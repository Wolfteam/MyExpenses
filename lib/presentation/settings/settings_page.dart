import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/presentation/settings/widgets/about_settings_card.dart';
import 'package:my_expenses/presentation/settings/widgets/appearance_settings_card.dart';
import 'package:my_expenses/presentation/settings/widgets/currency_settings_card.dart';
import 'package:my_expenses/presentation/settings/widgets/data_management_settings_card.dart';
import 'package:my_expenses/presentation/settings/widgets/language_settings_card.dart';
import 'package:my_expenses/presentation/settings/widgets/notifications_settings_card.dart';
import 'package:my_expenses/presentation/settings/widgets/payment_methods_settings_card.dart';
import 'package:my_expenses/presentation/settings/widgets/security_settings_card.dart';
import 'package:my_expenses/presentation/settings/widgets/sync_settings_card.dart';
import 'package:my_expenses/presentation/shared/styles.dart';

const double _kDesktopBreakpoint = 600;

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Styles.edgeInsetAll5,
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (ctx, state) => switch (state) {
          SettingsStateLoadingState() => const Center(child: CircularProgressIndicator()),
          SettingsStateInitialState() => LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > _kDesktopBreakpoint;
              if (!isDesktop) {
                return _MobileLayout(state: state);
              }
              return _DesktopLayout(state: state);
            },
          ),
        },
      ),
    );
  }
}

class _MobileLayout extends StatefulWidget {
  final SettingsStateInitialState state;

  const _MobileLayout({required this.state});

  @override
  State<_MobileLayout> createState() => _MobileLayoutState();
}

class _MobileLayoutState extends State<_MobileLayout> with AutomaticKeepAliveClientMixin<_MobileLayout> {
  final _mobileScrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _mobileScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      controller: _mobileScrollController,
      children: [
        AppearanceSettingsCard(
          appThemeType: widget.state.appTheme,
          accentColorType: widget.state.accentColor,
        ),
        LanguageSettingsCard(language: widget.state.appLanguage),
        CurrencySettingsCard(
          currencySymbolType: widget.state.currencySymbol,
          currencyToTheRight: widget.state.currencyToTheRight,
        ),
        SecuritySettingsCard(
          askForPassword: widget.state.askForPassword,
          canUseFingerPrint: widget.state.canUseFingerPrint,
          askForFingerPrint: widget.state.askForFingerPrint,
        ),
        NotificationsSettingsCard(
          showNotificationForRecurringTrans: widget.state.showNotificationForRecurringTrans,
          showNotificationAfterFullSync: widget.state.showNotificationAfterFullSync,
        ),
        SyncSettingsCard(
          syncIntervalType: widget.state.syncInterval,
          syncProviderType: widget.state.syncProvider,
        ),
        const PaymentMethodsSettingsCard(),
        const DataManagementSettingsCard(),
        AboutSettingsCard(appVersion: widget.state.appVersion),
      ],
    );
  }
}

class _DesktopLayout extends StatefulWidget {
  final SettingsStateInitialState state;

  const _DesktopLayout({required this.state});

  @override
  State<_DesktopLayout> createState() => _DesktopLayoutState();
}

class _DesktopLayoutState extends State<_DesktopLayout> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: _scrollController,
      children: [
        _DesktopRow(
          left: AppearanceSettingsCard(
            appThemeType: widget.state.appTheme,
            accentColorType: widget.state.accentColor,
          ),
          right: LanguageSettingsCard(language: widget.state.appLanguage),
        ),
        _DesktopRow(
          left: CurrencySettingsCard(
            currencySymbolType: widget.state.currencySymbol,
            currencyToTheRight: widget.state.currencyToTheRight,
          ),
          right: SecuritySettingsCard(
            askForPassword: widget.state.askForPassword,
            canUseFingerPrint: widget.state.canUseFingerPrint,
            askForFingerPrint: widget.state.askForFingerPrint,
          ),
        ),
        _DesktopRow(
          left: NotificationsSettingsCard(
            showNotificationForRecurringTrans: widget.state.showNotificationForRecurringTrans,
            showNotificationAfterFullSync: widget.state.showNotificationAfterFullSync,
          ),
          right: const DataManagementSettingsCard(),
        ),
        _DesktopRow(
          left: const PaymentMethodsSettingsCard(),
          right: SyncSettingsCard(
            syncIntervalType: widget.state.syncInterval,
            syncProviderType: widget.state.syncProvider,
          ),
        ),
        Row(
          children: [
            const Spacer(flex: 30),
            Flexible(
              flex: 70,
              fit: FlexFit.tight,
              child: AboutSettingsCard(appVersion: widget.state.appVersion),
            ),
            const Spacer(flex: 30),
          ],
        ),
      ],
    );
  }
}

class _DesktopRow extends StatelessWidget {
  final Widget right;
  final Widget left;
  const _DesktopRow({required this.right, required this.left});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(child: left),
          Expanded(child: right),
        ],
      ),
    );
  }
}
