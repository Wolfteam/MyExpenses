import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_expenses/domain/models/models.dart';

part 'credit_card_cycle_item.freezed.dart';

@freezed
sealed class CreditCardCycleItem with _$CreditCardCycleItem {
  const factory CreditCardCycleItem({
    required PaymentMethodItem paymentMethod,
    required DateTime cycleStart,
    required DateTime cycleNextClose,
    DateTime? nextDueDate,
  }) = _CreditCardCycleItem;
}
