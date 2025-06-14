part of 'category_icon_bloc.dart';

@freezed
sealed class CategoryIconEvent with _$CategoryIconEvent {
  const factory CategoryIconEvent.selectionChanged({required CategoryIcon selectedIcon}) = CategoryIconEventSelectionChanged;
}
