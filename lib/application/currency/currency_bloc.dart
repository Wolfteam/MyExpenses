import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_expenses/domain/services/services.dart';
import 'package:my_expenses/domain/utils/currency_utils.dart';

part 'currency_bloc.freezed.dart';
part 'currency_event.dart';
part 'currency_state.dart';

//TODO: MAYBE REMOVE THIS BLOC AND CONVERT IT TO A SERVICE ?
class CurrencyBloc extends Bloc<CurrencyEvent, CurrencyState> {
  final SettingsService _settingsService;

  CurrencyBloc(this._settingsService) : super(const CurrencyState.initial());

  @override
  Stream<CurrencyState> mapEventToState(
    CurrencyEvent event,
  ) async* {
    //Nothing...
  }

  String format(double amount, {bool showSymbol = true}) {
    if (showSymbol) {
      return CurrencyUtils.formatNumber(
        amount,
        symbol: CurrencyUtils.getCurrencySymbol(_settingsService.currencySymbol),
        symbolToTheRight: _settingsService.currencyToTheRight,
      );
    }

    return CurrencyUtils.formatNumber(
      amount,
      symbol: '',
      symbolSeparator: '',
      symbolToTheRight: _settingsService.currencyToTheRight,
    );
  }
}
