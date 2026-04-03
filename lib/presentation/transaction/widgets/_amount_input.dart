part of '../add_edit_transaction_page.dart';

typedef OnInputSubmit = void Function();

class _AmountInput extends StatelessWidget {
  final TextEditingController amountController;
  final FocusNode amountFocus;
  final bool isChildTransaction;
  final bool isAmountValid;
  final bool isAmountDirty;
  final OnInputSubmit onSubmit;

  const _AmountInput({
    required this.amountController,
    required this.amountFocus,
    required this.isChildTransaction,
    required this.isAmountValid,
    required this.isAmountDirty,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);

    return Row(
      children: <Widget>[
        Container(margin: const EdgeInsets.only(right: 10), child: const Icon(Icons.attach_money, size: 30)),
        Expanded(
          child: TextFormField(
            enabled: !isChildTransaction,
            controller: amountController,
            minLines: 1,
            maxLength: TransactionFormBloc.maxAmountLength,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            focusNode: amountFocus,
            textInputAction: TextInputAction.next,
            keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
            decoration: InputDecoration(
              suffixIcon: InputSuffixIcon(controller: amountController, focusNode: amountFocus),
              alignLabelWithHint: true,
              hintText: '0\$',
              labelText: i18n.amount,
            ),
            autovalidateMode: isAmountDirty ? AutovalidateMode.always : null,
            onFieldSubmitted: (_) => onSubmit(),
            validator: (_) => isAmountValid ? null : i18n.invalidAmount,
          ),
        ),
      ],
    );
  }
}
