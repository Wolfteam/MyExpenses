import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/extensions/string_extensions.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/drawer/widgets/logged_user_image.dart';

class HomeWelcome extends StatelessWidget {
  const HomeWelcome({super.key});

  @override
  Widget build(BuildContext context) {
    final S i18n = S.of(context);
    final theme = Theme.of(context);
    return BlocBuilder<UserSessionBloc, UserSessionState>(
      builder: (context, drawerState) {
        final settingsState = context.watch<SettingsBloc>().state;
        final syncProvider = settingsState is SettingsStateInitialState ? settingsState.syncProvider : SyncProviderType.none;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Spacer(),
            Expanded(
              child: Column(
                children: [
                  Text(
                    i18n.hello,
                    style: theme.textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (drawerState.fullName.isNotNullEmptyOrWhitespace)
                    Text(
                      drawerState.fullName!,
                      style: theme.textTheme.titleSmall,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                ],
              ),
            ),
            Expanded(child: _buildUserImage(syncProvider, drawerState)),
          ],
        );
      },
    );
  }

  Widget _buildUserImage(SyncProviderType syncProvider, UserSessionState drawerState) {
    return switch (syncProvider) {
      SyncProviderType.none => const SizedBox.square(dimension: 40),
      SyncProviderType.iCloud => const Icon(Icons.cloud, size: 40),
      SyncProviderType.googleDrive => LoggedUserImage(
        image: drawerState.img,
        isUserSignedIn: drawerState.isUserSignedIn,
        radius: 20,
        popContext: false,
      ),
    };
  }
}
