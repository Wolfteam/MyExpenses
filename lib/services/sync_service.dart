import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../common/enums/local_status_type.dart';
import '../common/enums/secure_resource_type.dart';
import '../common/utils/app_path_utils.dart';
import '../daos/categories_dao.dart';
import '../daos/transactions_dao.dart';
import '../daos/users_dao.dart';
import '../models/drive/app_file.dart';
import '../services/google_service.dart';
import '../services/logging_service.dart';
import '../services/secure_storage_service.dart';

abstract class SyncService {
  Future<void> initializeAppFolderAndFiles();

  Future<void> downloadAndUpdateFile();
}

class SyncServiceImpl implements SyncService {
  final LoggingService _logger;
  final TransactionsDao _transactionsDao;
  final CategoriesDao _categoriesDao;
  final UsersDao _usersDao;
  final GoogleService _googleService;
  final SecureStorageService _secureStorageService;

  static const _appFile = 'app_file.json';
  static const _readmeFile = 'README.md';

  Future<String> get appFilePath async {
    final dir = await getExternalStorageDirectory();
    final path = '${dir.path}/$_appFile';
    return path;
  }

  Future<String> get readmeFilePath async {
    final dir = await getExternalStorageDirectory();
    final path = '${dir.path}/$_readmeFile';
    return path;
  }

  SyncServiceImpl(
    this._logger,
    this._transactionsDao,
    this._categoriesDao,
    this._usersDao,
    this._googleService,
    this._secureStorageService,
  );

  @override
  Future<void> initializeAppFolderAndFiles() async {
    try {
      _logger.info(
        runtimeType,
        'createAppFolderAndFiles: Checking if drive folder exists...',
      );
      final currentUser = await _secureStorageService.get(
        SecureResourceType.currentUser,
        _secureStorageService.defaultUsername,
      );
      final folderExists = await _googleService.appFolderExist();

      if (!folderExists) {
        await _onFirstInstall();
      } else {
        await _onExistingInstall(currentUser);
      }
    } catch (e, s) {
      _logger.error(
        runtimeType,
        'createAppFolderAndFiles: An unknown error occurred',
        e,
        s,
      );
      rethrow;
    }
  }

  @override
  Future<void> downloadAndUpdateFile() async {
    try {
      _logger.info(
        runtimeType,
        'downloadAndUpdateFile: Getting remote app file....',
      );
      final filePath = await appFilePath;
      final fileId = await _googleService.downloadFile(_appFile, filePath);
      final appFile = await _getLocalAppFile(filePath);
      final user = await _usersDao.getActiveUser();
      await _performSyncDown(user.id, appFile);

      await _performSyncUp(user.id);

      _logger.info(
        runtimeType,
        'downloadAndUpdateFile: Creating local file....',
      );
      await _createLocalAppFile();

      _logger.info(runtimeType, 'downloadAndUpdateFile: Updating file...');
      final path = await appFilePath;
      await _googleService.updateFile(fileId, path);
      _logger.info(runtimeType, 'downloadAndUpdateFile: File was updated');

      await _updateLocalStatus(LocalStatusType.nothing);

      await _updateImgFiles();
    } catch (e, s) {
      _logger.error(
        runtimeType,
        'updateFile: An error occurred while trying to update file',
        e,
        s,
      );
      rethrow;
    }
  }

  Future<void> _uploadAppFile(
    String currentUser,
  ) async {
    try {
      _logger.info(
        runtimeType,
        '_uploadAppFile: Trying to upload app file to drive',
      );
      final filePath = await appFilePath;
      final fileExists = await File(filePath).exists();
      if (!fileExists) {
        _logger.warning(
          runtimeType,
          '_uploadAppFile: File to upload doesnt exists',
        );
        return;
      }

      final appFileId = await _googleService.uploadFile(filePath);
      _logger.info(
        runtimeType,
        '_uploadAppFile: File was successfully uploaded',
      );
      await _updateLocalStatus(LocalStatusType.nothing);
      await _secureStorageService.save(
        SecureResourceType.currentUserAppFileId,
        currentUser,
        appFileId,
      );
    } catch (e, s) {
      _logger.error(
        runtimeType,
        '_uploadAppFile: An error occurred while trying to upload file',
        e,
        s,
      );
    }
  }

  Future<void> _createLocalAppFile() async {
    _logger.info(runtimeType, 'createAppFile: Creating $_appFile');
    try {
      _logger.info(
        runtimeType,
        'createAppFile: Getting all transactions to save..',
      );
      final currentUser = await _usersDao.getActiveUser();

      final transactions = await _transactionsDao.getAllTransactionsToSync(
        currentUser.id,
      );

      _logger.info(
        runtimeType,
        'createAppFile: Getting all categories to save..',
      );
      final categories = await _categoriesDao.getAllCategoriesToSync(
        currentUser.id,
      );

      final appFile = AppFile(
        transactions: transactions,
        categories: categories,
      );
      final encoded = jsonEncode(appFile);
      final path = await appFilePath;

      final file = File(path);

      _logger.info(runtimeType, 'createAppFile: Saving file..');
      await file.writeAsString(encoded);
    } catch (e, s) {
      _logger.error(
        runtimeType,
        'createAppFile: An error occurred while trying to create file',
        e,
        s,
      );
    }
  }

  Future<void> _createReadmeFile() async {
    try {
      _logger.info(runtimeType, '_createReadmeFile: Creating $_readmeFile');
      final path = await readmeFilePath;
      final file = File(path);
      const contents = 'DO NOT DELETE NOR MODIFY THIS FOLDER AND ITS CONTENTS.\n' +
          'This folder is used by MyExpenses to keep your transactions and categories synced';
      await file.writeAsString(contents);
    } catch (e, s) {
      _logger.error(
        runtimeType,
        '_createReadmeFile: An error occurred while trying to create file',
        e,
        s,
      );
    }
  }

  Future<void> _onFirstInstall() async {
    _logger.info(
      runtimeType,
      '_onFirstInstall: Creating drive folder...',
    );

    final currentUser = await _usersDao.getActiveUser();
    _logger.info(
      runtimeType,
      '_onFirstInstall: Updating categories...',
    );

    await _categoriesDao.updateUserId(currentUser.id);

    _logger.info(
      runtimeType,
      '_onFirstInstall: Creating app and readme files...',
    );

    await _createLocalAppFile();
    // await _createReadmeFile();

    _logger.info(
      runtimeType,
      '_onFirstInstall: Uploading app and readme files...',
    );
    await _uploadAppFile(currentUser.email);
    // await _uploadReadmeFile(folderId);
    await _uploadAllLocalImgs();
  }

  Future<void> _onExistingInstall(
    String currentUser,
  ) async {
    _logger.info(
      runtimeType,
      '_onExistingInstall: Getting appfile...',
    );
    final filePath = await appFilePath;
    final fileId = await _googleService.downloadFile(_appFile, filePath);
    await _secureStorageService.save(
      SecureResourceType.currentUserAppFileId,
      currentUser,
      fileId,
    );

    _logger.info(
      runtimeType,
      '_onExistingInstall: Getting remote imgs...',
    );
    await _downloadAllRemoteImgs();

    final appFile = await _getLocalAppFile(filePath);
    final user = await _usersDao.getActiveUser();

    _logger.info(
      runtimeType,
      '_onExistingInstall: Deleting all existing categories and transactions...',
    );
    await _categoriesDao.deleteAll();
    await _transactionsDao.deleteAll();

    await _performSyncDown(user.id, appFile);
  }

  Future<void> _uploadReadmeFile(String folderId) async {
    final readmePath = await readmeFilePath;
    await _googleService.uploadFile(readmePath);
  }

  Future<AppFile> _getLocalAppFile(String filePath) async {
    final file = File(filePath);
    final json = await file.readAsString();
    final appFile = AppFile.fromJson(jsonDecode(json) as Map<String, dynamic>);
    return appFile;
  }

  Future<void> _performSyncDown(int userId, AppFile appFile) async {
    //The order is important
    _logger.info(
      runtimeType,
      '_performSyncDown: Creating categories and transactions...',
    );
    await _categoriesDao.syncDownCreate(userId, appFile.categories);
    await _transactionsDao.syncDownCreate(userId, appFile.transactions);

    _logger.info(
      runtimeType,
      '_performSyncDown: Deleting categories and transactions...',
    );
    await _transactionsDao.syncDownDelete(userId, appFile.transactions);
    await _categoriesDao.syncDownDelete(userId, appFile.categories);

    _logger.info(
      runtimeType,
      '_performSyncDown: Updating categories and transactions...',
    );
    await _categoriesDao.syncDownUpdate(userId, appFile.categories);
    await _transactionsDao.syncDownUpdate(userId, appFile.transactions);

    //TODO: SYNC IMG in the bg
    //TODO: IF THE USER SWITCHES ACCOUNTS, YOU SHOULD ONLY SYNC THE USER TRANSACTIONS SO, WHEN YOU GET THE
    //TRANSACTIONS YOU MUST DO AN INNER JOIN WITH CATEGORIES AND SEARCH FOR THE ID
  }

  Future<void> _performSyncUp(int userId) async {
    //The order is important
    _logger.info(
      runtimeType,
      '_performSyncUp: Deleting categories and transactions...',
    );
    await _transactionsDao.syncUpDelete(userId);
    await _categoriesDao.syncUpDelete(userId);
  }

  Future<void> _updateLocalStatus(LocalStatusType newValue) {
    _logger.info(
      runtimeType,
      '_updateLocalStatus: Updating the local status for all categories and transactions',
    );
    return Future.wait([
      _categoriesDao.updateAllLocalStatus(newValue),
      _transactionsDao.updateAllLocalStatus(newValue),
    ]);
  }

  Future<void> _uploadAllLocalImgs() async {
    _logger.info(
      runtimeType,
      '_uploadAllLocalImgs: Trying to upload all local imgs...',
    );

    try {
      final imgPath = await AppPathUtils.imagesPath;
      final imgs = await Directory(imgPath)
          .list()
          .asyncMap((f) => f.path)
          .where((path) => path.startsWith(AppPathUtils.transactionImgPrefix))
          .toList();

      _logger.info(
        runtimeType,
        '_uploadAllLocalImgs: ${imgs.length} will be uploaded...',
      );

      for (final path in imgs) {
        await _googleService.uploadFile(path);
      }
      _logger.info(
        runtimeType,
        '_uploadAllLocalImgs: Completed uploading all the imgs',
      );
    } catch (e, s) {
      _logger.error(
        runtimeType,
        '_uploadAllLocalImgs: Unknown error occurred',
        e,
        s,
      );
    }
  }

  Future<void> _downloadAllRemoteImgs() async {
    try {
      _logger.info(
        runtimeType,
        '_downloadAllRemoteImgs: Trying to download all remote imgs...',
      );
      final currentImgsMap = await _googleService.getAllImgs(
        AppPathUtils.transactionImgPrefix,
      );

      _logger.info(
        runtimeType,
        '_downloadAllRemoteImgs: ${currentImgsMap.length} images will be downloaded...',
      );

      final imgPath = await AppPathUtils.imagesPath;

      for (final kvp in currentImgsMap.entries) {
        final filePath = join(imgPath, kvp.value);
        await _googleService.downloadFile(kvp.value, filePath);
      }

      _logger.info(
        runtimeType,
        '_downloadAllRemoteImgs: Downloads completed',
      );
    } catch (e, s) {
      _logger.error(
        runtimeType,
        '_downloadAllRemoteImgs: Unknown error occurred',
        e,
        s,
      );
    }
  }

  Future<void> _updateImgFiles() async {
    try {
      _logger.info(runtimeType, '_updateImgFiles: Getting all remote imgs...');
      final currentImgsMap = await _googleService.getAllImgs(
        AppPathUtils.transactionImgPrefix,
      );

      _logger.info(runtimeType, '_updateImgFiles: Getting all local imgs...');
      final imgPath = await AppPathUtils.imagesPath;

      final imgs = await Directory(imgPath)
          .list()
          .asyncMap((f) => basename(f.path))
          .where((path) => path.contains(AppPathUtils.transactionImgPrefix))
          .toList();

      final imgsToDownload = currentImgsMap.entries
          .where((kvp) => !imgs.contains(kvp.value))
          .toList();

      final imgsToUpload = imgs
          .where((filename) => !currentImgsMap.values.contains(filename))
          .toList();

      _logger.info(
        runtimeType,
        '_updateImgFiles: We will download ${imgsToDownload.length} imgs...',
      );
      //TODO: CREATE MULTIPLE FUTURES
      for (final kvp in imgsToDownload) {
        final filePath = join(imgPath, kvp.value);
        await _googleService.downloadFile(kvp.value, filePath);
      }

      _logger.info(
        runtimeType,
        '_updateImgFiles: We will upload ${imgsToUpload.length} imgs...',
      );
      for (final filename in imgsToUpload) {
        final filePath = join(imgPath, filename);
        await _googleService.uploadFile(filePath);
      }
      _logger.info(
        runtimeType,
        '_updateImgFiles: Process completed...',
      );
    } catch (e, s) {
      _logger.error(
        runtimeType,
        '_updateImgFiles: Unknown error occurred',
        e,
        s,
      );
    }
  }
}
