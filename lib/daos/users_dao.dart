import '../models/entities/database.dart';

abstract class UsersDao {
  Future<List<User>> getAllUsers();
}
