import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../bloc/app/app_bloc.dart' as app_bloc;
import '../../bloc/settings/settings_bloc.dart';
import '../../common/enums/app_accent_color_type.dart';
import '../../common/enums/app_language_type.dart';
import '../../common/enums/app_theme_type.dart';
import '../../common/enums/sync_intervals_type.dart';
import '../../common/extensions/app_theme_type_extensions.dart';
import '../../common/extensions/i18n_extensions.dart';
import '../../generated/i18n.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with AutomaticKeepAliveClientMixin<SettingsPage> {
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
        _buildSyncSettings(context, state, i18n),
        _buildAboutSettings(context, state, i18n),
      ];
    }

    return [
      const Center(
        child: CircularProgressIndicator(),
      )
    ];
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
      iconSize: 24,
      underline: Container(
        height: 0,
        color: Colors.transparent,
      ),
      onChanged: _appThemeChanged,
      items: AppThemeType.values
          .map<DropdownMenuItem<AppThemeType>>(
            (theme) => DropdownMenuItem<AppThemeType>(
              value: theme,
              child: Text(
                i18n.translateAppThemeType(theme),
              ),
            ),
          )
          .toList(),
    );

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(10),
      elevation: 3,
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.color_lens),
                Container(
                  margin: const EdgeInsets.only(left: 5),
                  child: Text(
                    i18n.settingsTheme,
                    style: Theme.of(context).textTheme.title,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                i18n.settingsChooseAppTheme,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
              ),
              child: dropdown,
            ),
            // SwitchListTile(
            //   title: Text(i18n.settingsUseDarkAmoled),
            //   // subtitle: Text("Usefull on amoled screens"),
            //   value: true,
            //   onChanged: (newValue) {},
            // ),
          ],
        ),
      ),
    );
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
          child: state.accentColor == accentColor
              ? Icon(
                  Icons.check,
                  color: Colors.white,
                )
              : null,
        ),
      );

      return widget;
    }).toList();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(10),
      elevation: 3,
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.colorize),
                Container(
                  margin: const EdgeInsets.only(left: 5),
                  child: Text(
                    i18n.settingsAccentColor,
                    style: Theme.of(context).textTheme.title,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 5,
              ),
              child: Text(
                i18n.settingsChooseAccentColor,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
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
        ),
      ),
    );
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
            child: Text(
              i18n.translateAppLanguageType(lang),
            ),
          ),
        )
        .toList();
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(10),
      elevation: 3,
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.language),
                Container(
                  margin: const EdgeInsets.only(left: 5),
                  child: Text(
                    i18n.settingsLanguage,
                    style: Theme.of(context).textTheme.title,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                i18n.settingsChooseLanguage,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
              ),
              child: DropdownButton<AppLanguageType>(
                isExpanded: true,
                hint: Text(i18n.settingsSelectLanguage),
                value: state.appLanguage,
                iconSize: 24,
                underline: Container(
                  height: 0,
                  color: Colors.transparent,
                ),
                onChanged: _languageChanged,
                items: dropdown,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncSettings(
    BuildContext context,
    SettingsInitialState state,
    I18n i18n,
  ) {
    final dropdown = DropdownButton<SyncIntervalType>(
      isExpanded: true,
      hint: Text(i18n.settingsSelectSyncInterval),
      value: state.syncInterval,
      iconSize: 24,
      underline: Container(
        height: 0,
        color: Colors.transparent,
      ),
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

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(10),
      elevation: 3,
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.sync),
                Container(
                  margin: const EdgeInsets.only(left: 5),
                  child: Text(
                    i18n.settingsSync,
                    style: Theme.of(context).textTheme.title,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 5,
              ),
              child: Text(
                i18n.settingsChooseSyncInterval,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
              ),
              child: dropdown,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSettings(
    BuildContext context,
    SettingsInitialState state,
    I18n i18n,
  ) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(10),
      elevation: 3,
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.info_outline),
                Container(
                  margin: const EdgeInsets.only(left: 5),
                  child: Text(
                    i18n.settingsAbout,
                    style: textTheme.title,
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 5, left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Image.asset(
                      'assets/images/cost.png',
                      width: 70,
                      height: 70,
                    ),
                  ),
                  Text(
                    i18n.appName,
                    textAlign: TextAlign.center,
                    style: textTheme.subtitle,
                  ),
                  Text(
                    i18n.appVersion(state.appVersion),
                    textAlign: TextAlign.center,
                    style: textTheme.subtitle,
                  ),
                  Text(
                    i18n.settingsAboutSummary,
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: Text(
                      i18n.settingsDonations,
                      style: textTheme.subhead
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    i18n.settingsDonationSupport,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: Text(
                      i18n.settingsSupport,
                      style: textTheme.subhead
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    child: Text(
                      i18n.settingsDonationSupport,
                      style: textTheme.subtitle,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Github Issue Page',
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.blue,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                _lauchUrl(
                                    'https://github.com/Wolfteam/MyExpenses/Issues');
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
        ),
      ),
    );
  }

  Future _lauchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  void _appThemeChanged(AppThemeType newValue) {
    context.bloc<SettingsBloc>().add(AppThemeChanged(newValue));
    context.bloc<app_bloc.AppBloc>().add(app_bloc.AppThemeChanged(newValue));
  }

  void _accentColorChanged(AppAccentColorType newValue) {
    context.bloc<SettingsBloc>().add(AppAccentColorChanged(newValue));
    context
        .bloc<app_bloc.AppBloc>()
        .add(app_bloc.AppAccentColorChanged(newValue));
  }

  void _syncIntervalChanged(SyncIntervalType newValue) =>
      context.bloc<SettingsBloc>().add(SyncIntervalChanged(newValue));

  void _languageChanged(AppLanguageType newValue) =>
      context.bloc<SettingsBloc>().add(AppLanguageChanged(newValue));
}
