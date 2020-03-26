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

  Future<String> get appFilePath async {
    final dir = await getExternalStorageDirectory();
    final path = '${dir.path}/$_appFile';
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
        await _onFirstInstall(currentUser);
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
          runtimeType, 'createAppFile: Getting all categories to save..');
      final categories = await _categoriesDao.getAllCategoriesToSync();

      final appFile = AppFile(
        transactions: transactions,
        categories: categories,
      );
      final encoded = jsonEncode(appFile);
      final path = await appFilePath;

      final file = File(path);
      // bool fileExists = await file.exists();
      // if (fileExists) {
      //   final readed = await file.readAsString();
      //   final decoded = jsonDecode(readed) as Map<String, dynamic>;
      //   final appFilex2 = AppFile.fromJson(decoded);
      //   print("decoded");
      // }
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

  Future<void> _onFirstInstall(String currentUser) async {
    _logger.info(
      runtimeType,
      '_onFirstInstall: Creating drive folder and uploading app file...',
    );
    final folderId = await _googleService.createAppDriveFolder();

    await _secureStorageService.save(
      SecureResourceType.currentUserDriveFolderId,
      currentUser,
      folderId,
    );

    await createLocalAppFile();
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
    //The order is important
    // Create Cat - Trasn
    await _categoriesDao.createCategories(user.id, appFile.categories);
    await _transactionsDao.createTransactions(appFile.transactions);

    // Delete Trans - Cats
    await _categoriesDao.deleteCategories(user.id, appFile.categories);
    await _transactionsDao.deleteTransactions(appFile.transactions);

    //Update Cat - Trans
    await _categoriesDao.updateCategories(user.id, appFile.categories);
    await _transactionsDao.updateTransactions(appFile.transactions);
  }
}
