import 'package:drift/drift.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/models/drive.dart' as drive;
import 'package:my_expenses/domain/models/entities.dart';
import 'package:my_expenses/domain/models/entities/converters/db_converters.dart';
import 'package:my_expenses/domain/models/entities/daos/payment_methods_dao.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/infrastructure/db/database.dart';

part 'payment_methods_dao_impl.g.dart';

@DriftAccessor(tables: [PaymentMethods])
class PaymentMethodsDaoImpl extends DatabaseAccessor<AppDatabase> with _$PaymentMethodsDaoImplMixin implements PaymentMethodsDao {
  PaymentMethodsDaoImpl(super.db);

  @override
  Future<List<PaymentMethodItem>> getAll(int? userId, {bool includeArchived = false}) async {
    final q = select(paymentMethods)
      ..where(
        (t) => t.localStatus.equals(LocalStatusType.deleted.index).not(),
      )
      ..orderBy([
        (t) => OrderingTerm(expression: t.sortOrder),
        (t) => OrderingTerm(expression: t.name),
      ]);

    if (!includeArchived) {
      q.where((t) => t.isArchived.equals(false));
    }

    if (userId == null) {
      q.where((t) => t.userId.isNull());
    } else {
      q.where((t) => t.userId.equals(userId));
    }

    final rows = await q.get();
    return rows
        .map(
          (r) => PaymentMethodItem(
            id: r.id,
            userId: r.userId,
            name: r.name,
            type: r.type,
            icon: r.icon,
            iconColor: r.iconColor,
            statementCloseDay: r.statementCloseDay,
            paymentDueDay: r.paymentDueDay,
            creditLimitMinor: r.creditLimitMinor,
            isArchived: r.isArchived,
            sortOrder: r.sortOrder,
          ),
        )
        .toList();
  }

  @override
  Future<PaymentMethodItem> save(int? userId, PaymentMethodItem method) async {
    final now = DateTime.now();
    int id = method.id;

    if (method.id <= 0) {
      id = await into(paymentMethods).insert(
        PaymentMethodsCompanion.insert(
          localStatus: LocalStatusType.created,
          userId: Value(userId),
          name: method.name,
          type: method.type,
          icon: Value(method.icon),
          iconColor: Value(method.iconColor),
          statementCloseDay: Value(method.statementCloseDay),
          paymentDueDay: Value(method.paymentDueDay),
          creditLimitMinor: Value(method.creditLimitMinor),
          isArchived: const Value(false),
          sortOrder: Value(method.sortOrder),
          createdAt: now,
          createdBy: createdBy,
          createdHash: createdHash([
            method.name,
            const PaymentTypeConverter().toSql(method.type),
            const IconDataConverter().toSql(method.icon) ?? '',
            const ColorConverter().toSql(method.iconColor),
            method.sortOrder,
            now,
            createdBy,
          ]),
        ),
      );
    } else {
      final current = await (select(paymentMethods)..where((t) => t.id.equals(method.id))).getSingle();
      await (update(paymentMethods)..where((t) => t.id.equals(method.id))).write(
        PaymentMethodsCompanion(
          name: Value(method.name),
          type: Value(method.type),
          icon: Value(method.icon),
          iconColor: Value(method.iconColor),
          statementCloseDay: Value(method.statementCloseDay),
          paymentDueDay: Value(method.paymentDueDay),
          creditLimitMinor: Value(method.creditLimitMinor),
          updatedAt: Value(now),
          updatedBy: const Value(createdBy),
          userId: Value(userId),
          localStatus: Value(current.localStatus == LocalStatusType.created ? LocalStatusType.created : LocalStatusType.updated),
        ),
      );
    }

    final row = await (select(paymentMethods)..where((t) => t.id.equals(id))).getSingle();
    return PaymentMethodItem(
      id: row.id,
      userId: row.userId,
      name: row.name,
      type: row.type,
      icon: row.icon,
      iconColor: row.iconColor,
      statementCloseDay: row.statementCloseDay,
      paymentDueDay: row.paymentDueDay,
      creditLimitMinor: row.creditLimitMinor,
      isArchived: row.isArchived,
      sortOrder: row.sortOrder,
    );
  }

  @override
  Future<void> archive(int id, {required bool isArchived}) async {
    final current = await (select(paymentMethods)..where((t) => t.id.equals(id))).getSingle();
    await (update(paymentMethods)..where((t) => t.id.equals(id))).write(
      PaymentMethodsCompanion(
        isArchived: Value(isArchived),
        updatedAt: Value(DateTime.now()),
        updatedBy: const Value(createdBy),
        localStatus: Value(current.localStatus == LocalStatusType.created ? LocalStatusType.created : LocalStatusType.updated),
      ),
    );
  }

  @override
  Future<void> deleteAll(int? userId) async {
    var query = delete(paymentMethods);
    if (userId != null) {
      query = (query..where((t) => t.userId.equals(userId)));
    } else {
      query = (query..where((t) => t.userId.isNull()));
    }

    await query.go();
  }

  @override
  Future<void> updateSortOrders(int? userId, List<int> orderedIds) async {
    await batch((b) {
      for (int i = 0; i < orderedIds.length; i++) {
        final update = PaymentMethodsCompanion(
          sortOrder: Value(i),
          updatedAt: Value(DateTime.now()),
          updatedBy: const Value(createdBy),
        );
        if (userId != null) {
          b.update<PaymentMethods, PaymentMethod>(
            paymentMethods,
            update,
            where: (t) => t.id.equals(orderedIds[i]) & t.userId.equals(userId),
          );
        } else {
          b.update<PaymentMethods, PaymentMethod>(
            paymentMethods,
            update,
            where: (t) => t.id.equals(orderedIds[i]) & t.userId.isNull(),
          );
        }
      }
    });
  }

  // ========= Drive sync helpers =========
  @override
  Future<List<drive.PaymentMethod>> getAllPaymentMethodsToSync(int? userId) async {
    var query = select(paymentMethods)
      ..where((t) => t.localStatus.equals(LocalStatusType.deleted.index).not())
      ..orderBy([(t) => OrderingTerm(expression: t.id)]);

    if (userId == null) {
      query = query..where((t) => t.userId.isNull());
    } else {
      query = query..where((t) => t.userId.equals(userId));
    }

    final rows = await query.get();

    return rows
        .map(
          (r) => drive.PaymentMethod(
            name: r.name,
            type: r.type,
            icon: const IconDataConverter().toSql(r.icon),
            iconColor: const ColorConverter().toSql(r.iconColor),
            statementCloseDay: r.statementCloseDay,
            paymentDueDay: r.paymentDueDay,
            creditLimitMinor: r.creditLimitMinor,
            isArchived: r.isArchived,
            sortOrder: r.sortOrder,
            createdAt: r.createdAt,
            createdBy: r.createdBy,
            createdHash: r.createdHash,
            updatedAt: r.updatedAt,
            updatedBy: r.updatedBy,
          ),
        )
        .toList();
  }

  @override
  Future<void> syncDownDelete(int? userId, List<drive.PaymentMethod> existing) async {
    var query = select(paymentMethods)..where((t) => t.localStatus.equals(LocalStatusType.created.index).not());

    if (userId == null) {
      query = query..where((t) => t.userId.isNull());
    } else {
      query = query..where((t) => t.userId.equals(userId));
    }

    final local = await query.get();
    final downloadedHashes = existing.map((e) => e.createdHash).toList();
    final idsToDelete = local.where((m) => !downloadedHashes.contains(m.createdHash)).map((m) => m.id).toList();

    if (idsToDelete.isEmpty) {
      return;
    }
    await batch((b) {
      b.deleteWhere<PaymentMethods, PaymentMethod>(paymentMethods, (t) => t.id.isIn(idsToDelete));
    });
  }

  @override
  Future<void> syncUpDelete(int? userId) async {
    var query = delete(paymentMethods)..where((t) => t.localStatus.equals(LocalStatusType.deleted.index));
    if (userId == null) {
      query = query..where((t) => t.userId.isNull());
    } else {
      query = query..where((t) => t.userId.equals(userId));
    }

    await query.go();
  }

  @override
  Future<void> syncDownCreate(int? userId, List<drive.PaymentMethod> existing) async {
    var query = select(paymentMethods);
    if (userId == null) {
      query = query..where((t) => t.userId.isNull());
    } else {
      query = query..where((t) => t.userId.equals(userId));
    }

    final localHashes = await query.map((r) => r.createdHash).get();
    final toCreate = existing
        .where((e) => !localHashes.contains(e.createdHash))
        .map(
          (e) => PaymentMethodsCompanion.insert(
            localStatus: LocalStatusType.nothing,
            userId: Value(userId),
            name: e.name,
            type: e.type,
            icon: Value(const IconDataConverter().fromSql(e.icon)),
            iconColor: Value(const ColorConverter().fromSql(e.iconColor)),
            statementCloseDay: Value(e.statementCloseDay),
            paymentDueDay: Value(e.paymentDueDay),
            creditLimitMinor: Value(e.creditLimitMinor),
            isArchived: Value(e.isArchived),
            sortOrder: Value(e.sortOrder),
            createdAt: e.createdAt,
            createdBy: e.createdBy,
            createdHash: e.createdHash,
            updatedAt: Value(e.updatedAt),
            updatedBy: Value(e.updatedBy),
          ),
        )
        .toList();

    if (toCreate.isEmpty) return;
    await batch((b) {
      b.insertAll(paymentMethods, toCreate);
    });
  }

  @override
  Future<void> syncDownUpdate(int? userId, List<drive.PaymentMethod> existing) async {
    final existingToUse = existing.where((e) => e.updatedAt != null).toList();
    if (existingToUse.isEmpty) return;
    final hashes = existingToUse.map((e) => e.createdHash).toList();
    var query = select(paymentMethods)
      ..where((t) => t.createdHash.isIn(hashes) & t.localStatus.equals(LocalStatusType.deleted.index).not());
    if (userId == null) {
      query = query..where((t) => t.userId.isNull());
    } else {
      query = query..where((t) => t.userId.equals(userId));
    }

    final local = await query.get();
    final toUpdate = <PaymentMethod>[];
    for (final m in local) {
      final remote = existingToUse.singleWhere((e) => e.createdHash == m.createdHash);
      if (m.updatedAt == null || (remote.updatedAt != null && m.updatedAt!.isBefore(remote.updatedAt!))) {
        toUpdate.add(m);
      }
    }
    if (toUpdate.isEmpty) return;
    await batch((b) {
      for (final m in toUpdate) {
        final remote = existingToUse.singleWhere((e) => e.createdHash == m.createdHash);
        b.update<PaymentMethods, PaymentMethod>(
          paymentMethods,
          PaymentMethodsCompanion(
            localStatus: const Value(LocalStatusType.nothing),
            name: Value(remote.name),
            type: Value(remote.type),
            icon: Value(const IconDataConverter().fromSql(remote.icon)),
            iconColor: Value(const ColorConverter().fromSql(remote.iconColor)),
            statementCloseDay: Value(remote.statementCloseDay),
            paymentDueDay: Value(remote.paymentDueDay),
            creditLimitMinor: Value(remote.creditLimitMinor),
            isArchived: Value(remote.isArchived),
            sortOrder: Value(remote.sortOrder),
            updatedAt: Value(remote.updatedAt),
            updatedBy: Value(remote.updatedBy),
          ),
          where: (t) => t.id.equals(m.id),
        );
      }
    });
  }

  @override
  Future<int?> getIdByCreatedHash(String createdHash) async {
    final row = await (select(paymentMethods)..where((t) => t.createdHash.equals(createdHash))).getSingleOrNull();
    return row?.id;
  }

  @override
  Future<String?> getCreatedHashById(int id) async {
    final row = await (select(paymentMethods)..where((t) => t.id.equals(id))).getSingleOrNull();
    return row?.createdHash;
  }

  @override
  Future<void> updateAllLocalStatus(LocalStatusType newValue) {
    return update(paymentMethods).write(
      PaymentMethodsCompanion(updatedAt: Value(DateTime.now()), updatedBy: const Value(createdBy), localStatus: Value(newValue)),
    );
  }
}
