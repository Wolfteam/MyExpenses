import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/domain/services/cloud_storage_service.dart';

abstract class GoogleService implements CloudStorageService {
  Future<bool> signIn();

  Future<bool?> signInSilently();

  Future<bool> signOut();

  Future<UserItem> getUserInfo();
}
