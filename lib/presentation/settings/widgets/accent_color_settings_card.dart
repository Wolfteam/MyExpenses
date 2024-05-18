import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/extensions/string_extensions.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/settings/widgets/setting_card_subtitle_text.dart';
import 'package:my_expenses/presentation/settings/widgets/settings_card.dart';
import 'package:my_expenses/presentation/settings/widgets/settings_card_title_text.dart';
import 'package:my_expenses/presentation/shared/common_dropdown_button.dart';
import 'package:my_expenses/presentation/shared/extensions/app_theme_type_extensions.dart';
import 'package:my_expenses/presentation/shared/styles.dart';
import 'package:my_expenses/presentation/shared/utils/enum_utils.dart';

class AccentColorSettingsCard extends StatelessWidget {
  final AppAccentColorType accentColorType;

  const AccentColorSettingsCard({super.key, required this.accentColorType});

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);

    return SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SettingsCardTitleText(text: i18n.accentColor, icon: const Icon(Icons.colorize)),
          SettingsCardSubtitleText(text: i18n.chooseAccentColor),
          Padding(
            padding: Styles.edgeInsetHorizontal16,
            child: CommonDropdownButton<AppAccentColorType>(
              hint: i18n.chooseAccentColor,
              currentValue: accentColorType,
              values: EnumUtils.getTranslatedAndSortedEnum<AppAccentColorType>(AppAccentColorType.values, (val, _) => _getAccentColorName(val)),
              onChanged: _accentColorChanged,
              leadingIconBuilder: (val) => Container(
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: val.getAccentColor(),
                ),
                width: 20,
                height: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _accentColorChanged(AppAccentColorType newValue, BuildContext context) {
    context.read<SettingsBloc>().add(SettingsEvent.appAccentColorChanged(selectedAccentColor: newValue));
    context.read<AppBloc>().add(AppEvent.accentColorChanged(accentColor: newValue));
  }

  String _getAccentColorName(AppAccentColorType color) {
    final name = color.name;
    final words = name.split(RegExp('(?<=[a-z])(?=[A-Z])'));
    return words.map((e) => e.toCapitalized()).join(' ');
  }
}
