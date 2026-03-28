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

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with AutomaticKeepAliveClientMixin<SettingsPage> {
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
    return Padding(
      padding: Styles.edgeInsetAll5,
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (ctx, state) => switch (state) {
          SettingsStateLoadingState() => const Center(child: CircularProgressIndicator()),
          SettingsStateInitialState() => LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > _kDesktopBreakpoint;
              final cards = _buildCards(state);
              if (!isDesktop) {
                return ListView(
                  controller: _mobileScrollController,
                  children: cards,
                );
              }
              return _DesktopLayout(cards: cards);
            },
          ),
        },
      ),
    );
  }

  List<Widget> _buildCards(SettingsStateInitialState state) => [
    AppearanceSettingsCard(
      appThemeType: state.appTheme,
      accentColorType: state.accentColor,
    ),
    LanguageSettingsCard(language: state.appLanguage),
    CurrencySettingsCard(
      currencySymbolType: state.currencySymbol,
      currencyToTheRight: state.currencyToTheRight,
    ),
    SecuritySettingsCard(
      askForPassword: state.askForPassword,
      canUseFingerPrint: state.canUseFingerPrint,
      askForFingerPrint: state.askForFingerPrint,
    ),
    NotificationsSettingsCard(
      showNotificationForRecurringTrans: state.showNotificationForRecurringTrans,
      showNotificationAfterFullSync: state.showNotificationAfterFullSync,
    ),
    if (state.isUserLoggedIn)
      SyncSettingsCard(syncIntervalType: state.syncInterval),
    const PaymentMethodsSettingsCard(),
    const DataManagementSettingsCard(),
    AboutSettingsCard(appVersion: state.appVersion),
  ];
}

class _DesktopLayout extends StatefulWidget {
  final List<Widget> cards;
  const _DesktopLayout({required this.cards});

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
    final allCards = widget.cards;
    final rows = <Widget>[];
    for (int i = 0; i < allCards.length - 1; i += 2) {
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: allCards[i]),
              if (i + 1 < allCards.length - 1)
                Expanded(child: allCards[i + 1])
              else
                const Expanded(child: SizedBox()),
            ],
          ),
        ),
      );
    }
    rows.add(allCards.last);

    return ListView(
      controller: _scrollController,
      children: rows,
    );
  }
}
