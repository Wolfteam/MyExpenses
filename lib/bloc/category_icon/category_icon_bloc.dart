import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../common/utils/category_utils.dart';
import '../../models/category_icon.dart';

part 'category_icon_event.dart';
part 'category_icon_state.dart';

class CategoryIconBloc extends Bloc<CategoryIconEvent, CategoryIconState> {
  @override
  CategoryIconState get initialState => CategoryIconState.initial();

  @override
  Stream<CategoryIconState> mapEventToState(
    CategoryIconEvent event,
  ) async* {
    if (event is IconSelectionChanged) {
      yield CategoryIconState(event.selectedIcon);
    }
  }
}
