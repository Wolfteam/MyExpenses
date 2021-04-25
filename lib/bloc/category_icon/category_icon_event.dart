part of 'category_icon_bloc.dart';

@freezed
class CategoryIconEvent with _$CategoryIconEvent {
  const factory CategoryIconEvent.selectionChanged({
    required CategoryIcon selectedIcon,
  }) = _SelectionChanged;
}
