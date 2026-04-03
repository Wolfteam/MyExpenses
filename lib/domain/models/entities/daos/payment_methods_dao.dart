import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/models/drive.dart' as drive;
import 'package:my_expenses/domain/models/models.dart';

abstract class PaymentMethodsDao {
  Future<List<PaymentMethodItem>> getAll(int? userId, {bool includeArchived = false});

  Future<PaymentMethodItem> save(int? userId, PaymentMethodItem method);

  Future<void> archive(int id, {required bool isArchived});

  Future<void> deleteAll(int? userId);

  Future<void> updateSortOrders(int? userId, List<int> orderedIds);

  // Drive sync helpers
  Future<List<drive.PaymentMethod>> getAllPaymentMethodsToSync(int? userId);

  Future<void> syncDownDelete(int? userId, List<drive.PaymentMethod> existing);

  Future<void> syncUpDelete(int? userId);

  Future<void> syncDownCreate(int? userId, List<drive.PaymentMethod> existing);

  Future<void> syncDownUpdate(int? userId, List<drive.PaymentMethod> existing);

  // Hash mapping helpers
  Future<int?> getIdByCreatedHash(String createdHash);

  Future<String?> getCreatedHashById(int id);

  Future<void> updateAllLocalStatus(LocalStatusType newValue);
}
