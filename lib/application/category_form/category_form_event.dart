part of 'category_form_bloc.dart';

@freezed
sealed class CategoryFormEvent with _$CategoryFormEvent {
  const factory CategoryFormEvent.addCategory() = CategoryFormEventAddCategory;

  const factory CategoryFormEvent.editCategory({required CategoryItem category}) = CategoryFormEventEditCategory;

  const factory CategoryFormEvent.nameChanged({required String name}) = CategoryFormEventNameChanged;

  const factory CategoryFormEvent.typeChanged({required TransactionType selectedType}) = CategoryFormEventTypeChanged;

  const factory CategoryFormEvent.iconChanged({required IconData selectedIcon}) = CategoryFormEventIconChanged;

  const factory CategoryFormEvent.iconColorChanged({required Color iconColor}) = CategoryFormEventIconColorChanged;

  const factory CategoryFormEvent.deleteCategory() = CategoryFormEventDeleteCategory;

  const factory CategoryFormEvent.formSubmitted() = CategoryFormEventFormSubmitted;
}
