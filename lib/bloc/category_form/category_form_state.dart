part of 'category_form_bloc.dart';

abstract class CategoryState extends Equatable {
  @override
  List<Object> get props => [];

  const CategoryState();
}

class CategoryFormState extends CategoryState {
  final int id;

  final String name;
  final bool isNameValid;
  final bool isNameDirty;

  final TransactionType type;
  final bool isTypeValid;

  final IconData icon;
  final bool isIconValid;

  final Color iconColor;

  final bool errorOccurred;

  bool get isFormValid => isNameValid && isTypeValid && isIconValid;
  bool get newCategory => id <= 0;

  @override
  List<Object> get props => [
        id,
        name,
        isNameValid,
        isNameDirty,
        type,
        isTypeValid,
        icon,
        isIconValid,
        iconColor,
        errorOccurred,
      ];

  const CategoryFormState({
    @required this.id,
    @required this.name,
    @required this.isNameValid,
    @required this.isNameDirty,
    @required this.type,
    @required this.isTypeValid,
    @required this.icon,
    @required this.isIconValid,
    @required this.iconColor,
    this.errorOccurred = false,
  });

  factory CategoryFormState.initial() {
    final cat = CategoryUtils.getByName(CategoryUtils.question);
    return CategoryFormState(
      id: 0,
      name: '',
      isNameValid: false,
      isNameDirty: false,
      type: TransactionType.incomes,
      isTypeValid: true,
      icon: cat.icon.icon,
      isIconValid: true,
      iconColor: Colors.white,
    );
  }

  CategoryFormState copyWith({
    int id,
    String name,
    bool isNameValid,
    bool isNameDirty,
    TransactionType type,
    bool isTypeValid,
    IconData icon,
    bool isIconValid,
    Color iconColor,
    bool errorOccurred,
  }) {
    return CategoryFormState(
        id: id ?? this.id,
        name: name ?? this.name,
        isNameValid: isNameValid ?? this.isNameValid,
        isNameDirty: isNameDirty ?? this.isNameDirty,
        type: type ?? this.type,
        isTypeValid: isTypeValid ?? this.isTypeValid,
        icon: icon ?? this.icon,
        isIconValid: isIconValid ?? this.isIconValid,
        iconColor: iconColor ?? this.iconColor,
        errorOccurred: errorOccurred ?? this.errorOccurred);
  }

  CategoryItem buildCategoryItem() {
    return CategoryItem(
      icon: icon,
      iconColor: iconColor,
      id: id,
      isAnIncome: type == TransactionType.incomes,
      name: name,
    );
  }
}

class CategorySavedOrDeletedState extends CategoryState {
  final CategoryItem category;

  @override
  List<Object> get props => [category];

  const CategorySavedOrDeletedState(this.category);
}

class CategorySavedState extends CategorySavedOrDeletedState {
  const CategorySavedState(CategoryItem category) : super(category);
}

class CategoryDeletedState extends CategorySavedOrDeletedState {
  const CategoryDeletedState(CategoryItem category) : super(category);
}
