import 'dart:convert';
import 'dart:io';

import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/people/v1.dart' as people;
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart' as g_auth;
import 'package:http/http.dart' as http;

import '../common/enums/secure_resource_type.dart';
import '../models/user_item.dart';
import '../secrets.dart';
import 'secure_storage_service.dart';

abstract class GoogleService {
  String get redirectUrl;

  String getAuthUrl();

  Future<bool> exchangeAuthCodeAndSaveCredentials(String code);

  Future<UserItem> getUserInfo();
}

class GoogleServiceImpl implements GoogleService {
  final SecureStorageService _secureStorageService;

  static const _baseGoogleApisUrl = 'https://www.googleapis.com';
  final _authUrl = 'https://accounts.google.com/o/oauth2/v2/auth';
  final String _tokenUrl = '$_baseGoogleApisUrl/oauth2/v4/token';
  final _redirectUrl = 'http://localhost';
  final _scopes = <String>[
    people.PeopleApi.UserinfoEmailScope,
    people.PeopleApi.UserinfoProfileScope,
    drive.DriveApi.DriveScope,
    drive.DriveApi.DriveReadonlyScope,
    drive.DriveApi.DriveFileScope,
    sheets.SheetsApi.SpreadsheetsScope,
    sheets.SheetsApi.SpreadsheetsReadonlyScope,
    // 'email',
    // 'profile',
    // 'https://www.googleapis.com/auth/drive',
    // 'https://www.googleapis.com/auth/drive.readonly',
    // 'https://www.googleapis.com/auth/spreadsheets.readonly',
    // 'https://www.googleapis.com/auth/spreadsheets',
    // 'https://www.googleapis.com/auth/drive.file'
  ];

  @override
  String get redirectUrl => _redirectUrl;

  GoogleServiceImpl(this._secureStorageService);

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

      final credentials =
          g_auth.AccessCredentials(accessToken, refreshToken, _scopes);

      return await _saveAccessCredentials(credentials);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<UserItem> getUserInfo() async {
    try {
      final client = await _getAuthClient();

      final response =
          await client.get('$_baseGoogleApisUrl/oauth2/v3/userinfo');
      final json = jsonDecode(response.body);

      final user = UserItem(
        email: json['email'] as String,
        isActive: true,
        googleUserId: json['sub'] as String,
        name: json['name'] as String,
        pictureUrl: json['picture'] as String,
      );
      return user;
    } catch (error) {
      return null;
    }
  }

  Future<void> uploadFile(String file, String name) async {
    final client = await _getAuthClient();
    final api = drive.DriveApi(client);
    final localFile = File(file);
    final media = drive.Media(localFile.openRead(), localFile.lengthSync());
    final driveFile = drive.File();
    driveFile.name = name;
    driveFile.description = 'Uploaded by My Expenses';
    return api.files.create(driveFile, uploadMedia: media).then((f) {
      print('Uploaded $file. Id: ${f.id}');
    });
  }

  Future downloadFile(
    drive.DriveApi api,
    http.Client client,
    String objectId,
    String filename,
  ) {
    return api.files.get(objectId).then((file) {
      // The Drive API allows one to download files via `File.downloadUrl`.
      return client.readBytes(file.downloadUrl).then((bytes) {
        final stream = File(filename).openWrite()..add(bytes);
        return stream.close();
      });
    });
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
    if (type == null ||
        data == null ||
        expiricy == null ||
        refreshToken == null) {
      return null;
    }

    final accessToken =
        g_auth.AccessToken(type, data, DateTime.parse(expiricy));
    return g_auth.AccessCredentials(accessToken, refreshToken, _scopes);
  }

  Future<bool> _saveAccessCredentials(
    g_auth.AccessCredentials credentials,
  ) async {
    try {
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

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<http.Client> _getAuthClient() async {
    final credentials = await _getAccessCredentials();
    if (credentials == null) {
      throw Exception('Credentials does not exists');
    }

    return g_auth.authenticatedClient(http.Client(), credentials);
  }
}
