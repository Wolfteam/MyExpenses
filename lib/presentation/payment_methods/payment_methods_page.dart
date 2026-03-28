import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/injection.dart';
import 'package:my_expenses/presentation/payment_methods/credit_card_cycles_page.dart';
import 'package:my_expenses/presentation/shared/custom_icons.dart';
import 'package:my_expenses/presentation/shared/extensions/i18n_extensions.dart';

part 'widgets/payment_method_list.dart';
part 'widgets/payment_method_list_item.dart';
part 'widgets/payment_method_form_dialog.dart';

class PaymentMethodsPage extends StatelessWidget {
  const PaymentMethodsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => Injection.paymentMethodsBloc..add(const PaymentMethodsEvent.load()),
      child: const _Page(),
    );
  }
}

class _Page extends StatelessWidget {
  const _Page();

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(i18n.paymentMethods),
        actions: [
          IconButton(
            tooltip: i18n.creditCardCycles,
            icon: const Icon(Icons.date_range),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CreditCardCyclesPage()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateOrEditDialog(context),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<PaymentMethodsBloc, PaymentMethodsState>(
        builder: (context, state) {
          switch (state) {
            case PaymentMethodsStateLoadingState():
              return const Center(child: CircularProgressIndicator());
            case final PaymentMethodsStateLoadedState state:
              final active = state.items.where((e) => !e.isArchived).toList();

              if (!state.includeArchived && active.isEmpty) {
                return Center(child: Text(i18n.noPaymentMethodsYet));
              }

              return _List(items: state.items, includeArchived: state.includeArchived);
          }
        },
      ),
    );
  }

  Future<void> _showCreateOrEditDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<PaymentMethodsBloc>(),
        child: const _CreateOrEditDialog(),
      ),
    );
  }
}
