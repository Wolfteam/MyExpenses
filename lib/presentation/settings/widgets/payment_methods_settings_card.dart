import 'package:flutter/material.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/payment_methods/payment_methods_page.dart';
import 'package:my_expenses/presentation/settings/widgets/settings_card.dart';

class PaymentMethodsSettingsCard extends StatelessWidget {
  const PaymentMethodsSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      child: ListTile(
        leading: const Icon(Icons.account_balance_wallet_outlined),
        trailing: const Icon(Icons.chevron_right),
        title: Text(S.of(context).paymentMethods),
        subtitle: Text(S.of(context).paymentMethodsSubtitle),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PaymentMethodsPage()),
        ),
      ),
    );
  }
}
