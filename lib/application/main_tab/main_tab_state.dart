part of 'main_tab_bloc.dart';

@freezed
class MainTabState with _$MainTabState {
  const factory MainTabState.loading() = _LoadingState;

  const factory MainTabState.initial() = _InitialState;
}
