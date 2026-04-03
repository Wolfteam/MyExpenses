import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/settings/widgets/setting_card_subtitle_text.dart';
import 'package:my_expenses/presentation/settings/widgets/settings_card.dart';
import 'package:my_expenses/presentation/settings/widgets/settings_card_title_text.dart';

class NotificationsSettingsCard extends StatelessWidget {
  final bool showNotificationForRecurringTrans;
  final bool showNotificationAfterFullSync;

  const NotificationsSettingsCard({
    super.key,
    required this.showNotificationForRecurringTrans,
    required this.showNotificationAfterFullSync,
  });

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    return SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SettingsCardTitleText(
            text: i18n.notificationsCardTitle,
            icon: const Icon(Icons.notifications_outlined),
          ),
          SettingsCardSubtitleText(text: i18n.notificationsCardSubTitle),
          SwitchListTile(
            value: showNotificationForRecurringTrans,
            title: Tooltip(
              message: i18n.showNotificationForRecurringTrans,
              child: Text(i18n.showNotificationForRecurringTrans, overflow: TextOverflow.ellipsis),
            ),
            onChanged: (v) => _recurringTransNotificationChanged(v, context),
          ),
          SwitchListTile(
            value: showNotificationAfterFullSync,
            title: Tooltip(
              message: i18n.showNotificationAfterFullSync,
              child: Text(i18n.showNotificationAfterFullSync, overflow: TextOverflow.ellipsis),
            ),
            onChanged: (v) => _syncNotificationChanged(v, context),
          ),
        ],
      ),
    );
  }

  void _recurringTransNotificationChanged(bool newValue, BuildContext context) => context.read<SettingsBloc>().add(
    SettingsEvent.showNotificationForRecurringTransChanged(show: newValue),
  );

  void _syncNotificationChanged(bool newValue, BuildContext context) => context.read<SettingsBloc>().add(
    SettingsEvent.showNotificationAfterFullSyncChanged(show: newValue),
  );
}
