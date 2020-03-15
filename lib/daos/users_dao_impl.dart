part of '../models/entities/database.dart';

@UseDao(tables: [Users])
class UsersDaoImpl extends DatabaseAccessor<AppDatabase>
    with _$UsersDaoImplMixin
    implements UsersDao {
  UsersDaoImpl(AppDatabase db) : super(db);

  @override
  Future<List<UserItem>> getAllUsers() {
    return select(users).map(_mapToUserItem).get();
  }

  @override
  Future<UserItem> getUser(String googleUserId) {
    return (select(users)..where((u) => u.googleUserId.equals(googleUserId)))
        .map(_mapToUserItem)
        .getSingle();
  }

  @override
  Future<UserItem> saveUser(
    String googleUserId,
    String fullName,
    String email,
    String imgUrl,
  ) async {
    int id;
    final existingUser = await (select(users)
          ..where((u) => u.googleUserId.equals(googleUserId)))
        .getSingle();
    //user exists
    if (existingUser != null) {
      id = existingUser.id;
      final updatedFields = UsersCompanion(
        email: Value(email),
        isActive: const Value(false),
        name: Value(fullName),
        pictureUrl: Value(imgUrl),
        updatedAt: Value(DateTime.now()),
        updatedBy: const Value(createdBy),
      );
      await (update(users)..where((u) => u.id.equals(existingUser.id)))
          .write(updatedFields);
    } else {
      id = await into(users).insert(User(
        googleUserId: googleUserId,
        isActive: false,
        name: fullName,
        email: email,
        pictureUrl: imgUrl,
        createdBy: createdBy,
      ));
    }

    await changeActiveUser(id);
    return (select(users)..where((u) => u.id.equals(id)))
        .map(_mapToUserItem)
        .getSingle();
  }

  @override
  Future<UserItem> getActiveUser() {
    return (select(users)..where((u) => u.isActive))
        .map(_mapToUserItem)
        .getSingle();
  }

  @override
  Future<void> changeActiveUser(int newActiveUserId) async {
    await batch((b) {
      b.update(
        users,
        UsersCompanion(
          updatedBy: const Value(createdBy),
          updatedAt: Value(DateTime.now()),
          isActive: const Value(false),
        ),
      );

      if (newActiveUserId != null) {
        b.update<Users, User>(
          users,
          UsersCompanion(
            updatedBy: const Value(createdBy),
            updatedAt: Value(DateTime.now()),
            isActive: const Value(true),
          ),
          where: (u) => u.id.equals(newActiveUserId),
        );
      }
    });
  }

  @override
  Future<bool> deleteUser(int id) async {
    await (delete(users)..where((u) => u.id.equals(id))).go();
    final remainingUsers = await (select(users)
          ..orderBy(
            [(u) => OrderingTerm(expression: u.id, mode: OrderingMode.asc)],
          ))
        .get();
    if (remainingUsers.isNotEmpty) {
      await changeActiveUser(remainingUsers.first.id);
    }
    return true;
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
