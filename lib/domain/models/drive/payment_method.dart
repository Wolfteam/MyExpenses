import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_expenses/domain/enums/enums.dart';

part 'payment_method.freezed.dart';
part 'payment_method.g.dart';

@freezed
sealed class PaymentMethod with _$PaymentMethod {
  const factory PaymentMethod({
    required String name,
    required PaymentMethodType type,
    String? icon,
    int? iconColor,
    // Credit card statement cycle metadata
    int? statementCloseDay,
    int? paymentDueDay,
    int? creditLimitMinor,
    // Lifecycle & sorting
    @Default(false) bool isArchived,
    @Default(0) int sortOrder,
    // Sync metadata
    required DateTime createdAt,
    required String createdBy,
    required String createdHash,
    DateTime? updatedAt,
    String? updatedBy,
  }) = _PaymentMethod;

  static const requiredJsonFields = [
    'name',
    'type',
    'createdAt',
    'createdBy',
    'createdHash',
  ];

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => _$PaymentMethodFromJson(json);
}
