part of 'category_icon_bloc.dart';

class CategoryIconState extends Equatable {
  final CategoryIcon selectedIcon;

  @override
  List<Object> get props => [selectedIcon];

  const CategoryIconState(this.selectedIcon);

  factory CategoryIconState.initial() {
    final cat = CategoryUtils.getByName(CategoryUtils.question);
    return CategoryIconState(cat);
  }
}
