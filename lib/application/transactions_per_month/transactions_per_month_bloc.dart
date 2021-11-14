import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/domain/services/services.dart';

part 'transactions_per_month_bloc.freezed.dart';
part 'transactions_per_month_event.dart';
part 'transactions_per_month_state.dart';

//TODO: DELETE THIS BLOC ?
class TransactionsPerMonthBloc extends Bloc<TransactionsPerMonthEvent, TransactionsPerMonthState> {
  final SettingsService _settingsService;

  TransactionsPerMonthBloc(this._settingsService) : super(const TransactionsPerMonthState.loading());

  @override
  Stream<TransactionsPerMonthState> mapEventToState(TransactionsPerMonthEvent event) async* {
    final s = event.map(
      init: (e) {
        return TransactionsPerMonthState.initial(
          incomes: e.incomes,
          expenses: e.expenses,
          total: e.total,
          month: e.month,
          transactions: e.transactions,
          currentDate: e.currentDate,
          currentLanguage: _settingsService.language,
        );
      },
    );

    yield s;
  }
}
