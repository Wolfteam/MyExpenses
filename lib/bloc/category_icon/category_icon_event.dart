part of 'category_icon_bloc.dart';

abstract class CategoryIconEvent extends Equatable {
  const CategoryIconEvent();
}

class IconSelectionChanged extends CategoryIconEvent {
  final CategoryIcon selectedIcon;

  @override
  List<Object> get props => [selectedIcon];

  const IconSelectionChanged(this.selectedIcon);
}
