import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../common/enums/secure_resource_type.dart';

abstract class SecureStorageService {
  String get defaultUsername;

  Future<void> save(SecureResourceType resource, String username, String value);

  Future<String?> get(SecureResourceType resource, String username);

  Future<void> delete(SecureResourceType resource, String username);

  Future<void> deleteAll(String username);

  Future<void> update(
    SecureResourceType resource,
    String username,
    bool updateUsername,
    String newValueOrOwner,
  );
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
  Future<String?> get(SecureResourceType resource, String username) {
    final key = _buildKey(resource, username);
    return _storage.read(key: key);
  }

  @override
  Future<void> deleteAll(String username) async {
    const values = SecureResourceType.values;
    for (final item in values) {
      final key = item == SecureResourceType.currentUser ? _buildKey(item, defaultUsername) : _buildKey(item, username);
      await _storage.delete(key: key);
    }
  }

  @override
  Future<void> delete(SecureResourceType resource, String username) {
    final key = _buildKey(resource, username);
    return _storage.delete(key: key);
  }

  @override
  Future<void> update(
    SecureResourceType resource,
    String username,
    bool updateUsername,
    String newValueOrOwner,
  ) async {
    if (updateUsername) {
      final currentSecret = await get(resource, username);
      await delete(resource, username);
      await save(resource, newValueOrOwner, currentSecret!);
      return;
    }
    await delete(resource, username);
    await save(resource, username, newValueOrOwner);
  }

  String _buildKey(SecureResourceType resourceType, String username) => '${username}_$resourceType';
}
