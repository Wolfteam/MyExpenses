import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/generated/l10n.dart';

class FormAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool toEditTransaction;
  final bool isChildTransaction;
  final bool isNewTransaction;
  final bool isParentTransaction;
  final bool isFormValid;

  final String description;

  const FormAppBar({
    super.key,
    required this.toEditTransaction,
    required this.isChildTransaction,
    required this.isNewTransaction,
    required this.isParentTransaction,
    required this.isFormValid,
    required this.description,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    return AppBar(
      title: Text(!toEditTransaction ? i18n.addTransaction : i18n.editTransaction),
      leading: const BackButton(),
      actions: [
        if (!isChildTransaction)
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: isFormValid ? () => _saveTransaction(context) : null,
          ),
        if (!isNewTransaction && !isChildTransaction)
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmationDialog(context, description, isParentTransaction),
          ),
      ],
    );
  }

  void _saveTransaction(BuildContext context) {
    context.read<TransactionFormBloc>().add(const TransactionFormEvent.submit());
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context, String description, bool isParentTransaction) {
    final i18n = S.of(context);
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(i18n.deleteX(description)),
        content: Text(i18n.confirmDeleteTransaction),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text(i18n.close),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();

              if (isParentTransaction) {
                _showDeleteChildrenConfirmationDialog(context);
              } else {
                context.read<TransactionFormBloc>().add(const TransactionFormEvent.deleteTransaction(keepChildren: false));
              }
            },
            child: Text(i18n.yes),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteChildrenConfirmationDialog(BuildContext context) {
    final i18n = S.of(context);
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(i18n.deleteX(i18n.childTransactions.toLowerCase())),
        content: Text(i18n.deleteChildTransactionsConfirmation),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              context.read<TransactionFormBloc>().add(const TransactionFormEvent.deleteTransaction(keepChildren: true));
              Navigator.of(ctx).pop();
            },
            child: Text(i18n.no),
          ),
          FilledButton(
            onPressed: () {
              context.read<TransactionFormBloc>().add(const TransactionFormEvent.deleteTransaction(keepChildren: false));
              Navigator.of(ctx).pop();
            },
            child: Text(i18n.yes),
          ),
        ],
      ),
    );
  }
}
