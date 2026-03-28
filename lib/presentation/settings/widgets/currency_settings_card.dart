import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/utils/currency_utils.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/settings/widgets/setting_card_subtitle_text.dart';
import 'package:my_expenses/presentation/settings/widgets/settings_card.dart';
import 'package:my_expenses/presentation/settings/widgets/settings_card_title_text.dart';
import 'package:my_expenses/presentation/shared/common_dropdown_button.dart';
import 'package:my_expenses/presentation/shared/styles.dart';
import 'package:my_expenses/presentation/shared/utils/bloc_utils.dart';
import 'package:my_expenses/presentation/shared/utils/enum_utils.dart';

class CurrencySettingsCard extends StatelessWidget {
  final CurrencySymbolType currencySymbolType;
  final bool currencyToTheRight;

  const CurrencySettingsCard({
    super.key,
    required this.currencySymbolType,
    required this.currencyToTheRight,
  });

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    return SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SettingsCardTitleText(
            text: i18n.currencyCardTitle,
            icon: const Icon(Icons.attach_money),
          ),
          SettingsCardSubtitleText(text: i18n.currencyCardSubTitle),
          Container(
            margin: const EdgeInsets.only(top: 10),
            padding: Styles.edgeInsetHorizontal16,
            child: CommonDropdownButton<CurrencySymbolType>(
              hint: i18n.currencySymbol,
              currentValue: currencySymbolType,
              values: CurrencySymbolType.values
                  .map((e) => TranslatedEnum(e, CurrencyUtils.getCurrencySymbol(e)))
                  .toList(),
              selectedItemBuilder: (current) => _CurrencyItem(value: current.enumValue),
              onChanged: (v, _) => _currencyChanged(v, context),
            ),
          ),
          SwitchListTile(
            value: currencyToTheRight,
            title: Text(i18n.currencySymbolToRight),
            onChanged: (v) => _currencyPlacementChanged(v, context),
          ),
        ],
      ),
    );
  }

  void _currencyChanged(CurrencySymbolType newValue, BuildContext context) {
    context.read<SettingsBloc>().add(SettingsEvent.currencyChanged(selectedCurrency: newValue));
    BlocUtils.raiseCommonBlocEvents(context, reloadTransactions: true);
  }

  void _currencyPlacementChanged(bool newValue, BuildContext context) {
    context.read<SettingsBloc>().add(SettingsEvent.currencyPlacementChanged(placeToTheRight: newValue));
    BlocUtils.raiseCommonBlocEvents(context, reloadTransactions: true);
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
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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
