part of '../add_edit_transaction_page.dart';

class _LongDescriptionInput extends StatelessWidget {
  final TextEditingController longDescriptionController;
  final FocusNode longDescriptionFocus;
  final bool isChildTransaction;
  final bool isLongDescriptionDirty;
  final bool isLongDescriptionValid;
  final OnInputSubmit onSubmit;

  const _LongDescriptionInput({
    required this.longDescriptionController,
    required this.longDescriptionFocus,
    required this.isChildTransaction,
    required this.isLongDescriptionDirty,
    required this.isLongDescriptionValid,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);

    return Row(
      children: <Widget>[
        Container(margin: const EdgeInsets.only(right: 10), child: const Icon(Icons.note, size: 30)),
        Expanded(
          child: TextFormField(
            enabled: !isChildTransaction,
            controller: longDescriptionController,
            keyboardType: TextInputType.text,
            maxLines: 5,
            minLines: 1,
            maxLength: TransactionFormBloc.maxLongDescriptionLength,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            focusNode: longDescriptionFocus,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              suffixIcon: InputSuffixIcon(controller: longDescriptionController, focusNode: longDescriptionFocus),
              alignLabelWithHint: true,
              labelText: i18n.longDescription,
              hintText: i18n.descriptionOfThisTransaction,
              hintMaxLines: 1,
            ),
            autovalidateMode: isLongDescriptionDirty ? AutovalidateMode.always : null,
            onFieldSubmitted: (_) => onSubmit(),
            validator: (_) => isLongDescriptionValid ? null : i18n.invalidDescription,
          ),
        ),
      ],
    );
  }
}
