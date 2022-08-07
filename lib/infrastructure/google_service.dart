import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/people/v1.dart' as people;
import 'package:googleapis_auth/auth_io.dart' as g_auth;
import 'package:http/http.dart' as http;
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/domain/services/services.dart';
import 'package:path/path.dart';

class GoogleServiceImpl implements GoogleService {
  final LoggingService _logger;
  final SecureStorageService _secureStorageService;
  final GoogleSignIn _googleSignIn;

  static const _baseGoogleApisUrl = 'https://www.googleapis.com';
  static const _appDataFolder = 'appDataFolder';

  static const _scopes = <String>[
    people.PeopleServiceApi.userinfoEmailScope,
    people.PeopleServiceApi.userinfoProfileScope,
    drive.DriveApi.driveAppdataScope,
  ];

  GoogleServiceImpl(this._logger, this._secureStorageService) : _googleSignIn = GoogleSignIn(scopes: _scopes);

  Future<bool> _afterSignIn(GoogleSignInAccount account) async {
    final accessToken = await _getAccessToken(account);
    final credentials = g_auth.AccessCredentials(accessToken, null, _scopes);
    return _saveAccessCredentials(credentials);
  }

  @override
  Future<bool> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        return false;
      }
      return _afterSignIn(account);
    } catch (e, s) {
      _logger.error(runtimeType, 'signIn: Unknown error occurred', e, s);
      return false;
    }
  }

  @override
  Future<void> signInSilently() async {
    try{
      final isSignedIn = await _googleSignIn.isSignedIn();
      if (!isSignedIn){
        return;
      }
      final account = await _googleSignIn.signInSilently(reAuthenticate: true);
      if (account == null) {
        return;
      }
      await _afterSignIn(account);
    } catch (e, s) {
      _logger.error(runtimeType, 'signInSilently: Unknown error occurred', e, s);
    }
  }

  @override
  Future<bool> signOut() async {
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      return true;
    } catch (e, s) {
      _logger.error(runtimeType, 'signOut: Unknown error occurred', e, s);
      return false;
    }
  }

  @override
  Future<UserItem> getUserInfo() async {
    try {
      _logger.info(runtimeType, 'getUserInfo: Trying to get user info...');
      final client = await _getAuthClient();

      final response = await client.get(Uri.parse('$_baseGoogleApisUrl/oauth2/v3/userinfo'));
      final json = jsonDecode(response.body) as Map<String, dynamic>;

      final user = UserItem(
        id: -1,
        email: json['email'] as String,
        isActive: true,
        googleUserId: json['sub'] as String,
        name: json['name'] as String,
        pictureUrl: json['picture'] as String,
      );
      return user;
    } catch (e, s) {
      _logger.error(runtimeType, 'getUserInfo: Unknown error occurred...', e, s);
      rethrow;
    }
  }

  @override
  Future<bool> appFolderExist() async {
    try {
      _logger.info(runtimeType, 'appFolderExist: Trying to check if app folder exists');

      final client = await _getAuthClient();
      final api = drive.DriveApi(client);
      final fileList = await api.files.list(spaces: _appDataFolder);

      return fileList.files!.isNotEmpty;
    } catch (e, s) {
      _logger.error(runtimeType, 'appFolderExist: Unknown error occurred...', e, s);
      rethrow;
    }
  }

  @override
  Future<String> downloadFile(String fileName, String filePath) async {
    try {
      final fileToSave = File(filePath);
      final fileExists = await fileToSave.exists();
      if (fileExists) {
        _logger.info(runtimeType, 'downloadFile: A file with the same name exists on disk, deleting it...');
        await fileToSave.delete();
      }

      _logger.info(runtimeType, 'downloadFile: Getting an auth client');
      final client = await _getAuthClient();

      _logger.info(runtimeType, 'downloadFile: Downloading file = $fileName from drive...');
      final api = drive.DriveApi(client);
      final fileList = await api.files.list(
        q: "name='$fileName'",
        spaces: _appDataFolder,
      );

      final fileId = fileList.files?.first.id;
      _logger.info(runtimeType, 'downloadFile: Trying to download fileId = $fileId');
      final file = await api.files.get(
        fileId!,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      _logger.info(runtimeType, 'downloadFile: Saving downloaded file  to disk...');
      await fileToSave.openWrite().addStream(file.stream);
      _logger.info(runtimeType, 'downloadFile: File was successfully saved');
      return fileId;
    } catch (e, s) {
      _logger.error(runtimeType, 'downloadFile: Unknown error occurred...', e, s);
      rethrow;
    }
  }

  @override
  Future<String> uploadFile(String filePath) async {
    try {
      final localFile = File(filePath);
      final name = basename(localFile.path);
      _logger.info(runtimeType, 'uploadFile: Trying to upload file = $name...');

      final client = await _getAuthClient();
      final api = drive.DriveApi(client);
      final media = drive.Media(localFile.openRead(), localFile.lengthSync());
      final driveFile = drive.File()
        ..name = name
        ..description = 'Uploaded by My Expenses'
        ..parents = [_appDataFolder];

      final response = await api.files.create(driveFile, uploadMedia: media);

      _logger.info(runtimeType, 'uploadFile: File was successfully uploaded');

      return response.id!;
    } catch (e, s) {
      _logger.error(runtimeType, 'uploadFile: Unknown error occurred...', e, s);
      rethrow;
    }
  }

  @override
  Future<String> updateFile(String fileId, String filePath) async {
    try {
      final localFile = File(filePath);
      _logger.info(runtimeType, 'uploadFile: Trying to update file = ${basename(localFile.path)}');

      final client = await _getAuthClient();
      final api = drive.DriveApi(client);
      final media = drive.Media(localFile.openRead(), localFile.lengthSync());
      final driveFile = drive.File();

      final response = await api.files.update(
        driveFile,
        fileId,
        uploadMedia: media,
      );

      _logger.info(runtimeType, 'uploadFile: File was successfully updated');
      return response.id!;
    } catch (e, s) {
      _logger.error(runtimeType, 'updateFile: Unknown error occurred...', e, s);
      rethrow;
    }
  }

  @override
  Future<Map<String, String>> getAllImages(String imgPrefix) async {
    try {
      final files = <drive.File>[];
      String? pageToken;
      do {
        final client = await _getAuthClient();
        final api = drive.DriveApi(client);
        final result = await api.files.list(
          q: "name contains '$imgPrefix' and mimeType contains 'image/'",
          spaces: _appDataFolder,
          pageSize: 1000,
        );
        files.addAll(result.files!);
        pageToken = result.nextPageToken;
      } while (pageToken != null);

      return {for (var v in files) v.id!: v.name!};
    } catch (e, s) {
      _logger.error(runtimeType, 'getAllImages: Unknown error occurred...', e, s);
      rethrow;
    }
  }

  Future<g_auth.AccessCredentials?> _getAccessCredentials() async {
    final currentUser = await _secureStorageService.get(SecureResourceType.currentUser, _secureStorageService.defaultUsername);

    if (currentUser == null) {
      return null;
    }

    final type = await _secureStorageService.get(SecureResourceType.accessTokenType, currentUser);
    final data = await _secureStorageService.get(SecureResourceType.accessTokenData, currentUser);
    final expiricy = await _secureStorageService.get(SecureResourceType.accessTokenExpiricy, currentUser);

    if (type == null || data == null || expiricy == null) {
      return null;
    }

    final accessToken = g_auth.AccessToken(type, data, DateTime.parse(expiricy));
    final credentials = g_auth.AccessCredentials(accessToken, null, _scopes);
    return credentials;
  }

  Future<bool> _saveAccessCredentials(g_auth.AccessCredentials credentials) async {
    try {
      _logger.info(runtimeType, '_saveAccessCredentials: Trying to save access credentials...');
      final accessToken = credentials.accessToken;
      await Future.wait([
        _secureStorageService.save(SecureResourceType.accessTokenData, _secureStorageService.defaultUsername, accessToken.data),
        _secureStorageService.save(SecureResourceType.accessTokenExpiricy, _secureStorageService.defaultUsername, accessToken.expiry.toString()),
        _secureStorageService.save(SecureResourceType.accessTokenType, _secureStorageService.defaultUsername, accessToken.type),
        _secureStorageService.save(SecureResourceType.currentUser, _secureStorageService.defaultUsername, _secureStorageService.defaultUsername),
      ]);

      _logger.info(runtimeType, '_saveAccessCredentials: Access credentials were successfully saved');

      return true;
    } catch (e, s) {
      _logger.error(runtimeType, '_saveAccessCredentials: Unknown error occurred...', e, s);
      return false;
    }
  }

  Future<http.Client> _getAuthClient() async {
    _logger.info(runtimeType, '_getAuthClient: Getting auth client...');
    var credentials = await _getAccessCredentials();
    if (credentials == null) {
      _logger.warning(runtimeType, '_getAuthClient: Credentials does not exist');
      throw Exception('Credentials does not exist');
    }

    if (credentials.accessToken.hasExpired) {
      _logger.info(runtimeType, '_getAuthClient: Token expired, updating it...');
      final account = await _googleSignIn.signInSilently(reAuthenticate: true);
      if (account == null) {
        _logger.warning(runtimeType, '_getAuthClient: Could not sign in silently');
        throw Exception('Could not sign in silently');
      }
      final accessToken = await _getAccessToken(account);
      credentials = g_auth.AccessCredentials(accessToken, null, _scopes);

      _logger.info(runtimeType, '_getAuthClient: Token was updated, saving it...');
      await _saveAccessCredentials(credentials);
    }

    final client = g_auth.authenticatedClient(http.Client(), credentials);

    _logger.info(runtimeType, '_getAuthClient: Returning auth client...');
    return client;
  }

  Future<g_auth.AccessToken> _getAccessToken(GoogleSignInAccount account) async {
    final auth = await account.authentication;
    return g_auth.AccessToken(
      'Bearer',
      auth.accessToken!,
      DateTime.now().toUtc().add(const Duration(seconds: 3600)),
    );
  }
}
