part of 'category_form_bloc.dart';

@freezed
sealed class CategoryState with _$CategoryState {
  const factory CategoryState.loading() = CategoryStateLoadingState;

  const factory CategoryState.loaded({
    required int id,
    required String name,
    required bool isNameValid,
    required bool isNameDirty,
    required TransactionType type,
    required bool isTypeValid,
    required IconData icon,
    required bool isIconValid,
    required Color iconColor,
    required bool isFormValid,
    required bool isNew,
    @Default(false) bool errorOccurred,
    @Default(false) bool categoryCantBeDeleted,
    @Default(false) bool saved,
    @Default(false) bool deleted,
  }) = CategoryStateLoadedState;
}
