import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../common/enums/local_status_type.dart';
import '../common/enums/secure_resource_type.dart';
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
      final folderId = await _googleService.getAppFolder();

      if (folderId == null) {
        await _onFirstInstall();
      } else {
        await _onExistingInstall(folderId, currentUser);
      }
    } on Exception catch (e, s) {
      _logger.error(
        runtimeType,
        'createAppFolderAndFiles: An unknown error occurred',
        e,
        s,
      );
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
      await _performSync(user.id, appFile);

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
    } on Exception catch (e, s) {
      _logger.error(
        runtimeType,
        'updateFile: An error occurred while trying to update file',
        e,
        s,
      );
    }
  }

  Future<void> _uploadAppFile() async {
    try {
      _logger.info(
        runtimeType,
        '_uploadAppFile: Trying to upload app file to drive',
      );
      final currentUser = await _secureStorageService.get(
        SecureResourceType.currentUser,
        _secureStorageService.defaultUsername,
      );
      final appFolderId = await _secureStorageService.get(
        SecureResourceType.currentUserDriveFolderId,
        currentUser,
      );
      final filePath = await appFilePath;
      final fileExists = await File(filePath).exists();
      if (!fileExists) {
        _logger.warning(
          runtimeType,
          '_uploadAppFile: File doesnt exists',
        );
        return;
      }

      final appFileId = await _googleService.uploadFile(appFolderId, filePath);
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
    } on Exception catch (e, s) {
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
      final transactions = await _transactionsDao.getAllTransactionsToSync();
      _logger.info(
        runtimeType,
        'createAppFile: Getting all categories to save..',
      );

      final currentUser = await _usersDao.getActiveUser();
      final categories =
          await _categoriesDao.getAllCategoriesToSync(currentUser.id);

      final appFile = AppFile(
        transactions: transactions,
        categories: categories,
      );
      final encoded = jsonEncode(appFile);
      final path = await appFilePath;

      final file = File(path);

      _logger.info(runtimeType, 'createAppFile: Saving file..');
      await file.writeAsString(encoded);
    } on Exception catch (e, s) {
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
    } on Exception catch (e, s) {
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
    final folderId = await _googleService.createAppDriveFolder();

    await _secureStorageService.save(
      SecureResourceType.currentUserDriveFolderId,
      currentUser.email,
      folderId,
    );

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
    await _createReadmeFile();

    _logger.info(
      runtimeType,
      '_onFirstInstall: Uploading app and readme files...',
    );
    await _uploadAppFile();
    await _uploadReadmeFile();
  }

  Future<void> _onExistingInstall(
    String folderId,
    String currentUser,
  ) async {
    _logger.info(
      runtimeType,
      '_onExistingInstall: Getting appfile...',
    );
    await _secureStorageService.save(
      SecureResourceType.currentUserDriveFolderId,
      currentUser,
      folderId,
    );
    final filePath = await appFilePath;
    final fileId = await _googleService.downloadFile(_appFile, filePath);
    await _secureStorageService.save(
      SecureResourceType.currentUserAppFileId,
      currentUser,
      fileId,
    );

    final appFile = await _getLocalAppFile(filePath);
    final user = await _usersDao.getActiveUser();

    _logger.info(
      runtimeType,
      '_onExistingInstall: Deleting all existing categories and transactions...',
    );
    await _categoriesDao.deleteAll();
    await _transactionsDao.deleteAll();

    await _performSync(user.id, appFile);
  }

  Future<void> _uploadReadmeFile() async {
    final currentUser = await _secureStorageService.get(
      SecureResourceType.currentUser,
      _secureStorageService.defaultUsername,
    );
    final appFolderId = await _secureStorageService.get(
      SecureResourceType.currentUserDriveFolderId,
      currentUser,
    );

    final readmePath = await readmeFilePath;
    await _googleService.uploadFile(appFolderId, readmePath);
  }

  Future<AppFile> _getLocalAppFile(String filePath) async {
    final file = File(filePath);
    final json = await file.readAsString();
    final appFile = AppFile.fromJson(jsonDecode(json) as Map<String, dynamic>);
    return appFile;
  }

  Future<void> _performSync(int userId, AppFile appFile) async {
    //The order is important
    _logger.info(
      runtimeType,
      '_performSync: Creating categories and transactions...',
    );
    await _categoriesDao.createCategories(userId, appFile.categories);
    await _transactionsDao.createTransactions(appFile.transactions);

    _logger.info(
      runtimeType,
      '_performSync: Deleting categories and transactions...',
    );
    await _categoriesDao.deleteCategories(userId, appFile.categories);
    await _transactionsDao.deleteTransactions(appFile.transactions);

    _logger.info(
      runtimeType,
      '_performSync: Updating categories and transactions...',
    );
    await _categoriesDao.updateCategories(userId, appFile.categories);
    await _transactionsDao.updateTransactions(appFile.transactions);

    //TODO: SYNC IMG in the bg
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
}
