part of '../add_edit_transaction_page.dart';

class _DescriptionInput extends StatelessWidget {
  final TextEditingController descriptionController;
  final FocusNode descriptionFocus;
  final bool isChildTransaction;
  final bool isDescriptionDirty;
  final bool isDescriptionValid;
  final OnInputSubmit onSubmit;

  const _DescriptionInput({
    required this.descriptionController,
    required this.descriptionFocus,
    required this.isChildTransaction,
    required this.isDescriptionDirty,
    required this.isDescriptionValid,
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
            controller: descriptionController,
            keyboardType: TextInputType.text,
            minLines: 1,
            maxLength: TransactionFormBloc.maxDescriptionLength,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            focusNode: descriptionFocus,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              suffixIcon: InputSuffixIcon(controller: descriptionController, focusNode: descriptionFocus),
              alignLabelWithHint: true,
              labelText: i18n.description,
              hintText: i18n.descriptionOfThisTransaction,
            ),
            autovalidateMode: isDescriptionDirty ? AutovalidateMode.always : null,
            onFieldSubmitted: (_) => onSubmit(),
            validator: (_) => isDescriptionValid ? null : i18n.invalidDescription,
          ),
        ),
      ],
    );
  }
}
