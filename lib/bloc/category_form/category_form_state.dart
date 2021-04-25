part of 'category_form_bloc.dart';

@freezed
class CategoryState with _$CategoryState {
  static bool isFormValid(_InitialState state) => state.isNameValid && state.isTypeValid && state.isIconValid;

  static bool newCategory(_InitialState state) => state.id <= 0;

  const factory CategoryState.initial({
    required int id,
    required String name,
    required bool isNameValid,
    required bool isNameDirty,
    required TransactionType type,
    required bool isTypeValid,
    required IconData icon,
    required bool isIconValid,
    required Color iconColor,
    @Default(false) bool errorOccurred,
    @Default(false) bool categoryCantBeDeleted,
  }) = _InitialState;

  const factory CategoryState.saved({
    required CategoryItem category,
  }) = _SavedState;

  const factory CategoryState.deleted({
    required CategoryItem category,
  }) = _DeletedState;

// factory CategoryFormState.initial() {
//   final cat = CategoryUtils.getByName(CategoryUtils.question);
//   return CategoryFormState(
//     id: 0,
//     name: '',
//     isNameValid: false,
//     isNameDirty: false,
//     type: TransactionType.incomes,
//     isTypeValid: true,
//     icon: cat.icon.icon,
//     isIconValid: true,
//     iconColor: Colors.white,
//   );
// }

// CategoryItem buildCategoryItem() {
//   return CategoryItem(
//     icon: icon,
//     iconColor: iconColor,
//     id: id,
//     isAnIncome: type == TransactionType.incomes,
//     name: name.trim(),
//   );
// }
}
