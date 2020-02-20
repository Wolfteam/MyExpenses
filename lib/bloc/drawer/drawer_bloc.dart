import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../common/enums/app_drawer_item_type.dart';

part 'drawer_event.dart';
part 'drawer_state.dart';

class DrawerBloc extends Bloc<DrawerEvent, DrawerState> {
  @override
  DrawerState get initialState =>
      DrawerState.initial(AppDrawerItemType.transactions);

  @override
  Stream<DrawerState> mapEventToState(
    DrawerEvent event,
  ) async* {
    if (event is DrawerItemSelectionChanged) {
      yield DrawerState.initial(event.selectedPage);
    }
  }
}
