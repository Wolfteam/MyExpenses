import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../common/enums/secure_resource_type.dart';

abstract class SecureStorageService {
  String get defaultUsername;

  Future save(SecureResourceType resource, String username, String value);

  Future<String> get(SecureResourceType resource, String username);

  Future<void> delete(SecureResourceType resource, String username);

  Future<void> deleteAll();
}

class SecureStorageServiceImpl implements SecureStorageService {
  final _storage = const FlutterSecureStorage();

  @override
  String get defaultUsername => 'DefaultUser';

  @override
  Future<void> save(
    SecureResourceType resource,
    String username,
    String value,
  ) {
    final key = _buildKey(resource, username);
    return _storage.write(key: key, value: value);
  }

  @override
  Future<String> get(SecureResourceType resource, String username) {
    final key = _buildKey(resource, username);
    return _storage.read(key: key);
  }

  @override
  Future<void> deleteAll() {
    return _storage.deleteAll();
  }

  @override
  Future<void> delete(SecureResourceType resource, String username) {
    final key = _buildKey(resource, username);
    return _storage.delete(key: key);
  }

  String _buildKey(SecureResourceType resourceType, String username) =>
      '${username}_$resourceType';
}
