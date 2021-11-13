import 'package:my_expenses/domain/enums/enums.dart';

abstract class SecureStorageService {
  String get defaultUsername;

  Future<void> save(SecureResourceType resource, String username, String value);

  Future<String?> get(SecureResourceType resource, String username);

  Future<void> delete(SecureResourceType resource, String username);

  Future<void> deleteAll(String username);

  Future<void> update(SecureResourceType resource, String username, bool updateUsername, String newValueOrOwner);
}
