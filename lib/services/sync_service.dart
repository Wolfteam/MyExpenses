import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

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

  Future<void> createLocalAppFile();

  Future<void> uploadAppFile();
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
  Future<void> createLocalAppFile() async {
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

  Future<void> createReadmeFile() async {
    try {
      _logger.info(runtimeType, 'createReadmeFile: Creating $_readmeFile');
      final path = await readmeFilePath;
      final file = File(path);
      const contents = 'DO NOT DELETE NOR MODIFY THIS FOLDER AND ITS CONTENTS.\n' +
          'This folder is used by MyExpenses to keep your transactions synced';
      await file.writeAsString(contents);
    } on Exception catch (e, s) {
      _logger.error(
        runtimeType,
        'createReadmeFile: An error occurred while trying to create file',
        e,
        s,
      );
    }
  }

  @override
  Future<void> uploadAppFile() async {
    try {
      _logger.info(
        runtimeType,
        'uploadAppFile: Trying to upload app file to drive',
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
          'uploadAppFile: File doesnt exists',
        );
        return;
      }

      final appFileId = await _googleService.uploadFile(appFolderId, filePath);

      await _secureStorageService.save(
        SecureResourceType.currentUserAppFileId,
        currentUser,
        appFileId,
      );
    } on Exception catch (e, s) {
      _logger.error(
        runtimeType,
        'uploadAppFile: An error occurred while trying to upload file',
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

    await createLocalAppFile();
    await createReadmeFile();

    _logger.info(
      runtimeType,
      '_onFirstInstall: Uploading app and readme files...',
    );
    await uploadAppFile();
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
    final file = await _googleService.downloadFile(_appFile, filePath);
    final json = await file.readAsString();
    final appFile = AppFile.fromJson(jsonDecode(json) as Map<String, dynamic>);
    final user = await _usersDao.getActiveUser();

    _logger.info(
      runtimeType,
      '_onExistingInstall: Creating categories and transactions...',
    );
    //The order is important
    // Create Cat - Trasn
    await _categoriesDao.createCategories(user.id, appFile.categories);
    await _transactionsDao.createTransactions(appFile.transactions);

    _logger.info(
      runtimeType,
      '_onExistingInstall: Deleting categories and transactions...',
    );

    // Delete Trans - Cats
    await _categoriesDao.deleteCategories(user.id, appFile.categories);
    await _transactionsDao.deleteTransactions(appFile.transactions);

    _logger.info(
      runtimeType,
      '_onExistingInstall: Updating categories and transactions...',
    );
    //Update Cat - Trans
    await _categoriesDao.updateCategories(user.id, appFile.categories);
    await _transactionsDao.updateTransactions(appFile.transactions);

    //TODO: SYNC IMG in the bg
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
}
