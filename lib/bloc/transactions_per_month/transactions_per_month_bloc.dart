import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../common/enums/app_language_type.dart';
import '../../models/transactions_summary_per_month.dart';
import '../../services/settings_service.dart';

part 'transactions_per_month_bloc.freezed.dart';
part 'transactions_per_month_state.dart';

class TransactionsPerMonthBloc extends Cubit<TransactionsPerMonthState> {
  final SettingsService _settingsService;

  TransactionsPerMonthBloc(this._settingsService) : super(TransactionsPerMonthState.initial());

  void transactionsLoaded(
    double incomes,
    double expenses,
    double total,
    String month,
    List<TransactionsSummaryPerMonth> transactions,
    DateTime currentDate,
  ) {
    emit(TransactionsPerMonthState.loaded(
      incomes: incomes,
      expenses: expenses,
      total: total,
      month: month,
      transactions: transactions,
      currentDate: currentDate,
      currentLanguage: _settingsService.language,
    ));
  }
}
