import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/people/v1.dart' as people;
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart' as g_auth;
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

import '../common/enums/secure_resource_type.dart';
import '../models/user_item.dart';
import '../secrets.dart';
import '../services/logging_service.dart';
import 'secure_storage_service.dart';

abstract class GoogleService {
  String get redirectUrl;

  String getAuthUrl();

  Future<bool> exchangeAuthCodeAndSaveCredentials(String code);

  Future<UserItem> getUserInfo();

  Future<bool> appFolderExist();

  Future<String> uploadFile(String filePath);

  Future<String> downloadFile(String fileName, String filePath);

  Future<String> updateFile(
    String fileId,
    String filePath,
  );

  Future<Map<String, String>> getAllImgs(
    String imgPrefix,
  );
}

class GoogleServiceImpl implements GoogleService {
  final LoggingService _logger;
  final SecureStorageService _secureStorageService;

  static const _baseGoogleApisUrl = 'https://www.googleapis.com';
  static const _folderMimeType = 'application/vnd.google-apps.folder';
  static const _spreadSheetName = 'Default SpreadSheet';
  static const _spreadSheetMimeType = 'application/vnd.google-apps.spreadsheet';
  static const _appDataFolder = 'appDataFolder';

  final _authUrl = 'https://accounts.google.com/o/oauth2/v2/auth';
  final String _tokenUrl = '$_baseGoogleApisUrl/oauth2/v4/token';
  final _redirectUrl = 'http://localhost';
  final _scopes = <String>[
    people.PeopleApi.UserinfoEmailScope,
    people.PeopleApi.UserinfoProfileScope,
    drive.DriveApi.DriveAppdataScope,
  ];

  @override
  String get redirectUrl => _redirectUrl;

  GoogleServiceImpl(this._logger, this._secureStorageService);

  @override
  String getAuthUrl() {
    final clientId = Uri.encodeQueryComponent(Secrets.googleClientId);
    final scopes = Uri.encodeQueryComponent(_scopes.join(' '));
    final redirectUrl = Uri.encodeQueryComponent(_redirectUrl);
    return '$_authUrl?client_id=$clientId&scope=$scopes&redirect_uri=$redirectUrl&response_type=code&include_granted_scopes=true';
  }

  @override
  Future<bool> exchangeAuthCodeAndSaveCredentials(String code) async {
    try {
      _logger.info(
        runtimeType,
        'exchangeAuthCodeAndSaveCredentials: Changing code for an auth token...',
      );
      final response = await http.post(_tokenUrl, body: {
        'client_id': Secrets.googleClientId,
        'redirect_uri': '$_redirectUrl',
        'grant_type': 'authorization_code',
        'code': code,
      });

      final json = jsonDecode(response.body);
      final token = json['access_token'] as String;
      final refreshToken = json['refresh_token'] as String;
      final type = json['token_type'] as String;
      final expiresIn = json['expires_in'] as int;

      final accessToken = g_auth.AccessToken(
        type,
        token,
        DateTime.now().toUtc().add(Duration(seconds: expiresIn)),
      );

      final credentials = g_auth.AccessCredentials(
        accessToken,
        refreshToken,
        _scopes,
      );
      return await _saveAccessCredentials(credentials);
    } catch (e, s) {
      _logger.error(
        runtimeType,
        'exchangeAuthCodeAndSaveCredentials: Unknown error occurred',
        e,
        s,
      );
      return false;
    }
  }

  @override
  Future<UserItem> getUserInfo() async {
    try {
      _logger.info(
        runtimeType,
        'getUserInfo: Trying to get user info...',
      );
      final client = await _getAuthClient();

      final response = await client.get('$_baseGoogleApisUrl/oauth2/v3/userinfo');
      final json = jsonDecode(response.body);

      final user = UserItem(
        email: json['email'] as String,
        isActive: true,
        googleUserId: json['sub'] as String,
        name: json['name'] as String,
        pictureUrl: json['picture'] as String,
      );
      return user;
    } catch (e, s) {
      _logger.error(
        runtimeType,
        'getUserInfo: Unknown error occurred...',
        e,
        s,
      );
      rethrow;
    }
  }

  @override
  Future<bool> appFolderExist() async {
    try {
      _logger.info(
        runtimeType,
        'appFolderExist: Trying to check if app folder exists',
      );

      final client = await _getAuthClient();
      final api = drive.DriveApi(client);
      final fileList = await api.files.list(
        spaces: _appDataFolder,
      );

      return fileList.files.isNotEmpty;
    } catch (e, s) {
      _logger.error(
        runtimeType,
        'appFolderExist: Unknown error occurred...',
        e,
        s,
      );
      rethrow;
    }
  }

  @override
  Future<String> downloadFile(
    String fileName,
    String filePath,
  ) async {
    try {
      final fileToSave = File(filePath);
      final fileExists = await fileToSave.exists();
      if (fileExists) {
        _logger.info(
          runtimeType,
          'downloadFile: A file with the same name exists on disk, deleting it...',
        );
        await fileToSave.delete();
      }

      _logger.info(
        runtimeType,
        'downloadFile: Getting an auth client',
      );
      final client = await _getAuthClient();

      _logger.info(
        runtimeType,
        'downloadFile: Downloading file = $fileName from drive...',
      );
      final api = drive.DriveApi(client);
      final fileList = await api.files.list(
        q: "name='$fileName'",
        spaces: _appDataFolder,
      );

      _logger.info(
        runtimeType,
        'downloadFile: Trying to donwload fileId = ${fileList?.files?.first?.id}',
      );
      final file = await api.files.get(
        fileList.files.first.id,
        downloadOptions: drive.DownloadOptions.FullMedia,
      ) as drive.Media;

      _logger.info(
        runtimeType,
        'downloadFile: Saving downloaded file  to disk...',
      );
      await fileToSave.openWrite().addStream(file.stream);
      _logger.info(
        runtimeType,
        'downloadFile: File was successfully saved',
      );
      return fileList.files.first.id;
    } catch (e, s) {
      _logger.error(
        runtimeType,
        'downloadFile: Unknown error occurred...',
        e,
        s,
      );
      rethrow;
    }
  }

  @override
  Future<String> uploadFile(String filePath) async {
    try {
      final localFile = File(filePath);
      final name = basename(localFile.path);
      _logger.info(
        runtimeType,
        'uploadFile: Trying to upload file = $name...',
      );

      final client = await _getAuthClient();
      final api = drive.DriveApi(client);
      final media = drive.Media(localFile.openRead(), localFile.lengthSync());
      final driveFile = drive.File()
        ..name = name
        ..description = 'Uploaded by My Expenses'
        ..parents = [_appDataFolder];

      final response = await api.files.create(driveFile, uploadMedia: media);

      _logger.info(
        runtimeType,
        'uploadFile: File was successfully uploaded',
      );

      return response.id;
    } catch (e, s) {
      _logger.error(
        runtimeType,
        'uploadFile: Unknown error occurred...',
        e,
        s,
      );
      rethrow;
    }
  }

  @override
  Future<String> updateFile(
    String fileId,
    String filePath,
  ) async {
    try {
      final localFile = File(filePath);
      _logger.info(
        runtimeType,
        'uploadFile: Trying to update file = ${basename(localFile.path)}',
      );

      final client = await _getAuthClient();
      final api = drive.DriveApi(client);
      final media = drive.Media(localFile.openRead(), localFile.lengthSync());
      final driveFile = drive.File();

      final response = await api.files.update(
        driveFile,
        fileId,
        uploadMedia: media,
      );

      _logger.info(
        runtimeType,
        'uploadFile: File was succesfully updated',
      );
      return response.id;
    } catch (e, s) {
      _logger.error(
        runtimeType,
        'updateFile: Unknown error occurred...',
        e,
        s,
      );
      rethrow;
    }
  }

  @override
  Future<Map<String, String>> getAllImgs(
    String imgPrefix,
  ) async {
    try {
      final files = <drive.File>[];
      String pageToken;
      do {
        final client = await _getAuthClient();
        final api = drive.DriveApi(client);
        final result = await api.files.list(
          q: "name contains '$imgPrefix' and mimeType contains 'image/'",
          spaces: _appDataFolder,
          pageSize: 1000,
        );
        files.addAll(result.files);
        pageToken = result.nextPageToken;
      } while (pageToken != null);

      return {for (var v in files) v.id: v.name};
    } catch (e, s) {
      _logger.error(
        runtimeType,
        'getAllImgs: Unknown error occurred...',
        e,
        s,
      );
      rethrow;
    }
  }

  Future<g_auth.AccessCredentials> _getAccessCredentials() async {
    final currentUser = await _secureStorageService.get(
      SecureResourceType.currentUser,
      _secureStorageService.defaultUsername,
    );

    final type = await _secureStorageService.get(
      SecureResourceType.accessTokenType,
      currentUser,
    );

    final data = await _secureStorageService.get(
      SecureResourceType.accessTokenData,
      currentUser,
    );

    final expiricy = await _secureStorageService.get(
      SecureResourceType.accessTokenExpiricy,
      currentUser,
    );

    final refreshToken = await _secureStorageService.get(
      SecureResourceType.refreshToken,
      currentUser,
    );
    if (type == null || data == null || expiricy == null || refreshToken == null) {
      return null;
    }

    final accessToken = g_auth.AccessToken(
      type,
      data,
      DateTime.parse(expiricy),
    );

    final credentials = g_auth.AccessCredentials(
      accessToken,
      refreshToken,
      _scopes,
    );

    return credentials;
  }

  Future<bool> _saveAccessCredentials(
    g_auth.AccessCredentials credentials,
  ) async {
    try {
      _logger.info(
        runtimeType,
        '_saveAccessCredentials: Trying to save access credentials...',
      );
      final accessToken = credentials.accessToken;
      final refreshToken = credentials.refreshToken;
      await Future.wait([
        _secureStorageService.save(
          SecureResourceType.accessTokenData,
          _secureStorageService.defaultUsername,
          accessToken.data,
        ),
        _secureStorageService.save(
          SecureResourceType.accessTokenExpiricy,
          _secureStorageService.defaultUsername,
          accessToken.expiry.toString(),
        ),
        _secureStorageService.save(
          SecureResourceType.accessTokenType,
          _secureStorageService.defaultUsername,
          accessToken.type,
        ),
        _secureStorageService.save(
          SecureResourceType.refreshToken,
          _secureStorageService.defaultUsername,
          refreshToken,
        ),
        _secureStorageService.save(
          SecureResourceType.currentUser,
          _secureStorageService.defaultUsername,
          _secureStorageService.defaultUsername,
        ),
      ]);

      _logger.info(
        runtimeType,
        '_saveAccessCredentials: Access credentials were successfully saved',
      );

      return true;
    } catch (e, s) {
      _logger.error(
        runtimeType,
        '_saveAccessCredentials: Unknown error occurred...',
        e,
        s,
      );
      return false;
    }
  }

  Future<http.Client> _getAuthClient() async {
    _logger.info(runtimeType, '_getAuthClient: Getting auth client...');
    var credentials = await _getAccessCredentials();
    if (credentials == null) {
      _logger.warning(runtimeType, '_getAuthClient: Credentials doesnt exist');
      throw Exception('Credentials does not exist');
    }

    if (credentials.accessToken.hasExpired) {
      _logger.info(
        runtimeType,
        '_getAuthClient: Token expired, updating it...',
      );
      credentials = await g_auth.refreshCredentials(
        g_auth.ClientId(Secrets.googleClientId, ''),
        credentials,
        http.Client(),
      );

      _logger.info(
        runtimeType,
        '_getAuthClient: Token was updated, saving it...',
      );
      await _saveAccessCredentials(credentials);
    }

    final client = g_auth.authenticatedClient(
      http.Client(),
      credentials,
    );

    _logger.info(runtimeType, '_getAuthClient: Returning auth client...');
    return client;
  }

//NOT USED
  Future<String> _createAppSheet(String folderId) async {
    final client = await _getAuthClient();
    final api = drive.DriveApi(client);
    final driveFile = drive.File()
      ..name = _spreadSheetName
      ..mimeType = _spreadSheetMimeType
      ..parents = [folderId];

    final spreadSheet = await api.files.create(driveFile);
    await _initializeAppSheet(spreadSheet.id);
    return spreadSheet.id;
  }

//NOT USED
  Future<void> _initializeAppSheet(String spreadSheetId) async {
    final client = await _getAuthClient();
    final api = sheets.SheetsApi(client);

    final spreadSheet = await api.spreadsheets.get(spreadSheetId);
    final defaultSheetId = spreadSheet.sheets.first.properties.sheetId;

    final transSheetProps = sheets.SheetProperties()..title = 'Transactitons';
    final categoriesSheetProps = sheets.SheetProperties()..title = 'Categories';

    final transSheetRequest = sheets.Request()..addSheet = (sheets.AddSheetRequest()..properties = transSheetProps);
    final catSheetRequest = sheets.Request()..addSheet = (sheets.AddSheetRequest()..properties = categoriesSheetProps);
    final deleteRequest = sheets.Request()..deleteSheet = (sheets.DeleteSheetRequest()..sheetId = defaultSheetId);

    final updateRequest = sheets.BatchUpdateSpreadsheetRequest()
      ..requests = [
        transSheetRequest,
        catSheetRequest,
        deleteRequest,
      ];

    await api.spreadsheets.batchUpdate(updateRequest, spreadSheetId);
  }
}
