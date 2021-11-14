import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/presentation/settings/widgets/about_settings_card.dart';
import 'package:my_expenses/presentation/settings/widgets/accent_color_settings_card.dart';
import 'package:my_expenses/presentation/settings/widgets/language_settings_card.dart';
import 'package:my_expenses/presentation/settings/widgets/others_settings_card.dart';
import 'package:my_expenses/presentation/settings/widgets/sync_settings_card.dart';
import 'package:my_expenses/presentation/settings/widgets/theme_settings_card.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with AutomaticKeepAliveClientMixin<SettingsPage> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.all(5),
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (ctx, state) {
          return ListView(
            children: state.map(
              loading: (_) => [const Center(child: CircularProgressIndicator())],
              initial: (state) => [
                ThemeSettingsCard(appThemeType: state.appTheme),
                AccentColorSettingsCard(accentColorType: state.accentColor),
                LanguageSettingsCard(language: state.appLanguage),
                if (state.isUserLoggedIn)
                  SyncSettingsCard(
                    syncIntervalType: state.syncInterval,
                    showNotificationAfterFullSync: state.showNotificationAfterFullSync,
                  ),
                OtherSettingsCard(
                  currencySymbolType: state.currencySymbol,
                  currencyToTheRight: state.currencyToTheRight,
                  askForPassword: state.askForPassword,
                  canUseFingerPrint: state.canUseFingerPrint,
                  askForFingerPrint: state.askForFingerPrint,
                  showNotificationForRecurringTrans: state.showNotificationForRecurringTrans,
                ),
                AboutSettingsCard(appVersion: state.appVersion),
              ],
            ),
          );
        },
      ),
    );
  }
}
