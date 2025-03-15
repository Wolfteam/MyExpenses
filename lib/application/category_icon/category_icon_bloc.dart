import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/presentation/shared/utils/category_utils.dart';

part 'category_icon_bloc.freezed.dart';
part 'category_icon_event.dart';
part 'category_icon_state.dart';

class CategoryIconBloc extends Bloc<CategoryIconEvent, CategoryIconState> {
  CategoryIconBloc() : super(CategoryIconState.initial(selectedIcon: CategoryUtils.getByName(CategoryUtils.question))) {
    on<CategoryIconEventSelectionChanged>((event, emit) {
      final s = CategoryIconState.initial(selectedIcon: event.selectedIcon);
      emit(s);
    });
  }
}
