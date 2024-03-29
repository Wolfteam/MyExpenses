import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/presentation/shared/utils/category_utils.dart';

part 'category_icon_bloc.freezed.dart';
part 'category_icon_event.dart';
part 'category_icon_state.dart';

class CategoryIconBloc extends Bloc<CategoryIconEvent, CategoryIconState> {
  CategoryIconBloc() : super(CategoryIconState.initial(selectedIcon: CategoryUtils.getByName(CategoryUtils.question)));

  @override
  Stream<CategoryIconState> mapEventToState(
    CategoryIconEvent event,
  ) async* {
    final s = event.map(
      selectionChanged: (e) => CategoryIconState.initial(selectedIcon: e.selectedIcon),
    );
    yield s;
  }
}
