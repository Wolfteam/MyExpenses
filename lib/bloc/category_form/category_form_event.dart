part of 'category_form_bloc.dart';

abstract class CategoryFormEvent extends Equatable {
  @override
  List<Object> get props => [];

  const CategoryFormEvent();
}

class AddCategory extends CategoryFormEvent {
  @override
  List<Object> get props => [];
}

class EditCategory extends CategoryFormEvent {
  final CategoryItem category;

  const EditCategory(this.category);

  @override
  List<Object> get props => [category];
}

class NameChanged extends CategoryFormEvent {
  final String name;

  const NameChanged(this.name);

  @override
  List<Object> get props => [name];
}

class TypeChanged extends CategoryFormEvent {
  final TransactionType selectedType;

  const TypeChanged(this.selectedType);

  @override
  List<Object> get props => [selectedType];
}

class IconChanged extends CategoryFormEvent {
  final IconData selectedIcon;

  const IconChanged(this.selectedIcon);

  @override
  List<Object> get props => [selectedIcon];
}

class IconColorChanged extends CategoryFormEvent {
  final Color iconColor;

  const IconColorChanged(this.iconColor);

  @override
  List<Object> get props => [iconColor];
}

class DeleteCategory extends CategoryFormEvent {}

class FormSubmitted extends CategoryFormEvent {}

class FormClosed extends CategoryFormEvent {}
