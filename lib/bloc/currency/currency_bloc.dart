import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../common/utils/currency_utils.dart';
import '../../services/settings_service.dart';

part 'currency_event.dart';
part 'currency_state.dart';

class CurrencyBloc extends Bloc<CurrencyEvent, CurrencyState> {
  final SettingsService _settingsService;

  CurrencyBloc(this._settingsService) : super(CurrencyInitial());

  @override
  Stream<CurrencyState> mapEventToState(
    CurrencyEvent event,
  ) async* {
    //Nothing...
  }

  String format(
    double amount, {
    bool showSymbol = true,
  }) {
    if (showSymbol) {
      return CurrencyUtils.formatNumber(
        amount,
        symbol: CurrencyUtils.getCurrencySymbol(
          _settingsService.currencySymbol,
        ),
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
