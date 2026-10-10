import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/drawer/user_accounts_bottom_sheet_dialog.dart';
import 'package:my_expenses/presentation/settings/widgets/setting_card_subtitle_text.dart';
import 'package:my_expenses/presentation/settings/widgets/settings_card.dart';
import 'package:my_expenses/presentation/settings/widgets/settings_card_title_text.dart';
import 'package:my_expenses/presentation/shared/common_dropdown_button.dart';
import 'package:my_expenses/presentation/shared/extensions/i18n_extensions.dart';
import 'package:my_expenses/presentation/shared/styles.dart';
import 'package:my_expenses/presentation/shared/utils/enum_utils.dart';

class SyncSettingsCard extends StatelessWidget {
  final SyncIntervalType syncIntervalType;
  final SyncProviderType syncProviderType;

  const SyncSettingsCard({
    super.key,
    required this.syncIntervalType,
    required this.syncProviderType,
  });

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    final userSessionState = context.watch<UserSessionBloc>().state;
    final isGoogleDrive = syncProviderType == SyncProviderType.googleDrive;
    final isProviderSelected = syncProviderType != SyncProviderType.none;
    final needsGoogleSignIn = isGoogleDrive && !userSessionState.isUserSignedIn;
    final supportsSyncInterval = Platform.isIOS || Platform.isAndroid;

    return SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SettingsCardTitleText(
            text: i18n.sync,
            icon: const Icon(Icons.sync),
          ),
          SettingsCardSubtitleText(text: i18n.chooseSyncProvider),
          CommonDropdownButton<SyncProviderType>(
            hint: i18n.syncProvider,
            currentValue: syncProviderType,
            values: EnumUtils.getTranslatedAndSortedEnum(
              _getAvailableProviders(),
              (v, _) => i18n.translateSyncProviderType(v),
            ),
            onChanged: (v, _) => _syncProviderChanged(v, context),
          ),
          if (isGoogleDrive)
            _buildGoogleAccountSection(
              context,
              i18n,
              userSessionState,
            ),
          if (isProviderSelected && !needsGoogleSignIn) ...[
            if (supportsSyncInterval) ...[
              SettingsCardSubtitleText(
                text: i18n.chooseSyncInterval,
              ),
              CommonDropdownButton<SyncIntervalType>(
                hint: i18n.selectSyncInterval,
                currentValue: syncIntervalType,
                values: EnumUtils.getTranslatedAndSortedEnum(
                  SyncIntervalType.values,
                  (v, _) => i18n.translateSyncIntervalType(v),
                ),
                onChanged: (v, _) => _syncIntervalChanged(v, context),
              ),
            ],
            TextButton.icon(
              icon: const Icon(Icons.sync),
              onPressed: () => _triggerSyncTask(context),
              label: Text(i18n.syncNow),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGoogleAccountSection(
    BuildContext context,
    S i18n,
    UserSessionState userSessionState,
  ) {
    if (!userSessionState.isUserSignedIn) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: FilledButton.icon(
          icon: const Icon(Icons.login),
          onPressed: () => _showSignInDialog(context),
          label: Text(i18n.signInWithGoogle),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (userSessionState.img != null && userSessionState.img!.isNotEmpty)
            CircleAvatar(
              backgroundImage: FileImage(File(userSessionState.img!)),
              radius: 20,
            )
          else
            const CircleAvatar(
              radius: 20,
              child: Icon(Icons.person),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (userSessionState.fullName != null)
                  Text(
                    userSessionState.fullName!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                if (userSessionState.email != null)
                  Text(
                    userSessionState.email!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.read<UserSessionBloc>().add(const UserSessionEvent.signOut()),
            child: Text(i18n.signOut),
          ),
        ],
      ),
    );
  }

  void _showSignInDialog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: Styles.modalBottomSheetShape,
      isScrollControlled: true,
      builder: (_) => UserAccountsBottomSheetDialog(),
    );
  }

  List<SyncProviderType> _getAvailableProviders() {
    if (Platform.isIOS || Platform.isMacOS) {
      return SyncProviderType.values;
    }
    return [SyncProviderType.none, SyncProviderType.googleDrive];
  }

  void _syncProviderChanged(SyncProviderType newValue, BuildContext context) {
    if (syncProviderType != SyncProviderType.none && newValue != SyncProviderType.none && syncProviderType != newValue) {
      _showSwitchDialog(context, newValue);
      return;
    }

    _applyProviderChange(newValue, context);
  }

  void _applyProviderChange(SyncProviderType newValue, BuildContext context) {
    context.read<SettingsBloc>().add(SettingsEvent.syncProviderChanged(selectedSyncProvider: newValue));
  }

  void _showSwitchDialog(BuildContext context, SyncProviderType newProvider) {
    final i18n = S.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(i18n.switchSyncProviderTitle),
        content: Text(i18n.switchSyncProviderMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(i18n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _applyProviderChange(newProvider, context);
            },
            child: Text(i18n.switchAnyway),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _applyProviderChange(newProvider, context);
            },
            child: Text(i18n.exportFirst),
          ),
        ],
      ),
    );
  }

  void _syncIntervalChanged(SyncIntervalType newValue, BuildContext context) {
    final s = S.of(context);
    context.read<SettingsBloc>().add(
      SettingsEvent.syncIntervalChanged(
        selectedSyncInterval: newValue,
        translations: s.getBackgroundTranslations(),
      ),
    );
  }

  void _triggerSyncTask(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEvent.triggerSync());
  }
}
