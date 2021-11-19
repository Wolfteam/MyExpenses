import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/extensions/string_extensions.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/shared/extensions/i18n_extensions.dart';
import 'package:my_expenses/presentation/shared/modal_sheet_separator.dart';
import 'package:my_expenses/presentation/shared/modal_sheet_title.dart';
import 'package:my_expenses/presentation/shared/styles.dart';

class SearchAmountFilterBottomSheetDialog extends StatefulWidget {
  final double? initialAmount;

  const SearchAmountFilterBottomSheetDialog({
    Key? key,
    required this.initialAmount,
  }) : super(key: key);

  @override
  _SearchAmountFilterBottomSheetDialogState createState() => _SearchAmountFilterBottomSheetDialogState();
}

class _SearchAmountFilterBottomSheetDialogState extends State<SearchAmountFilterBottomSheetDialog> {
  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();

    _amountController = TextEditingController(text: widget.initialAmount?.toString() ?? '');
    _amountController.addListener(_amountChanged);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: Styles.modalBottomSheetContainerMargin,
        padding: Styles.modalBottomSheetContainerPadding,
        child: BlocBuilder<SearchBloc, SearchState>(
          builder: (ctx, state) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[..._buildPage(state)],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPage(SearchState state) {
    final theme = Theme.of(context);
    final i18n = S.of(context);

    return state.map(
      loading: (_) => [],
      initial: (s) => [
        ModalSheetSeparator(),
        ModalSheetTitle(title: i18n.filterByX(i18n.amount.toLowerCase()), padding: EdgeInsets.zero),
        _buildAmountInput(context),
        if (!_amountController.text.isNullEmptyOrWhitespace) _buildComparerRadioButtons(s.tempComparerType),
        Divider(color: theme.colorScheme.secondary),
        _buildBottomButtonBar(context),
      ],
    );
  }

  Widget _buildAmountInput(BuildContext context) {
    final i18n = S.of(context);
    final suffixIcon = _amountController.text.isNotEmpty
        ? IconButton(
            alignment: Alignment.bottomCenter,
            icon: const Icon(Icons.close),
            onPressed: _cleanAmount,
          )
        : null;

    return Row(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(right: 10),
          child: const Icon(Icons.attach_money, size: 30),
        ),
        Expanded(
          child: TextFormField(
            enabled: true,
            controller: _amountController,
            minLines: 1,
            maxLength: TransactionFormBloc.maxAmountLength,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              suffixIcon: suffixIcon,
              alignLabelWithHint: true,
              hintText: '0\$',
              labelText: i18n.amount,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComparerRadioButtons(ComparerType selectedComparer) {
    final i18n = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: ComparerType.values
          .map(
            (e) => ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(i18n.getComparerTypeName(e)),
              leading: Radio<ComparerType>(value: e, groupValue: selectedComparer, onChanged: (v) => _comparerChanged(v!)),
            ),
          )
          .toList(),
    );
  }

  Widget _buildBottomButtonBar(BuildContext context) {
    final theme = Theme.of(context);
    final i18n = S.of(context);
    return ButtonBar(
      layoutBehavior: ButtonBarLayoutBehavior.constrained,
      children: <Widget>[
        OutlinedButton(
          onPressed: () => _closeModal(context),
          child: Text(i18n.close, style: TextStyle(color: theme.primaryColor)),
        ),
        ElevatedButton(
          onPressed: () => _applyAmount(context),
          child: Text(i18n.apply),
        ),
      ],
    );
  }

  void _amountChanged() {
    //TODO: CHECK NEGATIVE VALUES
    try {
      if (_amountController.text.isNullEmptyOrWhitespace) {
        context.read<SearchBloc>().add(const SearchEvent.tempAmountChanged());
        return;
      }
      final amount = double.parse(_amountController.text);
      context.read<SearchBloc>().add(SearchEvent.tempAmountChanged(newValue: amount.abs()));
    } catch (e) {
      _amountController.text = '0';
    }
  }

  void _comparerChanged(ComparerType newValue) => context.read<SearchBloc>().add(SearchEvent.tempComparerTypeChanged(newValue: newValue));

  void _cleanAmount() => _amountController.clear();

  void _closeModal(BuildContext context) {
    Navigator.pop(context);
  }

  void _applyAmount(BuildContext context) {
    _closeModal(context);
    context.read<SearchBloc>().add(const SearchEvent.applyTempAmount());
  }
}
