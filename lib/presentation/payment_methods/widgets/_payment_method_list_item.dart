part of '../payment_methods_page.dart';

class _ListItem extends StatelessWidget {
  final PaymentMethodItem item;
  final bool draggable;

  const _ListItem({super.key, required this.item, this.draggable = true});

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    return ListTile(
      leading: item.icon != null ? Icon(item.icon, color: item.iconColor) : null,
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
              onChanged: (v) =>
                  context.read<PaymentMethodsBloc>().add(PaymentMethodsEvent.archive(id: item.id, isArchived: v)),
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
