import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/settings/widgets/password_bottom_sheet.dart';
import 'package:my_expenses/presentation/settings/widgets/setting_card_subtitle_text.dart';
import 'package:my_expenses/presentation/settings/widgets/settings_card.dart';
import 'package:my_expenses/presentation/settings/widgets/settings_card_title_text.dart';
import 'package:my_expenses/presentation/shared/styles.dart';

class SecuritySettingsCard extends StatelessWidget {
  final bool askForPassword;
  final bool canUseFingerPrint;
  final bool askForFingerPrint;

  const SecuritySettingsCard({
    super.key,
    required this.askForPassword,
    required this.canUseFingerPrint,
    required this.askForFingerPrint,
  });

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    return SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SettingsCardTitleText(
            text: i18n.securityCardTitle,
            icon: const Icon(Icons.lock_outline),
          ),
          SettingsCardSubtitleText(text: i18n.securityCardSubTitle),
          SwitchListTile(
            value: askForPassword,
            title: Tooltip(message: i18n.askForPassword, child: Text(i18n.askForPassword)),
            onChanged: (v) => _askForPasswordChanged(v, context),
          ),
          if (canUseFingerPrint)
            SwitchListTile(
              value: askForFingerPrint,
              title: Tooltip(
                message: i18n.askForFingerPrint,
                child: Text(i18n.askForFingerPrint, overflow: TextOverflow.ellipsis),
              ),
              onChanged: (v) => _askForFingerPrintChanged(v, context),
            ),
        ],
      ),
    );
  }

  void _askForFingerPrintChanged(bool ask, BuildContext context) =>
      context.read<SettingsBloc>().add(SettingsEvent.askForFingerPrintChanged(ask: ask));

  Future<void> _askForPasswordChanged(bool ask, BuildContext context) async {
    if (!ask) {
      context.read<SettingsBloc>().add(SettingsEvent.askForPasswordChanged(ask: ask));
      return;
    }

    await showModalBottomSheet<bool>(
      context: context,
      shape: Styles.modalBottomSheetShape,
      isScrollControlled: true,
      builder: (ctx) => const PasswordBottomSheet(),
    ).then((result) {
      if (result == null || !context.mounted) return;
      context.read<SettingsBloc>().add(SettingsEvent.askForPasswordChanged(ask: result));
    });
  }
}
