import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/injection.dart';
import 'package:my_expenses/presentation/payment_methods/credit_card_cycles_page.dart';
import 'package:my_expenses/presentation/shared/extensions/i18n_extensions.dart';

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

class _List extends StatelessWidget {
  final List<PaymentMethodItem> items;
  final bool includeArchived;

  const _List({required this.items, required this.includeArchived});

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    final active = items.where((e) => !e.isArchived).toList();
    final archived = items.where((e) => e.isArchived).toList();
    return Column(
      children: [
        SwitchListTile(
          title: Text(i18n.showArchived),
          value: includeArchived,
          onChanged: (v) => context.read<PaymentMethodsBloc>().add(PaymentMethodsEvent.load(includeArchived: v)),
        ),
        Expanded(
          child: includeArchived
              ? ListView(
                  children: [
                    if (active.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(i18n.active, style: Theme.of(context).textTheme.titleMedium),
                      ),
                    if (active.isNotEmpty)
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: active.length,
                        onReorder: (oldIndex, newIndex) => _onReorder(oldIndex, newIndex, active, context),
                        itemBuilder: (context, index) => _ListItem(key: ValueKey(active[index].id), item: active[index]),
                      ),
                    if (archived.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(i18n.archived, style: Theme.of(context).textTheme.titleMedium),
                      ),
                    for (final a in archived) _ListItem(item: a, draggable: false),
                  ],
                )
              : ReorderableListView.builder(
                  itemCount: active.length,
                  onReorder: (oldIndex, newIndex) => _onReorder(oldIndex, newIndex, active, context),
                  itemBuilder: (context, index) => _ListItem(key: ValueKey(active[index].id), item: active[index]),
                ),
        ),
      ],
    );
  }

  void _onReorder(int oldIndex, int newIndex, List<PaymentMethodItem> active, BuildContext context) {
    int nIndex = newIndex;
    final ids = List<int>.from(active.map((e) => e.id));
    if (nIndex > oldIndex) {
      nIndex -= 1;
    }
    final moved = ids.removeAt(oldIndex);
    ids.insert(nIndex, moved);
    context.read<PaymentMethodsBloc>().add(PaymentMethodsEvent.reorder(orderedIds: ids));
  }
}

class _ListItem extends StatelessWidget {
  final PaymentMethodItem item;
  final bool draggable;

  const _ListItem({super.key, required this.item, this.draggable = true});

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    return ListTile(
      leading: Icon(item.icon, color: item.iconColor),
      title: Text(item.name),
      subtitle: Text(i18n.translatePaymentMethodType(item.type)),
      trailing: Container(
        margin: const EdgeInsets.only(right: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showCreateOrEditDialog(context, existing: item),
            ),
            Switch(
              value: item.isArchived,
              onChanged: (v) => context.read<PaymentMethodsBloc>().add(PaymentMethodsEvent.archive(id: item.id, isArchived: v)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCreateOrEditDialog(BuildContext context, {PaymentMethodItem? existing}) {
    return showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<PaymentMethodsBloc>(),
        child: _CreateOrEditDialog(existing: existing),
      ),
    );
  }
}

class _CreateOrEditDialog extends StatefulWidget {
  final PaymentMethodItem? existing;

  const _CreateOrEditDialog({this.existing});

  @override
  State<_CreateOrEditDialog> createState() => _CreateOrEditDialogState();
}

class _CreateOrEditDialogState extends State<_CreateOrEditDialog> {
  PaymentMethodType selectedType = PaymentMethodType.cash;
  late final TextEditingController nameCtrl;
  late final TextEditingController statementCtrl;
  late final TextEditingController dueCtrl;
  late final TextEditingController limitCtrl;

  @override
  void initState() {
    super.initState();
    selectedType = widget.existing?.type ?? PaymentMethodType.cash;
    nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    statementCtrl = TextEditingController(text: widget.existing?.statementCloseDay?.toString() ?? '');
    dueCtrl = TextEditingController(text: widget.existing?.paymentDueDay?.toString() ?? '');
    limitCtrl = TextEditingController(text: widget.existing?.creditLimitMinor?.toString() ?? '');
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    statementCtrl.dispose();
    dueCtrl.dispose();
    limitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);

    return AlertDialog(
      title: Text(widget.existing == null ? i18n.newPaymentMethod : i18n.editPaymentMethod),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(labelText: i18n.name),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<PaymentMethodType>(
              decoration: InputDecoration(labelText: i18n.type),
              initialValue: selectedType,
              items: PaymentMethodType.values
                  .map((val) => DropdownMenuItem(value: val, child: Text(i18n.translatePaymentMethodType(val))))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => selectedType = v);
              },
            ),
            if (selectedType == PaymentMethodType.creditCard) ...[
              const SizedBox(height: 12),
              TextField(
                controller: statementCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: i18n.statementCloseDay),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dueCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: i18n.paymentDueDay),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: limitCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: i18n.creditLimitMinor),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(i18n.cancel)),
        FilledButton(
          onPressed: () {
            final name = nameCtrl.text.trim();
            if (name.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(i18n.nameIsRequired)));
              return;
            }

            // Duplicate check against current list
            final exists = switch (context.read<PaymentMethodsBloc>().state) {
              final PaymentMethodsStateLoadedState s => s.items.any(
                (e) =>
                    e.name.toLowerCase() == name.toLowerCase() && (widget.existing == null ? true : e.id != widget.existing!.id),
              ),
              _ => false,
            };
            if (exists) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(i18n.nameAlreadyExists)));
              return;
            }

            int? statementDay;
            int? dueDay;
            int? creditLimit;
            if (selectedType == PaymentMethodType.creditCard) {
              statementDay = int.tryParse(statementCtrl.text);
              dueDay = int.tryParse(dueCtrl.text);
              creditLimit = int.tryParse(limitCtrl.text);

              bool validDay(int? v) => v != null && v >= 1 && v <= 31;
              if (!validDay(statementDay) || !validDay(dueDay) || (creditLimit ?? -1) < 0) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(i18n.invalidCreditCardFields)));
                return;
              }
            }

            final method = PaymentMethodItem(
              id: widget.existing?.id ?? 0,
              userId: widget.existing?.userId ?? 0,
              // DAO will set
              name: name,
              type: selectedType,
              icon: widget.existing?.icon,
              iconColor: widget.existing?.iconColor,
              statementCloseDay: statementDay ?? widget.existing?.statementCloseDay,
              paymentDueDay: dueDay ?? widget.existing?.paymentDueDay,
              creditLimitMinor: creditLimit ?? widget.existing?.creditLimitMinor,
              isArchived: widget.existing?.isArchived ?? false,
              sortOrder: widget.existing?.sortOrder ?? 0,
            );
            context.read<PaymentMethodsBloc>().add(PaymentMethodsEvent.createOrUpdate(method: method));
            Navigator.pop(context);
          },
          child: Text(i18n.save),
        ),
      ],
    );
  }
}
