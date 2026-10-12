import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
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

  Future<void>? _initialization;

  static const _baseGoogleApisUrl = 'https://www.googleapis.com';
  static const _appDataFolder = 'appDataFolder';

  static const _scopes = <String>[
    people.PeopleServiceApi.userinfoEmailScope,
    people.PeopleServiceApi.userinfoProfileScope,
    drive.DriveApi.driveAppdataScope,
  ];

  GoogleServiceImpl(this._logger, this._secureStorageService);

  Future<void> _ensureInitialized() async {
    //The in-flight future is memoized (instead of a bool) so that two concurrent first callers
    //end up awaiting the very same initialize() call instead of running it twice
    final initialization = _initialization ??= GoogleSignIn.instance.initialize();
    try {
      await initialization;
    } catch (_) {
      //A failed initialization must not be cached forever, otherwise no caller could ever retry
      if (_initialization == initialization) {
        _initialization = null;
      }
      rethrow;
    }
  }

  @override
  Future<bool> isAvailable() async {
    try {
      await _ensureInitialized();
      final account = await GoogleSignIn.instance.attemptLightweightAuthentication();
      return account != null;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _afterSignIn(GoogleSignInAccount account) async {
    _logger.info(runtimeType, '_afterSignIn: Getting access token and saving it..');
    final accessToken = await _getAccessToken(account);
    final credentials = g_auth.AccessCredentials(accessToken, null, _scopes);
    return _saveAccessCredentials(credentials);
  }

  @override
  Future<bool> signIn() async {
    try {
      await _ensureInitialized();
      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        _logger.error(runtimeType, 'signIn: Platform does not support authenticate()');
        return false;
      }
      final account = await GoogleSignIn.instance.authenticate(scopeHint: _scopes);
      _logger.info(runtimeType, 'signIn: Successfully retrieved account details');
      //This is the only user-initiated path, hence the only one allowed to prompt for the scopes
      await _getAuthorizationInteractively(account);
      return await _afterSignIn(account);
    } catch (e, s) {
      _logger.error(runtimeType, 'signIn: Unknown error occurred', e, s);
      return false;
    }
  }

  @override
  Future<bool?> signInSilently() async {
    try {
      await _ensureInitialized();
      final account = await GoogleSignIn.instance.attemptLightweightAuthentication();
      if (account == null) {
        _logger.info(runtimeType, 'signInSilently: User is not signed in');
        return null;
      }
      await _afterSignIn(account);
      return true;
    } catch (e, s) {
      _logger.error(runtimeType, 'signInSilently: Unknown error occurred', e, s);
    }
    return false;
  }

  @override
  Future<bool> signOut() async {
    try {
      await _ensureInitialized();
      await GoogleSignIn.instance.signOut();
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
      final file = await api.files.get(fileId!, downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;

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
    } on drive.DetailedApiRequestError catch (e, s) {
      if (e.status == 403 && e.errors.any((err) => err.reason?.contains('storageQuotaExceeded') ?? false)) {
        _logger.error(runtimeType, 'uploadFile: Google Drive storage quota exceeded', e, s);
      } else {
        _logger.error(runtimeType, 'uploadFile: API error occurred', e, s);
      }
      rethrow;
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
    } on drive.DetailedApiRequestError catch (e, s) {
      if (e.status == 403 && e.errors.any((err) => err.reason?.contains('storageQuotaExceeded') ?? false)) {
        _logger.error(runtimeType, 'updateFile: Google Drive storage quota exceeded', e, s);
      } else {
        _logger.error(runtimeType, 'updateFile: API error occurred', e, s);
      }
      rethrow;
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

      return {for (final v in files) v.id!: v.name!};
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
        _secureStorageService.save(
          SecureResourceType.accessTokenExpiricy,
          _secureStorageService.defaultUsername,
          accessToken.expiry.toString(),
        ),
        _secureStorageService.save(SecureResourceType.accessTokenType, _secureStorageService.defaultUsername, accessToken.type),
        _secureStorageService.save(
          SecureResourceType.currentUser,
          _secureStorageService.defaultUsername,
          _secureStorageService.defaultUsername,
        ),
      ]);

      _logger.info(runtimeType, '_saveAccessCredentials: Access credentials were successfully saved');

      return true;
    } catch (e, s) {
      _logger.error(runtimeType, '_saveAccessCredentials: Unknown error occurred...', e, s);
      return false;
    }
  }

  Future<http.Client> _getAuthClient() async {
    await _ensureInitialized();
    _logger.info(runtimeType, '_getAuthClient: Getting auth client...');
    var credentials = await _getAccessCredentials();
    if (credentials == null) {
      _logger.warning(runtimeType, '_getAuthClient: Credentials does not exist');
      throw Exception('Credentials does not exist');
    }

    if (!credentials.accessToken.hasExpired) {
      //The stored token is still valid, so build the client out of it directly, just like the
      //pre 7.x implementation did, without consulting google_sign_in at all
      _logger.info(runtimeType, '_getAuthClient: Returning auth client...');
      return g_auth.authenticatedClient(http.Client(), credentials);
    }

    _logger.info(runtimeType, '_getAuthClient: Token expired, updating it...');
    final account = await GoogleSignIn.instance.attemptLightweightAuthentication();
    if (account == null) {
      _logger.warning(runtimeType, '_getAuthClient: Could not sign in silently');
      throw Exception('Could not sign in silently');
    }

    final accessToken = await _getAccessToken(account);
    credentials = g_auth.AccessCredentials(accessToken, null, _scopes);
    _logger.info(runtimeType, '_getAuthClient: Token was updated, saving it...');
    await _saveAccessCredentials(credentials);

    final authorization = await _getAuthorizationSilently(account);
    if (authorization == null) {
      _logger.warning(runtimeType, '_getAuthClient: Could not sign in silently');
      throw Exception('Could not sign in silently');
    }

    _logger.info(runtimeType, '_getAuthClient: Returning auth client...');
    return authorization.authClient(scopes: _scopes);
  }

  Future<g_auth.AccessToken> _getAccessToken(GoogleSignInAccount account) async {
    final authorization = await _getAuthorizationSilently(account);
    if (authorization == null) {
      _logger.warning(runtimeType, '_getAccessToken: Could not sign in silently');
      throw Exception('Could not sign in silently');
    }

    return g_auth.AccessToken(
      'Bearer',
      authorization.accessToken,
      DateTime.now().toUtc().add(const Duration(seconds: 3600)),
    );
  }

  //Non-prompting authorization lookup. It never shows any ui, hence it is the only variant that
  //can be safely used on cold start and from the workmanager background isolate
  Future<GoogleSignInClientAuthorization?> _getAuthorizationSilently(GoogleSignInAccount account) {
    return account.authorizationClient.authorizationForScopes(_scopes);
  }

  //This one may show a google consent sheet, so it must ONLY be called from a user-interaction
  //path (that is, the user-initiated signIn)
  Future<GoogleSignInClientAuthorization> _getAuthorizationInteractively(GoogleSignInAccount account) async {
    final client = account.authorizationClient;
    final existing = await client.authorizationForScopes(_scopes);
    if (existing != null) {
      return existing;
    }
    return client.authorizeScopes(_scopes);
  }
}
