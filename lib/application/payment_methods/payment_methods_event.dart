part of 'payment_methods_bloc.dart';

@freezed
sealed class PaymentMethodsEvent with _$PaymentMethodsEvent {
  const factory PaymentMethodsEvent.load({@Default(false) bool includeArchived}) = PaymentMethodsEventLoad;

  const factory PaymentMethodsEvent.createOrUpdate({required PaymentMethodItem method}) = PaymentMethodsEventCreateOrUpdate;

  const factory PaymentMethodsEvent.archive({required int id, required bool isArchived}) = PaymentMethodsEventArchive;

  const factory PaymentMethodsEvent.reorder({required List<int> orderedIds}) = PaymentMethodsEventReorder;
}
