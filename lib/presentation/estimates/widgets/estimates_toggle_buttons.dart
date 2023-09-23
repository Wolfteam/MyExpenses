import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/shared/custom_icons.dart';

class EstimatesToggleButtons extends StatelessWidget {
  final List<bool> selectedButtons;

  const EstimatesToggleButtons({super.key, required this.selectedButtons});

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: LayoutBuilder(
        builder: (ctx, constraints) => Center(
          child: ToggleButtons(
            constraints: BoxConstraints.expand(width: (constraints.minWidth - 20) / 3, height: 36),
            onPressed: (int index) => _transactionTypeChanged(context, index),
            isSelected: selectedButtons,
            borderRadius: BorderRadius.circular(5),
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(Icons.select_all, size: 16.0, color: Colors.blue),
                  const SizedBox(width: 4.0),
                  Text(i18n.all, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.blue)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(CustomIcons.money, size: 16.0, color: Colors.green),
                  const SizedBox(width: 4.0),
                  Text(i18n.incomes, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.green)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(Icons.money_off, size: 16.0, color: Colors.red),
                  const SizedBox(width: 4.0),
                  Text(i18n.expenses, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.red)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _transactionTypeChanged(BuildContext context, int newValue) =>
      context.read<EstimatesBloc>().add(EstimatesEvent.transactionTypeChanged(newValue: newValue));
}
