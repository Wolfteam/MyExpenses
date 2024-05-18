import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/utils/currency_utils.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/settings/widgets/password_bottom_sheet.dart';
import 'package:my_expenses/presentation/settings/widgets/setting_card_subtitle_text.dart';
import 'package:my_expenses/presentation/settings/widgets/settings_card.dart';
import 'package:my_expenses/presentation/settings/widgets/settings_card_title_text.dart';
import 'package:my_expenses/presentation/shared/common_dropdown_button.dart';
import 'package:my_expenses/presentation/shared/styles.dart';
import 'package:my_expenses/presentation/shared/utils/bloc_utils.dart';
import 'package:my_expenses/presentation/shared/utils/enum_utils.dart';

class OtherSettingsCard extends StatelessWidget {
  final CurrencySymbolType currencySymbolType;
  final bool currencyToTheRight;
  final bool askForPassword;
  final bool canUseFingerPrint;
  final bool askForFingerPrint;
  final bool showNotificationForRecurringTrans;

  const OtherSettingsCard({
    super.key,
    required this.currencySymbolType,
    required this.currencyToTheRight,
    required this.askForPassword,
    required this.canUseFingerPrint,
    required this.askForFingerPrint,
    required this.showNotificationForRecurringTrans,
  });

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SettingsCardTitleText(text: i18n.others, icon: const Icon(Icons.sync)),
        SettingsCardSubtitleText(text: i18n.othersSubTitle),
        Container(
          margin: const EdgeInsets.only(top: 10),
          padding: Styles.edgeInsetHorizontal16,
          child: CommonDropdownButton<CurrencySymbolType>(
            hint: i18n.currencySymbol,
            currentValue: currencySymbolType,
            values: CurrencySymbolType.values.map((e) => TranslatedEnum(e, CurrencyUtils.getCurrencySymbol(e))).toList(),
            selectedItemBuilder: (current) => _CurrencyItem(value: current.enumValue),
            onChanged: (v, _) => _currencyChanged(v, context),
          ),
        ),
        SwitchListTile(
          value: currencyToTheRight,
          title: Text(i18n.currencySymbolToRight),
          onChanged: (v) => _currencyPlacementChanged(v, context),
        ),
        SwitchListTile(
          value: askForPassword,
          title: Text(i18n.askForPassword),
          onChanged: (v) => _askForPasswordChanged(v, context),
        ),
        if (canUseFingerPrint)
          SwitchListTile(
            value: askForFingerPrint,
            title: Text(i18n.askForFingerPrint),
            onChanged: (v) => _askForFingerPrintChanged(v, context),
          ),
        SwitchListTile(
          value: showNotificationForRecurringTrans,
          title: Text(i18n.showNotificationForRecurringTrans),
          onChanged: (v) => _showNotificationForRecurringTransChanged(v, context),
        ),
      ],
    );

    return SettingsCard(child: content);
  }

  void _askForFingerPrintChanged(bool ask, BuildContext context) =>
      context.read<SettingsBloc>().add(SettingsEvent.askForFingerPrintChanged(ask: ask));

  Future<void> _askForPasswordChanged(bool ask, BuildContext context) async {
    if (!ask) {
      context.read<SettingsBloc>().add(SettingsEvent.askForPasswordChanged(ask: ask));
      return;
    }

    await showModalBottomSheet<bool>(
      context: context,
      shape: Styles.modalBottomSheetShape,
      isScrollControlled: true,
      builder: (ctx) => const PasswordBottomSheet(),
    ).then((result) {
      if (result == null) {
        return;
      }

      context.read<SettingsBloc>().add(SettingsEvent.askForPasswordChanged(ask: result));
    });
  }

  void _showNotificationForRecurringTransChanged(bool newValue, BuildContext context) =>
      context.read<SettingsBloc>().add(SettingsEvent.showNotificationForRecurringTransChanged(show: newValue));

  void _currencyChanged(CurrencySymbolType newValue, BuildContext context) {
    context.read<SettingsBloc>().add(SettingsEvent.currencyChanged(selectedCurrency: newValue));
    BlocUtils.raiseCommonBlocEvents(context, reloadCharts: true, reloadTransactions: true);
  }

  void _currencyPlacementChanged(bool newValue, BuildContext context) {
    context.read<SettingsBloc>().add(SettingsEvent.currencyPlacementChanged(placeToTheRight: newValue));
    BlocUtils.raiseCommonBlocEvents(context, reloadTransactions: true, reloadCharts: true);
  }
}

class _CurrencyItem extends StatelessWidget {
  final CurrencySymbolType value;

  const _CurrencyItem({required this.value});

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(i18n.currencySymbol),
            Container(
              margin: const EdgeInsets.only(right: 15),
              child: Text(CurrencyUtils.getCurrencySymbol(value)),
            ),
          ],
        ),
      ],
    );
  }
}
