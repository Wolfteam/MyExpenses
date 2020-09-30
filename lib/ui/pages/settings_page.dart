import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import '../../generated/i18n.dart';
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

    context.bloc<SettingsBloc>().add(const LoadSettings());
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

  List<Widget> _buildPage(
    BuildContext context,
    SettingsState state,
  ) {
    if (state is SettingsInitialState) {
      final i18n = I18n.of(context);
      return [
        _buildThemeSettings(context, state, i18n),
        _buildAccentColorSettings(context, state, i18n),
        _buildLanguageSettings(context, state, i18n),
        if (state.isUserLoggedIn) _buildSyncSettings(context, state, i18n),
        _buildOtherSettings(context, state, i18n),
        _buildAboutSettings(context, state, i18n),
      ];
    }

    return [
      const Center(
        child: CircularProgressIndicator(),
      )
    ];
  }

  Card _buildSettingsCard(Widget child) {
    return Card(
      shape: Styles.cardSettingsShape,
      margin: Styles.edgeInsetAll10,
      elevation: Styles.cardElevation,
      child: Container(margin: Styles.edgeInsetAll10, padding: Styles.edgeInsetAll5, child: child),
    );
  }

  Widget _buildThemeSettings(
    BuildContext context,
    SettingsInitialState state,
    I18n i18n,
  ) {
    final dropdown = DropdownButton<AppThemeType>(
      isExpanded: true,
      hint: Text(i18n.settingsSelectAppTheme),
      value: state.appTheme,
      underline: Container(
        height: 0,
        color: Colors.transparent,
      ),
      onChanged: _appThemeChanged,
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
        SettingsCardTitleText(text: i18n.settingsTheme, icon: const Icon(Icons.color_lens)),
        SettingsCardSubtitleText(text: i18n.settingsChooseAppTheme),
        Padding(padding: Styles.edgeInsetHorizontal16, child: dropdown),
      ],
    );

    return _buildSettingsCard(content);
  }

  Widget _buildAccentColorSettings(
    BuildContext context,
    SettingsInitialState state,
    I18n i18n,
  ) {
    final accentColors = AppAccentColorType.values.map((accentColor) {
      final color = accentColor.getAccentColor();

      final widget = InkWell(
        onTap: () => _accentColorChanged(accentColor),
        child: Container(
          padding: const EdgeInsets.all(8),
          color: color,
          child: state.accentColor == accentColor ? const Icon(Icons.check, color: Colors.white) : null,
        ),
      );

      return widget;
    }).toList();

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SettingsCardTitleText(text: i18n.settingsAccentColor, icon: const Icon(Icons.colorize)),
        SettingsCardSubtitleText(text: i18n.settingsChooseAccentColor),
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

  Widget _buildLanguageSettings(
    BuildContext context,
    SettingsInitialState state,
    I18n i18n,
  ) {
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
        SettingsCardTitleText(text: i18n.settingsLanguage, icon: const Icon(Icons.language)),
        SettingsCardSubtitleText(text: i18n.settingsChooseLanguage),
        Padding(
          padding: Styles.edgeInsetHorizontal16,
          child: DropdownButton<AppLanguageType>(
            isExpanded: true,
            hint: Text(i18n.settingsSelectLanguage),
            value: state.appLanguage,
            underline: Container(height: 0, color: Colors.transparent),
            onChanged: _languageChanged,
            items: dropdown,
          ),
        ),
      ],
    );
    return _buildSettingsCard(content);
  }

  Widget _buildSyncSettings(
    BuildContext context,
    SettingsInitialState state,
    I18n i18n,
  ) {
    final theme = Theme.of(context);
    final dropdown = DropdownButton<SyncIntervalType>(
      isExpanded: true,
      hint: Text(i18n.settingsSelectSyncInterval),
      value: state.syncInterval,
      underline: Container(height: 0, color: Colors.transparent),
      onChanged: _syncIntervalChanged,
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
        SettingsCardTitleText(text: i18n.settingsSync, icon: const Icon(Icons.sync)),
        SettingsCardSubtitleText(text: i18n.settingsChooseSyncInterval),
        Padding(padding: Styles.edgeInsetHorizontal16, child: dropdown),
        SwitchListTile(
          activeColor: theme.accentColor,
          value: state.showNotifAfterFullSync,
          title: Text(i18n.showNotificationAfterFullSync),
          onChanged: _showNotifAfterFullSyncChanged,
        ),
      ],
    );
    return _buildSettingsCard(content);
  }

  Widget _buildOtherSettings(
    BuildContext context,
    SettingsInitialState state,
    I18n i18n,
  ) {
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
                      Text(i18n.currencySimbol),
                      Container(
                        margin: const EdgeInsets.only(right: 15),
                        child: Text(CurrencyUtils.getCurrencySymbol(value)),
                      ),
                    ],
                  ),
                ],
              ))
          .toList(),
      value: state.currencySymbol,
      underline: Container(height: 0, color: Colors.transparent),
      onChanged: _currencyChanged,
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
        SettingsCardSubtitleText(text: i18n.settingsOthersSubTitle),
        Container(
          margin: const EdgeInsets.only(top: 10),
          padding: Styles.edgeInsetHorizontal16,
          child: currencyDropDown,
        ),
        SwitchListTile(
          activeColor: theme.accentColor,
          value: state.currencyToTheRight,
          title: Text(i18n.currencySymbolToRight),
          onChanged: _currencyPlacementChanged,
        ),
        SwitchListTile(
          activeColor: theme.accentColor,
          value: state.askForPassword,
          title: Text(i18n.askForPassword),
          onChanged: _askForPasswordChanged,
        ),
        if (state.canUseFingerPrint)
          SwitchListTile(
            activeColor: theme.accentColor,
            value: state.askForFingerPrint,
            title: Text(i18n.askForFingerPrint),
            onChanged: _askForFingerPrintChanged,
          ),
        SwitchListTile(
          activeColor: theme.accentColor,
          value: state.showNotifForRecurringTrans,
          title: Text(i18n.showNotificationForRecurringTrans),
          onChanged: _showNotifForRecurringTransChanged,
        ),
      ],
    );

    return _buildSettingsCard(content);
  }

  Widget _buildAboutSettings(
    BuildContext context,
    SettingsInitialState state,
    I18n i18n,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SettingsCardTitleText(text: i18n.settingsAbout, icon: const Icon(Icons.info_outline)),
        SettingsCardSubtitleText(text: i18n.settingsAboutSubTitle),
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
              Text(i18n.appVersion(state.appVersion), textAlign: TextAlign.center, style: textTheme.subtitle2),
              Text(i18n.settingsAboutSummary, textAlign: TextAlign.center),
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: Text(i18n.settingsDonations, style: textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold)),
              ),
              Text(i18n.settingsDonationsMsg),
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: Text(i18n.settingsSupport, style: textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold)),
              ),
              Container(
                margin: const EdgeInsets.only(top: 5),
                child: Text(i18n.settingsDonationSupport),
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
                            _lauchUrl('https://github.com/Wolfteam/MyExpenses/issues');
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

  Future _lauchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  void _appThemeChanged(AppThemeType newValue) {
    final i18n = I18n.of(context);
    showInfoToast(i18n.restartTheAppToApplyChanges);
    context.bloc<SettingsBloc>().add(AppThemeChanged(newValue));
    context.bloc<app_bloc.AppBloc>().add(app_bloc.AppThemeChanged(newValue));
  }

  void _accentColorChanged(AppAccentColorType newValue) {
    context.bloc<SettingsBloc>().add(AppAccentColorChanged(newValue));
    context.bloc<app_bloc.AppBloc>().add(app_bloc.AppAccentColorChanged(newValue));
  }

  void _syncIntervalChanged(SyncIntervalType newValue) =>
      context.bloc<SettingsBloc>().add(SyncIntervalChanged(newValue));

  void _languageChanged(AppLanguageType newValue) {
    final i18n = I18n.of(context);
    showInfoToast(i18n.restartTheAppToApplyChanges);
    context.bloc<SettingsBloc>().add(AppLanguageChanged(newValue));
  }

  void _askForFingerPrintChanged(bool ask) => context.bloc<SettingsBloc>().add(AskForFingerPrintChanged(ask: ask));

  Future<void> _askForPasswordChanged(bool ask) async {
    if (!ask) {
      context.bloc<SettingsBloc>().add(AskForPasswordChanged(ask: ask));
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

    context.bloc<SettingsBloc>().add(AskForPasswordChanged(ask: result));
  }

  void _currencyChanged(CurrencySymbolType newValue) {
    context.bloc<SettingsBloc>().add(CurrencyChanged(newValue));
    BlocUtils.raiseCommonBlocEvents(context, reloadCharts: true, reloadTransactions: true);
  }

  void _currencyPlacementChanged(bool newValue) {
    context.bloc<SettingsBloc>().add(CurrencyPlacementChanged(placeToTheRight: newValue));
    BlocUtils.raiseCommonBlocEvents(context, reloadTransactions: true, reloadCharts: true);
  }

  void _showNotifAfterFullSyncChanged(bool newValue) =>
      context.bloc<SettingsBloc>().add(ShowNotifAfterFullSyncChanged(show: newValue));

  void _showNotifForRecurringTransChanged(bool newValue) =>
      context.bloc<SettingsBloc>().add(ShowNotifForRecurringTransChanged(show: newValue));
}
