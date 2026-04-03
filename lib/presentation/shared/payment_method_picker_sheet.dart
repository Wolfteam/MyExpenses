import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/injection.dart';
import 'package:my_expenses/presentation/shared/extensions/i18n_extensions.dart';

class PaymentMethodPickerSheet extends StatelessWidget {
  final int? initialSelectedId;
  final bool showAllOption;
  /// Called when the user taps an item.
  ///
  /// - `null` — "None/Unknown" (no payment method) when [showAllOption] is false;
  ///   "All" (no filter) when [showAllOption] is true.
  /// - `0` — "None/Unknown" (transactions with no payment method) when [showAllOption] is true.
  /// - positive int — the selected payment method's id.
  final void Function(int?) onSelected;

  const PaymentMethodPickerSheet({
    super.key,
    this.initialSelectedId,
    this.showAllOption = false,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => Injection.paymentMethodPickerBloc
        ..add(PaymentMethodPickerEvent.load(initialSelectedId: initialSelectedId)),
      child: SafeArea(
        child: BlocBuilder<PaymentMethodPickerBloc, PaymentMethodPickerState>(
          builder: (context, state) {
            final i18n = S.of(context);
            final items = switch (state) {
              final PaymentMethodPickerStateLoadedState s => s.items,
              _ => const <PaymentMethodItem>[],
            };
            return ListView(
              shrinkWrap: true,
              children: [
                if (showAllOption) ...[
                  ListTile(
                    leading: const Icon(Icons.all_inclusive),
                    title: Text(i18n.all),
                    selected: initialSelectedId == null,
                    onTap: () {
                      onSelected(null);
                      Navigator.of(context).pop();
                    },
                  ),
                  const Divider(height: 1),
                ],
                ListTile(
                  leading: const Icon(Icons.not_interested),
                  title: Text(i18n.paymentMethodUnknownNone),
                  selected: showAllOption ? initialSelectedId == 0 : initialSelectedId == null,
                  onTap: () {
                    onSelected(showAllOption ? 0 : null);
                    Navigator.of(context).pop();
                  },
                ),
                const Divider(height: 1),
                for (final m in items)
                  ListTile(
                    leading: Icon(m.icon, color: m.iconColor),
                    title: Text(m.name),
                    subtitle: Text(i18n.translatePaymentMethodType(m.type)),
                    selected: initialSelectedId == m.id,
                    onTap: () {
                      onSelected(m.id);
                      Navigator.of(context).pop();
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
