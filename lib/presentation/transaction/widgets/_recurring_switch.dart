part of '../add_edit_transaction_page.dart';

class _RecurringSwitch extends StatelessWidget {
  final bool isRecurringTransactionRunning;

  const _RecurringSwitch({required this.isRecurringTransactionRunning});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final i18n = S.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SwitchListTile(
            activeThumbColor: theme.colorScheme.secondary,
            value: isRecurringTransactionRunning,
            title: Text(isRecurringTransactionRunning ? i18n.running : i18n.stopped),
            secondary: Icon(isRecurringTransactionRunning ? Icons.play_arrow : Icons.stop, size: 30),
            subtitle: Text(
              isRecurringTransactionRunning
                  ? i18n.recurringTransactionIsNowRunning
                  : i18n.recurringTransactionIsNowStopped,
            ),
            onChanged: (newValue) => _isRunningChanged(newValue, context),
          ),
        ],
      ),
    );
  }

  void _isRunningChanged(bool newValue, BuildContext context) =>
      context.read<TransactionFormBloc>().add(TransactionFormEvent.isRunningChanged(isRunning: newValue));
}
