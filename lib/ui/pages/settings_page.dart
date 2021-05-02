import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/common/utils/background_utils.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../bloc/app/app_bloc.dart' as app_bloc;
import '../../bloc/settings/settings_bloc.dart';
import '../../common/enums/app_accent_color_type.dart';
import '../../common/enums/app_language_type.dart';
import '../../common/enums/app_theme_type.dart';
import '../../common/enums/currency_symbol_type.dart';
import '../../common/enums/sync_intervals_type.dart';
import '../../common/extensions/app_theme_type_extensions.dart';
import '../../common/extensions/i18n_extensions.dart';
import '../../common/presentation/custom_assets.dart';
import '../../common/styles.dart';
import '../../common/utils/bloc_utils.dart';
import '../../common/utils/currency_utils.dart';
import '../../common/utils/toast_utils.dart';
import '../widgets/settings/password_dialog.dart';
import '../widgets/settings/setting_card_subtitle_text.dart';
import '../widgets/settings/settings_card_title_text.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with AutomaticKeepAliveClientMixin<SettingsPage> {
  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    context.read<SettingsBloc>().add(const SettingsEvent.load());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.all(5),
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (ctx, state) {
          return ListView(
            children: _buildPage(context, state),
          );
        },
      ),
    );
  }

  List<Widget> _buildPage(BuildContext context, SettingsState state) {
    final i18n = S.of(context);
    return state.map(
      loading: (_) => [const Center(child: CircularProgressIndicator())],
      initial: (state) => [
        _buildThemeSettings(context, state.appTheme, i18n),
        _buildAccentColorSettings(context, state.accentColor, i18n),
        _buildLanguageSettings(context, state.appLanguage, i18n),
        if (state.isUserLoggedIn) _buildSyncSettings(context, state.syncInterval, state.showNotificationAfterFullSync, i18n),
        _buildOtherSettings(
          context,
          state.currencySymbol,
          state.currencyToTheRight,
          state.askForPassword,
          state.canUseFingerPrint,
          state.askForFingerPrint,
          state.showNotificationForRecurringTrans,
          i18n,
        ),
        _buildAboutSettings(context, state.appVersion, i18n),
      ],
    );
  }

  Card _buildSettingsCard(Widget child) {
    return Card(
      shape: Styles.cardSettingsShape,
      margin: Styles.edgeInsetAll10,
      elevation: Styles.cardElevation,
      child: Container(margin: Styles.edgeInsetAll10, padding: Styles.edgeInsetAll5, child: child),
    );
  }

  Widget _buildThemeSettings(BuildContext context, AppThemeType appThemeType, S i18n) {
    final dropdown = DropdownButton<AppThemeType>(
      isExpanded: true,
      hint: Text(i18n.selectAppTheme),
      value: appThemeType,
      underline: Container(
        height: 0,
        color: Colors.transparent,
      ),
      onChanged: (v) => _appThemeChanged(v!),
      items: AppThemeType.values
          .map<DropdownMenuItem<AppThemeType>>(
            (theme) => DropdownMenuItem<AppThemeType>(
              value: theme,
              child: Text(i18n.translateAppThemeType(theme)),
            ),
          )
          .toList(),
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SettingsCardTitleText(text: i18n.theme, icon: const Icon(Icons.color_lens)),
        SettingsCardSubtitleText(text: i18n.chooseAppTheme),
        Padding(padding: Styles.edgeInsetHorizontal16, child: dropdown),
      ],
    );

    return _buildSettingsCard(content);
  }

  Widget _buildAccentColorSettings(BuildContext context, AppAccentColorType accentColorType, S i18n) {
    final accentColors = AppAccentColorType.values.map((accentColor) {
      final color = accentColor.getAccentColor();

      final widget = InkWell(
        onTap: () => _accentColorChanged(accentColor),
        child: Container(
          padding: const EdgeInsets.all(8),
          color: color,
          child: accentColorType == accentColor ? const Icon(Icons.check, color: Colors.white) : null,
        ),
      );

      return widget;
    }).toList();

    final content = Column(
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
          children: accentColors,
        ),
      ],
    );

    return _buildSettingsCard(content);
  }

  Widget _buildLanguageSettings(BuildContext context, AppLanguageType languageType, S i18n) {
    final dropdown = [AppLanguageType.english, AppLanguageType.spanish]
        .map<DropdownMenuItem<AppLanguageType>>(
          (lang) => DropdownMenuItem<AppLanguageType>(
            value: lang,
            child: Text(i18n.translateAppLanguageType(lang)),
          ),
        )
        .toList();

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SettingsCardTitleText(text: i18n.language, icon: const Icon(Icons.language)),
        SettingsCardSubtitleText(text: i18n.chooseLanguage),
        Padding(
          padding: Styles.edgeInsetHorizontal16,
          child: DropdownButton<AppLanguageType>(
            isExpanded: true,
            hint: Text(i18n.selectLanguage),
            value: languageType,
            underline: Container(height: 0, color: Colors.transparent),
            onChanged: (v) => _languageChanged(v!),
            items: dropdown,
          ),
        ),
      ],
    );
    return _buildSettingsCard(content);
  }

  Widget _buildSyncSettings(BuildContext context, SyncIntervalType syncIntervalType, bool showNotificationAfterFullSync, S i18n) {
    final theme = Theme.of(context);
    final dropdown = DropdownButton<SyncIntervalType>(
      isExpanded: true,
      hint: Text(i18n.selectSyncInterval),
      value: syncIntervalType,
      underline: Container(height: 0, color: Colors.transparent),
      onChanged: (v) => _syncIntervalChanged(v!),
      items: SyncIntervalType.values
          .map<DropdownMenuItem<SyncIntervalType>>(
            (interval) => DropdownMenuItem<SyncIntervalType>(
              value: interval,
              child: Text(i18n.translateSyncIntervalType(interval)),
            ),
          )
          .toList(),
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SettingsCardTitleText(text: i18n.sync, icon: const Icon(Icons.sync)),
        SettingsCardSubtitleText(text: i18n.chooseSyncInterval),
        Padding(padding: Styles.edgeInsetHorizontal16, child: dropdown),
        SwitchListTile(
          activeColor: theme.accentColor,
          value: showNotificationAfterFullSync,
          title: Text(i18n.showNotificationAfterFullSync),
          onChanged: _showNotificationAfterFullSyncChanged,
        ),
        if (!kReleaseMode)
          TextButton.icon(
            icon: const Icon(Icons.sync),
            onPressed: () => BackgroundUtils.runSyncTask(),
            label: Text(i18n.syncNow),
          )
      ],
    );
    return _buildSettingsCard(content);
  }

  Widget _buildOtherSettings(BuildContext context, CurrencySymbolType currencySymbolType, bool currencyToTheRight, bool askForPassword,
      bool canUseFingerPrint, bool askForFingerPrint, bool showNotificationForRecurringTrans, S i18n) {
    final theme = Theme.of(context);
    final currencyDropDown = DropdownButton<CurrencySymbolType>(
      isExpanded: true,
      isDense: true,
      selectedItemBuilder: (ctx) => CurrencySymbolType.values
          .map((value) => Column(
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
              ))
          .toList(),
      value: currencySymbolType,
      underline: Container(height: 0, color: Colors.transparent),
      onChanged: (v) => _currencyChanged(v!),
      items: CurrencySymbolType.values
          .map<DropdownMenuItem<CurrencySymbolType>>(
            (symbol) => DropdownMenuItem<CurrencySymbolType>(
              value: symbol,
              child: Text(CurrencyUtils.getCurrencySymbol(symbol)),
            ),
          )
          .toList(),
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SettingsCardTitleText(text: i18n.others, icon: const Icon(Icons.sync)),
        SettingsCardSubtitleText(text: i18n.othersSubTitle),
        Container(
          margin: const EdgeInsets.only(top: 10),
          padding: Styles.edgeInsetHorizontal16,
          child: currencyDropDown,
        ),
        SwitchListTile(
          activeColor: theme.accentColor,
          value: currencyToTheRight,
          title: Text(i18n.currencySymbolToRight),
          onChanged: _currencyPlacementChanged,
        ),
        SwitchListTile(
          activeColor: theme.accentColor,
          value: askForPassword,
          title: Text(i18n.askForPassword),
          onChanged: _askForPasswordChanged,
        ),
        if (canUseFingerPrint)
          SwitchListTile(
            activeColor: theme.accentColor,
            value: askForFingerPrint,
            title: Text(i18n.askForFingerPrint),
            onChanged: _askForFingerPrintChanged,
          ),
        SwitchListTile(
          activeColor: theme.accentColor,
          value: showNotificationForRecurringTrans,
          title: Text(i18n.showNotificationForRecurringTrans),
          onChanged: _showNotificationForRecurringTransChanged,
        ),
      ],
    );

    return _buildSettingsCard(content);
  }

  Widget _buildAboutSettings(BuildContext context, String appVersion, S i18n) {
    final textTheme = Theme.of(context).textTheme;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SettingsCardTitleText(text: i18n.about, icon: const Icon(Icons.info_outline)),
        SettingsCardSubtitleText(text: i18n.aboutSubTitle),
        Container(
          margin: Styles.edgeInsetHorizontal16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Image.asset(CustomAssets.appIcon, width: 70, height: 70),
              ),
              Text(i18n.appName, textAlign: TextAlign.center, style: textTheme.subtitle2),
              Text(i18n.appVersion(appVersion), textAlign: TextAlign.center, style: textTheme.subtitle2),
              Text(i18n.aboutSummary, textAlign: TextAlign.center),
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: Text(i18n.donations, style: textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold)),
              ),
              Text(i18n.donationsMsg),
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: Text(i18n.support, style: textTheme.subtitle1!.copyWith(fontWeight: FontWeight.bold)),
              ),
              Container(
                margin: const EdgeInsets.only(top: 5),
                child: Text(i18n.donationSupport),
              ),
              Container(
                margin: const EdgeInsets.only(top: 5),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Github Issue Page',
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.blue,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            _launchUrl('https://github.com/Wolfteam/MyExpenses/issues');
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return _buildSettingsCard(content);
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  void _appThemeChanged(AppThemeType newValue) {
    final i18n = S.of(context);
    ToastUtils.showInfoToast(context, i18n.restartTheAppToApplyChanges);
    context.read<SettingsBloc>().add(SettingsEvent.appThemeChanged(selectedAppTheme: newValue));
    context.read<app_bloc.AppBloc>().add(app_bloc.AppEvent.themeChanged(theme: newValue));
  }

  void _accentColorChanged(AppAccentColorType newValue) {
    context.read<SettingsBloc>().add(SettingsEvent.appAccentColorChanged(selectedAccentColor: newValue));
    context.read<app_bloc.AppBloc>().add(app_bloc.AppEvent.accentColorChanged(accentColor: newValue));
  }

  void _syncIntervalChanged(SyncIntervalType newValue) =>
      context.read<SettingsBloc>().add(SettingsEvent.syncIntervalChanged(selectedSyncInterval: newValue));

  void _languageChanged(AppLanguageType newValue) {
    final i18n = S.of(context);
    ToastUtils.showInfoToast(context, i18n.restartTheAppToApplyChanges);
    context.read<SettingsBloc>().add(SettingsEvent.appLanguageChanged(selectedLanguage: newValue));
  }

  void _askForFingerPrintChanged(bool ask) => context.read<SettingsBloc>().add(SettingsEvent.askForFingerPrintChanged(ask: ask));

  Future<void> _askForPasswordChanged(bool ask) async {
    if (!ask) {
      context.read<SettingsBloc>().add(SettingsEvent.askForPasswordChanged(ask: ask));
      return;
    }

    final result = await showModalBottomSheet<bool>(
      context: context,
      shape: Styles.modalBottomSheetShape,
      isDismissible: true,
      isScrollControlled: true,
      builder: (ctx) => const PasswordDialog(),
    );

    if (result == null) return;

    context.read<SettingsBloc>().add(SettingsEvent.askForPasswordChanged(ask: result));
  }

  void _currencyChanged(CurrencySymbolType newValue) {
    context.read<SettingsBloc>().add(SettingsEvent.currencyChanged(selectedCurrency: newValue));
    BlocUtils.raiseCommonBlocEvents(context, reloadCharts: true, reloadTransactions: true);
  }

  void _currencyPlacementChanged(bool newValue) {
    context.read<SettingsBloc>().add(SettingsEvent.currencyPlacementChanged(placeToTheRight: newValue));
    BlocUtils.raiseCommonBlocEvents(context, reloadTransactions: true, reloadCharts: true);
  }

  void _showNotificationAfterFullSyncChanged(bool newValue) =>
      context.read<SettingsBloc>().add(SettingsEvent.showNotificationAfterFullSyncChanged(show: newValue));

  void _showNotificationForRecurringTransChanged(bool newValue) =>
      context.read<SettingsBloc>().add(SettingsEvent.showNotificationForRecurringTransChanged(show: newValue));
}
