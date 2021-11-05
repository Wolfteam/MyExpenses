import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../common/enums/app_language_type.dart';
import '../../models/transactions_summary_per_month.dart';
import '../../services/settings_service.dart';

part 'transactions_per_month_bloc.freezed.dart';
part 'transactions_per_month_event.dart';
part 'transactions_per_month_state.dart';

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
