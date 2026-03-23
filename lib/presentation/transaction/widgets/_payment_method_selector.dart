part of '../add_edit_transaction_page.dart';

class _PaymentMethodSelector extends StatelessWidget {
  final int? paymentMethodId;
  final bool isChildTransaction;

  const _PaymentMethodSelector({required this.paymentMethodId, required this.isChildTransaction});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => Injection.paymentMethodPickerBloc
        ..add(PaymentMethodPickerEvent.load(initialSelectedId: paymentMethodId)),
      child: Builder(
        builder: (context) {
          return BlocBuilder<PaymentMethodPickerBloc, PaymentMethodPickerState>(
            builder: (context, pickerState) {
              final i18n = S.of(context);
              final selectedName = () {
                if (paymentMethodId == null) return i18n.paymentMethodUnknownNone;
                final items = switch (pickerState) {
                  final PaymentMethodPickerStateLoadedState s => s.items,
                  _ => const <PaymentMethodItem>[],
                };
                final m = items
                    .where((e) => e.id == paymentMethodId)
                    .cast<PaymentMethodItem?>()
                    .firstWhere(
                      (e) => e != null,
                      orElse: () => null,
                    );
                return m?.name ?? i18n.paymentMethodUnknownNone;
              }();

              return ListTile(
                contentPadding: EdgeInsets.zero,
                enabled: !isChildTransaction,
                leading: const Icon(Icons.account_balance_wallet_outlined),
                title: Text(i18n.paymentMethodFieldTitle),
                subtitle: Text(selectedName),
                onTap: isChildTransaction
                    ? null
                    : () => showModalBottomSheet(
                        shape: Styles.modalBottomSheetShape,
                        context: context,
                        builder: (_) => PaymentMethodPickerSheet(
                          initialSelectedId: paymentMethodId,
                          onSelected: (id) => context.read<TransactionFormBloc>().add(
                            TransactionFormEvent.paymentMethodChanged(paymentMethodId: id),
                          ),
                        ),
                      ),
                trailing: paymentMethodId != null && !isChildTransaction
                    ? IconButton(
                        tooltip: i18n.clear,
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          context.read<TransactionFormBloc>().add(
                            const TransactionFormEvent.paymentMethodChanged(paymentMethodId: null),
                          );
                        },
                      )
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}
