import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/settings/widgets/setting_card_subtitle_text.dart';
import 'package:my_expenses/presentation/settings/widgets/settings_card.dart';
import 'package:my_expenses/presentation/settings/widgets/settings_card_title_text.dart';
import 'package:my_expenses/presentation/shared/common_dropdown_button.dart';
import 'package:my_expenses/presentation/shared/extensions/i18n_extensions.dart';
import 'package:my_expenses/presentation/shared/styles.dart';
import 'package:my_expenses/presentation/shared/utils/enum_utils.dart';
import 'package:my_expenses/presentation/shared/utils/toast_utils.dart';

class ThemeSettingsCard extends StatelessWidget {
  final AppThemeType appThemeType;

  const ThemeSettingsCard({super.key, required this.appThemeType});

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    return SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SettingsCardTitleText(text: i18n.theme, icon: const Icon(Icons.color_lens)),
          SettingsCardSubtitleText(text: i18n.chooseAppTheme),
          Padding(
            padding: Styles.edgeInsetHorizontal16,
            child: CommonDropdownButton<AppThemeType>(
              hint: i18n.selectAppTheme,
              currentValue: appThemeType,
              values: EnumUtils.getTranslatedAndSortedEnum(AppThemeType.values, (v, _) => i18n.translateAppThemeType(v)),
              onChanged: (v, _) => _appThemeChanged(v, context),
            ),
          ),
        ],
      ),
    );
  }

  void _appThemeChanged(AppThemeType newValue, BuildContext context) {
    final i18n = S.of(context);
    ToastUtils.showInfoToast(context, i18n.restartTheAppToApplyChanges);
    context.read<SettingsBloc>().add(SettingsEvent.appThemeChanged(selectedAppTheme: newValue));
    context.read<AppBloc>().add(AppEvent.themeChanged(theme: newValue));
  }
}
