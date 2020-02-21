part of '../models/entities/database.dart';

@UseDao(tables: [Users])
class UsersDaoImpl extends DatabaseAccessor<AppDatabase>
    with _$UsersDaoImplMixin
    implements UsersDao {
  UsersDaoImpl(AppDatabase db) : super(db);

  @override
  Future<List<User>> getAllUsers() => select(users).get();
}
