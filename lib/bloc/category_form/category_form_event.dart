part of 'category_form_bloc.dart';

@freezed
class CategoryFormEvent with _$CategoryFormEvent {
  const factory CategoryFormEvent.addCategory() = _AddCategory;

  const factory CategoryFormEvent.editCategory({
    required CategoryItem category,
  }) = _EditCategory;

  const factory CategoryFormEvent.nameChanged({
    required String name,
  }) = _NameChanged;

  const factory CategoryFormEvent.typeChanged({
    required TransactionType selectedType,
  }) = _TypeChanged;

  const factory CategoryFormEvent.iconChanged({
    required IconData selectedIcon,
  }) = _IconChanged;

  const factory CategoryFormEvent.iconColorChanged({
    required Color iconColor,
  }) = _IconColorChanged;

  const factory CategoryFormEvent.deleteCategory() = _DeleteCategory;

  const factory CategoryFormEvent.formSubmitted() = _FormSubmitted;

  const factory CategoryFormEvent.formClosed() = _FormClosed;
}
