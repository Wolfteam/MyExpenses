import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/settings/widgets/setting_card_subtitle_text.dart';
import 'package:my_expenses/presentation/settings/widgets/settings_card.dart';
import 'package:my_expenses/presentation/settings/widgets/settings_card_title_text.dart';
import 'package:my_expenses/presentation/shared/custom_assets.dart';
import 'package:my_expenses/presentation/shared/styles.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutSettingsCard extends StatelessWidget {
  final String appVersion;
  const AboutSettingsCard({super.key, required this.appVersion});

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
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
                        text: 'Github',
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

    return SettingsCard(child: content);
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
