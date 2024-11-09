import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/models/models.dart';

part 'transactions_last_7_days_bloc.freezed.dart';
part 'transactions_last_7_days_event.dart';
part 'transactions_last_7_days_state.dart';

//TODO: DELETE THIS BLOC ?
class TransactionsLast7DaysBloc extends Bloc<TransactionsLast7DaysEvent, TransactionsLast7DaysState> {
  TransactionsLast7DaysBloc() : super(const TransactionsLast7DaysState.loading());

  _InitialState get currentState => state as _InitialState;

  @override
  Stream<TransactionsLast7DaysState> mapEventToState(TransactionsLast7DaysEvent event) async* {
    final s = event.map(
      init: (e) => _transactionsLoaded(e.selectedType, e.incomes, e.expenses, e.showLast7Days),
    );

    yield s;
  }

  TransactionsLast7DaysState _transactionsLoaded(
    TransactionType? selectedType,
    List<TransactionsSummaryPerDay> incomes,
    List<TransactionsSummaryPerDay> expenses,
    bool showLast7Days,
  ) {
    if (state is! _InitialState) {
      return TransactionsLast7DaysState.initial(
        showLast7Days: showLast7Days,
        incomes: incomes,
        expenses: expenses,
      );
    }

    return currentState.copyWith.call(
      incomes: incomes,
      expenses: expenses,
      showLast7Days: showLast7Days,
    );
  }
}
