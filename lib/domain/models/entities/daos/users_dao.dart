import 'package:my_expenses/domain/models/models.dart';

abstract class UsersDao {
  Future<List<UserItem>> getAllUsers();

  Future<UserItem?> getActiveUser();

  Future<UserItem> getUser(String googleUserId);

  Future<UserItem> saveUser(String googleUserId, String fullName, String email, String imgUrl);

  Future<bool> deleteUser(int id);

  Future<void> deleteAll();

  Future<void> changeActiveUser(int? newActiveUserId);
}
