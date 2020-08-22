import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/search/search_bloc.dart';
import '../../../common/enums/comparer_type.dart';
import '../../../common/extensions/i18n_extensions.dart';
import '../../../common/extensions/string_extensions.dart';
import '../../../common/styles.dart';
import '../../../generated/i18n.dart';
import '../modal_sheet_separator.dart';
import '../modal_sheet_title.dart';

class SearchAmountFilterBottomSheetDialog extends StatefulWidget {
  final double initialAmount;
  const SearchAmountFilterBottomSheetDialog({
    Key key,
    @required this.initialAmount,
  }) : super(key: key);

  @override
  _SearchAmountFilterBottomSheetDialogState createState() => _SearchAmountFilterBottomSheetDialogState();
}

class _SearchAmountFilterBottomSheetDialogState extends State<SearchAmountFilterBottomSheetDialog> {
  TextEditingController _amountController;

  @override
  void initState() {
    super.initState();

    _amountController = TextEditingController(text: widget.initialAmount?.toString() ?? '');
    _amountController.addListener(_amountChanged);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
    final i18n = I18n.of(context);

    return state.map(
      loading: (_) => [],
      initial: (s) => [
        ModalSheetSeparator(),
        ModalSheetTitle(title: i18n.filterByX(i18n.amount.toLowerCase()), padding: const EdgeInsets.all(0)),
        _buildAmountInput(context),
        if (!_amountController.text.isNullEmptyOrWhitespace) _buildComparerRadioButtons(s.tempComparerType),
        Divider(color: theme.accentColor),
        _buildBottomButtonBar(context),
      ],
    );
  }

  Widget _buildAmountInput(BuildContext context) {
    final i18n = I18n.of(context);
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
            maxLength: 255,
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
    final i18n = I18n.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: ComparerType.values
          .map(
            (e) => ListTile(
              contentPadding: const EdgeInsets.all(0),
              dense: true,
              title: Text(i18n.getComparerTypeName(e)),
              leading: Radio<ComparerType>(value: e, groupValue: selectedComparer, onChanged: _comparererChanged),
            ),
          )
          .toList(),
    );
  }

  Widget _buildBottomButtonBar(BuildContext context) {
    final theme = Theme.of(context);
    final i18n = I18n.of(context);
    return ButtonBar(
      layoutBehavior: ButtonBarLayoutBehavior.constrained,
      buttonPadding: const EdgeInsets.symmetric(horizontal: 20),
      children: <Widget>[
        OutlineButton(
          onPressed: () => _closeModal(context),
          child: Text(i18n.close, style: TextStyle(color: theme.primaryColor)),
        ),
        RaisedButton(
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
        context.bloc<SearchBloc>().tempAmountChanged(null);
        return;
      }
      final amount = double.parse(_amountController.text);
      context.bloc<SearchBloc>().tempAmountChanged(amount.abs());
    } catch (e) {
      _amountController.text = '0';
    }
  }

  void _comparererChanged(ComparerType newValue) => context.bloc<SearchBloc>().tempComparerTypeChanged(newValue);

  void _cleanAmount() => _amountController.clear();

  void _closeModal(BuildContext context) {
    Navigator.pop(context);
  }

  Future<void> _applyAmount(BuildContext context) {
    _closeModal(context);
    return context.bloc<SearchBloc>().applyTempAmount();
  }
}
