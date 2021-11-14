import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'main_tab_bloc.freezed.dart';
part 'main_tab_event.dart';
part 'main_tab_state.dart';

class MainTabBloc extends Bloc<MainTabEvent, MainTabState> {
  MainTabBloc() : super(const MainTabState.loading());

  @override
  Stream<MainTabState> mapEventToState(MainTabEvent event) async* {
    if (event is _Init) {
      yield const MainTabState.initial();
    }
  }
}
