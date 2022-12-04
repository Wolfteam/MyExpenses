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

class SyncSettingsCard extends StatelessWidget {
  final SyncIntervalType syncIntervalType;
  final bool showNotificationAfterFullSync;

  const SyncSettingsCard({
    super.key,
    required this.syncIntervalType,
    required this.showNotificationAfterFullSync,
  });

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    final theme = Theme.of(context);

    return SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SettingsCardTitleText(text: i18n.sync, icon: const Icon(Icons.sync)),
          SettingsCardSubtitleText(text: i18n.chooseSyncInterval),
          Padding(
            padding: Styles.edgeInsetHorizontal16,
            child: CommonDropdownButton<SyncIntervalType>(
              hint: i18n.selectSyncInterval,
              currentValue: syncIntervalType,
              values: EnumUtils.getTranslatedAndSortedEnum(SyncIntervalType.values, (v, _) => i18n.translateSyncIntervalType(v)),
              onChanged: (v, _) => _syncIntervalChanged(v, context),
            ),
          ),
          SwitchListTile(
            activeColor: theme.colorScheme.secondary,
            value: showNotificationAfterFullSync,
            title: Text(i18n.showNotificationAfterFullSync),
            onChanged: (v) => _showNotificationAfterFullSyncChanged(v, context),
          ),
          TextButton.icon(
            icon: const Icon(Icons.sync),
            onPressed: () => _triggerSyncTask(context),
            label: Text(i18n.syncNow),
          )
        ],
      ),
    );
  }

  void _syncIntervalChanged(SyncIntervalType newValue, BuildContext context) {
    final s = S.of(context);
    context.read<SettingsBloc>().add(SettingsEvent.syncIntervalChanged(selectedSyncInterval: newValue, translations: s.getBackgroundTranslations()));
  }

  void _showNotificationAfterFullSyncChanged(bool newValue, BuildContext context) =>
      context.read<SettingsBloc>().add(SettingsEvent.showNotificationAfterFullSyncChanged(show: newValue));

  void _triggerSyncTask(BuildContext context) {
    final s = S.of(context);
    context.read<SettingsBloc>().add(SettingsEvent.triggerSyncTask(translations: s.getBackgroundTranslations()));
  }
}
