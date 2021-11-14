import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/settings/widgets/setting_card_subtitle_text.dart';
import 'package:my_expenses/presentation/settings/widgets/settings_card.dart';
import 'package:my_expenses/presentation/settings/widgets/settings_card_title_text.dart';
import 'package:my_expenses/presentation/shared/extensions/app_theme_type_extensions.dart';

class AccentColorSettingsCard extends StatelessWidget {
  final AppAccentColorType accentColorType;

  const AccentColorSettingsCard({Key? key, required this.accentColorType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);

    return SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SettingsCardTitleText(text: i18n.accentColor, icon: const Icon(Icons.colorize)),
          SettingsCardSubtitleText(text: i18n.chooseAccentColor),
          GridView.count(
            shrinkWrap: true,
            primary: false,
            padding: const EdgeInsets.all(20),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 5,
            children: AppAccentColorType.values
                .map(
                  (accentColor) => _Item(accentColor: accentColor, isSelected: accentColorType == accentColor),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final AppAccentColorType accentColor;
  final bool isSelected;

  const _Item({
    Key? key,
    required this.accentColor,
    required this.isSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = accentColor.getAccentColor();

    return InkWell(
      onTap: () => _accentColorChanged(accentColor, context),
      child: Container(
        padding: const EdgeInsets.all(8),
        color: color,
        child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
      ),
    );
  }

  void _accentColorChanged(AppAccentColorType newValue, BuildContext context) {
    context.read<SettingsBloc>().add(SettingsEvent.appAccentColorChanged(selectedAccentColor: newValue));
    context.read<AppBloc>().add(AppEvent.accentColorChanged(accentColor: newValue));
  }
}
