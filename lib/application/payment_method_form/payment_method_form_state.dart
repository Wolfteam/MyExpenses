part of 'payment_method_form_bloc.dart';

@freezed
sealed class PaymentMethodFormState with _$PaymentMethodFormState {
  const factory PaymentMethodFormState.initial({
    @Default('') String name,
    @Default(PaymentMethodType.cash) PaymentMethodType type,
    @Default('') String statementDayText,
    @Default('') String dueDayText,
    @Default('') String creditLimitText,
    @Default(false) bool isNameDirty,
    @Default(false) bool isStatementDayDirty,
    @Default(false) bool isDueDayDirty,
    @Default(false) bool isCreditLimitDirty,
    @Default(true) bool isNameValid,
    @Default(true) bool isStatementDayValid,
    @Default(true) bool isDueDayValid,
    @Default(true) bool isCreditLimitValid,
    @Default(false) bool isDuplicate,
    @Default(false) bool submitted,
    IconData? icon,
    Color? iconColor,
  }) = PaymentMethodFormStateInitial;
}
