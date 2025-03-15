part of 'category_icon_bloc.dart';

@freezed
sealed class CategoryIconState with _$CategoryIconState {
  const factory CategoryIconState.initial({required CategoryIcon selectedIcon}) = CategoryIconStateInitialState;
}
