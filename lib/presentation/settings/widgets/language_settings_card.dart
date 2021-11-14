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

class LanguageSettingsCard extends StatelessWidget {
  final AppLanguageType language;

  const LanguageSettingsCard({Key? key, required this.language}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    return SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SettingsCardTitleText(text: i18n.language, icon: const Icon(Icons.language)),
          SettingsCardSubtitleText(text: i18n.chooseLanguage),
          Padding(
            padding: Styles.edgeInsetHorizontal16,
            child: CommonDropdownButton<AppLanguageType>(
              hint: i18n.selectLanguage,
              currentValue: language,
              values: EnumUtils.getTranslatedAndSortedEnum(AppLanguageType.values, (v, _) => i18n.translateAppLanguageType(v)),
              onChanged: (v, _) => _languageChanged(v, context),
            ),
          ),
        ],
      ),
    );
  }

  void _languageChanged(AppLanguageType newValue, BuildContext context) {
    final i18n = S.of(context);
    ToastUtils.showInfoToast(context, i18n.restartTheAppToApplyChanges);
    context.read<SettingsBloc>().add(SettingsEvent.appLanguageChanged(selectedLanguage: newValue));
  }
}
