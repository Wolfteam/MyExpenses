import 'package:drift/drift.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/models/entities.dart';
import 'package:my_expenses/domain/models/entities/daos/users_dao.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/infrastructure/db/database.dart';

part 'users_dao_impl.g.dart';

@DriftAccessor(tables: [Users])
class UsersDaoImpl extends DatabaseAccessor<AppDatabase> with _$UsersDaoImplMixin implements UsersDao {
  UsersDaoImpl(super.db);

  @override
  Future<List<UserItem>> getAllUsers() {
    return select(users).map(_mapToUserItem).get();
  }

  @override
  Future<UserItem> getUser(String googleUserId) {
    return (select(users)..where((u) => u.googleUserId.equals(googleUserId))).map(_mapToUserItem).getSingle();
  }

  @override
  Future<UserItem> saveUser(
    String googleUserId,
    String fullName,
    String email,
    String imgUrl,
  ) async {
    int id;
    final existingUser = await (select(users)..where((u) => u.googleUserId.equals(googleUserId))).getSingleOrNull();
    final now = DateTime.now();
    //user exists
    if (existingUser != null) {
      id = existingUser.id;
      final updatedFields = UsersCompanion(
        email: Value(email),
        isActive: const Value(false),
        name: Value(fullName),
        pictureUrl: Value(imgUrl),
        updatedAt: Value(now),
        updatedBy: const Value(createdBy),
      );
      await (update(users)..where((u) => u.id.equals(existingUser.id))).write(updatedFields);
    } else {
      id = await into(users).insert(
        UsersCompanion.insert(
          localStatus: LocalStatusType.nothing,
          googleUserId: googleUserId,
          isActive: const Value(false),
          name: fullName,
          email: email,
          pictureUrl: Value(imgUrl),
          createdBy: createdBy,
          createdAt: now,
          createdHash: createdHash([
            googleUserId,
            false,
            fullName,
            email,
            imgUrl,
            createdBy,
            now,
          ]),
        ),
      );
    }

    await changeActiveUser(id);
    return (select(users)..where((u) => u.id.equals(id))).map(_mapToUserItem).getSingle();
  }

  @override
  Future<UserItem?> getActiveUser() {
    return (select(users)..where((u) => u.isActive)).map(_mapToUserItem).getSingleOrNull();
  }

  @override
  Future<void> changeActiveUser(int? newActiveUserId) async {
    await update(users).write(
      UsersCompanion(
        updatedBy: const Value(createdBy),
        updatedAt: Value(DateTime.now()),
        isActive: const Value(false),
      ),
    );

    if (newActiveUserId != null) {
      await (update(users)..where((u) => u.id.equals(newActiveUserId))).write(
        UsersCompanion(
          updatedBy: const Value(createdBy),
          updatedAt: Value(DateTime.now()),
          isActive: const Value(true),
        ),
      );
    }
  }

  @override
  Future<bool> deleteUser(int id) async {
    await (delete(users)..where((u) => u.id.equals(id))).go();
    final remainingUsers = await (select(users)
          ..orderBy(
            [(u) => OrderingTerm(expression: u.id)],
          ))
        .get();
    if (remainingUsers.isNotEmpty) {
      await changeActiveUser(remainingUsers.first.id);
    }
    return true;
  }

  @override
  Future<void> deleteAll() {
    return delete(users).go();
  }

  UserItem _mapToUserItem(User user) {
    return UserItem(
      id: user.id,
      email: user.email,
      googleUserId: user.googleUserId,
      isActive: user.isActive,
      name: user.name,
      pictureUrl: user.pictureUrl,
    );
  }
}
