import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:my_expenses/generated/i18n.dart';
import 'package:provider/provider.dart';

import '../../bloc/transaction_form/transaction_form_bloc.dart';
import '../../bloc/transactions/transactions_bloc.dart';
import '../../common/enums/repetition_cycle_type.dart';
import '../../common/extensions/string_extensions.dart';
import '../../common/utils/repetition_cycle_utils.dart';
import '../../common/utils/toast_utils.dart';
import '../../models/category_item.dart';
import '../../models/current_selected_category.dart';
import '../../models/transaction_item.dart';
import 'categories_page.dart';

//TODO: IF THE SELECTED CATEGORY IS AN EXPENSE, YOU MUST SET A NEGATIVE AMOUNT
class AddEditTransactionPage extends StatefulWidget {
  final TransactionItem item;

  const AddEditTransactionPage({this.item});

  @override
  _AddEditTransactionPageState createState() => _AddEditTransactionPageState();
}

class _AddEditTransactionPageState extends State<AddEditTransactionPage> {
  TextEditingController _amountController;
  TextEditingController _descriptionController;
  TextEditingController _repetitionsController;

  final FocusNode _amountFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();
  final FocusNode _repetitionsFocus = FocusNode();

  final _dateFormat = DateFormat('MM/dd/yyyy');

  final _formKey = GlobalKey<FormState>();
  bool _didChangeDependencies = false;

  final _repetitionCycles = [
    RepetitionCycleType.none,
    RepetitionCycleType.eachDay,
    RepetitionCycleType.eachWeek,
    RepetitionCycleType.eachMonth,
    RepetitionCycleType.eachYear
  ];

  @override
  void initState() {
    final double amount = widget.item?.amount ?? 0;
    final description = widget.item?.description ?? '';
    final repetitions = widget.item?.repetitions ?? 0;

    _amountController = TextEditingController(text: '$amount');
    _descriptionController = TextEditingController(text: description);
    _repetitionsController = TextEditingController(text: '$repetitions');

    _amountController.addListener(_amountChanged);
    _descriptionController.addListener(_descriptionChanged);
    _repetitionsController.addListener(_repetitionsChanged);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didChangeDependencies) return;
    if (widget.item != null) {
      context.bloc<TransactionFormBloc>().add(EditTransaction(widget.item));
    } else {
      context.bloc<TransactionFormBloc>().add(AddTransaction());
    }

    _didChangeDependencies = true;
  }

  @override
  Widget build(BuildContext context) {
    final i18n = I18n.of(context);

    return BlocBuilder<TransactionFormBloc, TransactionFormState>(
      builder: (ctx, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.item == null ? i18n.addTransaction : i18n.editTransaction,
            ),
            leading: const BackButton(),
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.save,
                ),
                onPressed:
                    state is TransactionFormLoadedState && state.isFormValid
                        ? _saveTransaction
                        : null,
              ),
              if (widget.item != null)
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: state is TransactionFormLoadedState
                      ? () {
                          _showDeleteConfirmationDialog(state.description);
                        }
                      : null,
                ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: _buildPage(ctx, state),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _repetitionsController.dispose();
    super.dispose();
  }

  List<Widget> _buildPage(BuildContext context, TransactionFormState state) {
    if (state is TransactionFormLoadedState) {
      if (!state.error.isNullEmptyOrWhitespace) {
        showWarningToast(state.error);
      }

      return [_buildHeader(context, state), _buildForm(context, state)];
    }

    if (state is TransactionSavedState || state is TransactionDeletedState) {
      final i18n = I18n.of(context);
      final msg = state is TransactionSavedState
          ? i18n.transactionsWasSuccessfullySaved
          : i18n.transactionsWasSuccessfullyDeleted;
      showSucceedToast(msg);

      final now = DateTime.now();
      context.bloc<TransactionsBloc>().add(GetTransactions(inThisDate: now));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
      });
    }

    return [];
  }

  Container _buildHeader(
    final BuildContext context,
    final TransactionFormLoadedState state,
  ) {
    final createdAt = _dateFormat.format(state.transactionDate);
    const cornerRadius = Radius.circular(20);
    final theme = Theme.of(context);
    final i18n = I18n.of(context);

    return Container(
      height: 240.0,
      child: Stack(
        children: <Widget>[
          Container(
            height: 150,
            color: state.category.iconColor,
          ),
          Container(
            padding: const EdgeInsets.only(
              top: 40.0,
              left: 20.0,
              right: 20.0,
              bottom: 10.0,
            ),
            child: Material(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: cornerRadius,
                  bottomRight: cornerRadius,
                  topLeft: cornerRadius,
                  topRight: cornerRadius,
                ),
              ),
              elevation: 5.0,
              child: Column(
                children: <Widget>[
                  const SizedBox(
                    height: 50.0,
                  ),
                  Text(
                    state.description,
                    style: Theme.of(context).textTheme.title,
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    '${i18n.date}: $createdAt',
                    style: theme.textTheme.subtitle,
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  Container(
                    height: 40.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: ListTile(
                            title: Text(
                              '${state.amount} \$',
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.title,
                            ),
                            subtitle: Text(
                              i18n.amount.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.caption,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: Text(
                              state.category.isAnIncome
                                  ? i18n.income
                                  : i18n.expense,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.title,
                            ),
                            subtitle: Text(
                              i18n.category.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.caption,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: Text(
                              getRepetitionCycleTypeName(state.repetitionCycle),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.title,
                            ),
                            subtitle: Text(
                              i18n.repetitions.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.caption,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Material(
                  elevation: 10,
                  shape: const CircleBorder(),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 40.0,
                    child: Center(
                      child: IconButton(
                        iconSize: 50,
                        icon: Icon(state.category.icon),
                        color: state.category.iconColor,
                        onPressed: () => _changeCategory(state),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(
    final BuildContext context,
    final TransactionFormLoadedState state,
  ) {
    final transactionDate = _dateFormat.format(state.transactionDate);
    final theme = Theme.of(context);
    final i18n = I18n.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildAmountInput(context, state),
            _buildDescriptionInput(state),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.calendar_today,
                  size: 30,
                ),
                Expanded(
                  child: FlatButton(
                    onPressed: _transactionDateClicked,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(transactionDate),
                    ),
                  ),
                ),
              ],
            ),
            _buildRepetitionsInput(state),
            if (state.areRepetitionCyclesVisible)
              _buildRepetitionCyclesDropDown(state),
            Text(
              i18n.addPicture,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: <Widget>[
                FlatButton.icon(
                  textColor: theme.primaryColor,
                  onPressed: () {},
                  icon: Icon(Icons.photo_library),
                  label: Text(i18n.fromGallery),
                ),
                FlatButton.icon(
                  textColor: theme.primaryColor,
                  onPressed: () {},
                  icon: Icon(Icons.camera_enhance),
                  label: Text(i18n.fromCamera),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInput(
    final BuildContext context,
    final TransactionFormLoadedState state,
  ) {
    final suffixIcon = _buildSuffixIconButton(
      _amountController,
      _amountFocus,
    );
    final i18n = I18n.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(right: 10),
          child: Icon(
            Icons.attach_money,
            size: 30,
          ),
        ),
        Expanded(
          child: TextFormField(
            controller: _amountController,
            maxLines: 1,
            minLines: 1,
            maxLength: 255,
            focusNode: _amountFocus,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              suffixIcon: suffixIcon,
              alignLabelWithHint: true,
              hintText: '0\$',
              labelText: i18n.amount,
            ),
            autovalidate: state.isAmountDirty,
            onFieldSubmitted: (_) {
              _fieldFocusChange(context, _amountFocus, _descriptionFocus);
            },
            validator: (_) => state.isAmountValid ? null : i18n.invalidAmount,
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionInput(
    final TransactionFormLoadedState state,
  ) {
    final suffixIcon = _buildSuffixIconButton(
      _descriptionController,
      _descriptionFocus,
    );
    final i18n = I18n.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(right: 10),
          child: Icon(
            Icons.note,
            size: 30,
          ),
        ),
        Expanded(
          child: TextFormField(
            controller: _descriptionController,
            keyboardType: TextInputType.text,
            maxLines: 2,
            minLines: 1,
            maxLength: 255,
            focusNode: _descriptionFocus,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              suffixIcon: suffixIcon,
              alignLabelWithHint: true,
              labelText: i18n.description,
              hintText: i18n.descriptionOfThisTransaction,
            ),
            autovalidate: state.isDescriptionDirty,
            onFieldSubmitted: (_) {
              _fieldFocusChange(
                context,
                _descriptionFocus,
                _repetitionsFocus,
              );
            },
            validator: (_) =>
                state.isDescriptionValid ? null : i18n.invalidDescription,
          ),
        ),
      ],
    );
  }

  Widget _buildRepetitionsInput(
    final TransactionFormLoadedState state,
  ) {
    final suffixIcon = _buildSuffixIconButton(
      _repetitionsController,
      _repetitionsFocus,
    );
final i18n = I18n.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(right: 10),
          child: Icon(
            Icons.repeat_one,
            size: 30,
          ),
        ),
        Expanded(
          child: TextFormField(
            controller: _repetitionsController,
            maxLines: 1,
            minLines: 1,
            maxLength: 255,
            focusNode: _repetitionsFocus,
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              suffixIcon: suffixIcon,
              hintText: '0',
              alignLabelWithHint: true,
              labelText: i18n.repetitions,
            ),
            autovalidate: state.isRepetitionsDirty,
            onFieldSubmitted: (_) {
              _repetitionsFocus.unfocus();
            },
            validator: (_) =>
                state.isRepetitionsValid ? null : i18n.invalidRepetitions,
          ),
        ),
      ],
    );
  }

  Widget _buildRepetitionCyclesDropDown(
    final TransactionFormLoadedState state,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Icon(
          Icons.date_range,
          size: 30,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
            ),
            child: DropdownButton<RepetitionCycleType>(
              isExpanded: true,
              hint: Text(
                getRepetitionCycleTypeName(state.repetitionCycle),
                style: TextStyle(color: Colors.red),
              ),
              value: state.repetitionCycle,
              iconSize: 24,
              underline: Container(
                height: 0,
                color: Colors.transparent,
              ),
              onChanged: _repetitionCycleChanged,
              items: _repetitionCycles
                  .map<DropdownMenuItem<RepetitionCycleType>>((value) {
                return DropdownMenuItem<RepetitionCycleType>(
                  value: value,
                  child: Text(getRepetitionCycleTypeName(value)),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuffixIconButton(
    TextEditingController controller,
    FocusNode focusNode,
  ) {
    final suffixIcon =
        !controller.text.isNullEmptyOrWhitespace && focusNode.hasFocus
            ? IconButton(
                alignment: Alignment.bottomCenter,
                icon: Icon(Icons.close),
                onPressed: () =>
                    //For some reason an exception is thrown https://github.com/flutter/flutter/issues/35848
                    Future.microtask(() => controller.clear()),
              )
            : null;

    return suffixIcon;
  }

  void _amountChanged() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    context.bloc<TransactionFormBloc>().add(AmountChanged(amount));
  }

  void _descriptionChanged() {
    context
        .bloc<TransactionFormBloc>()
        .add(DescriptionChanged(_descriptionController.text));
  }

  void _repetitionsChanged() {
    final repetitions = int.tryParse(_repetitionsController.text) ?? 0;
    context.bloc<TransactionFormBloc>().add(RepetitionsChanged(repetitions));
  }

  void _repetitionCycleChanged(RepetitionCycleType newValue) {
    context.bloc<TransactionFormBloc>().add(RepetitionCycleChanged(newValue));
  }

  Future _transactionDateClicked() async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );
    context
        .bloc<TransactionFormBloc>()
        .add(TransactionDateChanged(selectedDate));
  }

  void _fieldFocusChange(
    BuildContext context,
    FocusNode currentFocus,
    FocusNode nextFocus,
  ) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  Future _changeCategory(TransactionFormLoadedState state) async {
    final selectedCatProvider = Provider.of<CurrentSelectedCategory>(
      context,
      listen: false,
    );

    if (state.category.id > 0) {
      selectedCatProvider.currentSelectedItem = state.category;
    }

    final route = MaterialPageRoute<CategoryItem>(
      builder: (ctx) => CategoriesPage(
        isInSelectionMode: true,
        selectedCategory: state.category,
      ),
    );
    final selectedCat = await Navigator.of(context).push(route);

    selectedCatProvider.currentSelectedItem = null;

    if (selectedCat != null) {
      context.bloc<TransactionFormBloc>().add(CategoryWasUpdated(selectedCat));
    }
  }

  void _saveTransaction() {
    context.bloc<TransactionFormBloc>().add(FormSubmitted());
  }

  void _showDeleteConfirmationDialog(String transDescription) {
    final i18n = I18n.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(i18n.deleteX(transDescription)),
        content: Text(i18n.confirmDeleteTransaction),
        actions: <Widget>[
          OutlineButton(
            textColor: Theme.of(context).primaryColor,
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text(
              i18n.close
            ),
          ),
          RaisedButton(
            color: Theme.of(ctx).primaryColor,
            onPressed: () {
              context.bloc<TransactionFormBloc>().add(DeleteTransaction());
              Navigator.of(ctx).pop();
            },
            child: Text(i18n.yes),
          ),
        ],
      ),
    );
  }
}
