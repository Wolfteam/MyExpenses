part of 'main_tab_bloc.dart';

@freezed
sealed class MainTabState with _$MainTabState {
  const factory MainTabState.loading() = MainTabStateLoadingState;

  const factory MainTabState.initial() = MainTabStateInitialState;
}
