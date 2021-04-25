import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_expenses/common/enums/app_language_type.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../bloc/charts/charts_bloc.dart';
import '../../bloc/currency/currency_bloc.dart';
import '../../bloc/transaction_form/transaction_form_bloc.dart';
import '../../bloc/transactions/transactions_bloc.dart';
import '../../common/enums/repetition_cycle_type.dart';
import '../../common/extensions/i18n_extensions.dart';
import '../../common/extensions/string_extensions.dart';
import '../../common/utils/bloc_utils.dart';
import '../../common/utils/date_utils.dart' as utils;
import '../../common/utils/i18n_utils.dart';
import '../../common/utils/toast_utils.dart';
import '../../models/category_item.dart';
import '../../models/current_selected_category.dart';
import '../../models/transaction_item.dart';
import 'categories_page.dart';

class AddEditTransactionPage extends StatelessWidget {
  final TransactionItem? item;

  const AddEditTransactionPage({
    this.item,
  });

  static MaterialPageRoute addRoute(BuildContext context) {
    context.read<TransactionFormBloc>().add(const TransactionFormEvent.add());
    return MaterialPageRoute(builder: (ctx) => const AddEditTransactionPage());
  }

  static MaterialPageRoute editRoute(TransactionItem transaction, BuildContext context) {
    context.read<TransactionFormBloc>().add(TransactionFormEvent.edit(id: transaction.id));
    return MaterialPageRoute(builder: (ctx) => AddEditTransactionPage(item: transaction));
  }

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);

    return BlocConsumer<TransactionFormBloc, TransactionFormState>(
      listener: (ctx, state) async {
        state.maybeMap(
          initial: (state) {
            if (state.errorOccurred) {
              ToastUtils.showWarningToast(ctx, i18n.unknownErrorOcurred);
            }

            if (state.nextRecurringDateWasUpdated) {
              BlocUtils.raiseCommonBlocEvents(context, reloadTransactions: true);
            }
          },
          transactionChanged: (state) {
            final msg = state.wasUpdated || state.wasCreated ? i18n.transactionsWasSuccessfullySaved : i18n.transactionsWasSuccessfullyDeleted;
            ToastUtils.showSucceedToast(ctx, msg);

            ctx.read<TransactionsBloc>().add(TransactionsEvent.loadTransactions(inThisDate: state.transactionDate));
            ctx.read<ChartsBloc>().add(ChartsEvent.loadChart(from: state.transactionDate));

            Navigator.of(ctx).pop();
          },
          orElse: () => {},
        );
      },
      builder: (ctx, state) => _buildPage(ctx, state),
    );
  }

  AppBar? _buildAppBar(BuildContext context, TransactionFormState state) {
    final i18n = S.of(context);
    return state.maybeMap(
      initial: (state) {
        return AppBar(
          title: Text(item == null ? i18n.addTransaction : i18n.editTransaction),
          leading: const BackButton(),
          actions: [
            if (!TransactionFormState.isChildTransaction(state))
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: TransactionFormState.isFormValid(state) ? () => _saveTransaction(context) : null,
              ),
            if (!TransactionFormState.isNewTransaction(state) && !TransactionFormState.isChildTransaction(state))
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _showDeleteConfirmationDialog(context, state.description, state.isParentTransaction),
              ),
          ],
        );
      },
      orElse: () => null,
    );
  }

  Widget _buildPage(BuildContext context, TransactionFormState state) {
    final i18n = S.of(context);
    final theme = Theme.of(context);

    const loadingIndicator = Center(child: CircularProgressIndicator());

    return state.maybeMap(
      initial: (state) {
        if (state.errorOccurred) {
          ToastUtils.showWarningToast(context, i18n.unknownErrorOcurred);
        }

        final scrollView = SingleChildScrollView(
          child: Column(
            children: [
              AddEditTransactionHeader(
                description: state.description,
                amount: state.amount,
                category: state.category,
                isChildTransaction: TransactionFormState.isChildTransaction(state),
                nextRecurringDate: state.nextRecurringDate,
                repetitionCycle: state.repetitionCycle,
                transactionDateString: state.transactionDateString,
                isParentTransaction: state.isParentTransaction,
                isRecurringTransactionRunning: state.isRecurringTransactionRunning,
                onCategoryChanged: (selectedCat) {
                  //TODO: THIS
                  // final amount = (double.tryParse(_amountController.text) ?? 0).abs();
                  // final amountText = selectedCat.isAnIncome ? '$amount' : '${amount * -1}';
                  // _amountController.text = amountText;
                  // if (_descriptionController.text.isNullEmptyOrWhitespace) {
                  //   _descriptionController.text = selectedCat.name;
                  // }
                  context.read<TransactionFormBloc>().add(TransactionFormEvent.categoryWasUpdated(category: selectedCat));
                  // final amount = (double.tryParse(_amountController.text) ?? 0).abs();
                  // final amountText = selectedCat.isAnIncome ? '$amount' : '${amount * -1}';
                  // _amountController.text = amountText;
                  // if (_descriptionController.text.isNullEmptyOrWhitespace) {
                  //   _descriptionController.text = selectedCat.name;
                  // }
                  // context.read<TransactionFormBloc>().add(CategoryWasUpdated(selectedCat));
                },
              ),
              if (TransactionFormState.isChildTransaction(state))
                Text(
                  i18n.childTransactionCantBeDeleted,
                  style: theme.textTheme.caption!.copyWith(color: theme.primaryColorDark),
                ),
              AddEditTransactionForm(
                isRecurringTransactionRunning: state.isRecurringTransactionRunning,
                transactionDateString: state.transactionDateString,
                repetitionCycle: state.repetitionCycle,
                isParentTransaction: state.isParentTransaction,
                firstDate: state.firstDate,
                lastDate: state.lastDate,
                imageExists: state.imageExists,
                imagePath: state.imagePath,
                isChildTransaction: TransactionFormState.isChildTransaction(state),
                isAmountValid: state.isAmountValid,
                isDescriptionValid: state.isDescriptionValid,
                isDescriptionDirty: state.isDescriptionDirty,
                isLongDescriptionValid: state.isLongDescriptionValid,
                isLongDescriptionDirty: state.isLongDescriptionDirty,
                isTransactionDateValid: state.isTransactionDateValid,
                language: state.language,
                transactionDate: state.transactionDate,
                item: item,
              ),
            ],
          ),
        );

        final scaffold = Scaffold(appBar: _buildAppBar(context, state), body: scrollView);

        if (state.isSavingForm) {
          return Stack(
            children: [
              scaffold,
              const Opacity(
                opacity: 0.5,
                child: ModalBarrier(dismissible: false, color: Colors.black),
              ),
              loadingIndicator,
            ],
          );
        }

        return scaffold;
      },
      orElse: () => loadingIndicator,
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
          OutlineButton(
            textColor: Theme.of(context).primaryColor,
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text(i18n.close),
          ),
          RaisedButton(
            color: Theme.of(ctx).primaryColor,
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
          OutlineButton(
            textColor: Theme.of(context).primaryColor,
            onPressed: () {
              context.read<TransactionFormBloc>().add(const TransactionFormEvent.deleteTransaction(keepChildren: true));
              Navigator.of(ctx).pop();
            },
            child: Text(i18n.no),
          ),
          RaisedButton(
            color: Theme.of(ctx).primaryColor,
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

typedef OnCategoryChanged = void Function(CategoryItem);

class AddEditTransactionHeader extends StatelessWidget {
  final bool isParentTransaction;
  final DateTime? nextRecurringDate;
  final bool isRecurringTransactionRunning;
  final String transactionDateString;
  final double amount;
  final RepetitionCycleType repetitionCycle;
  final String description;
  final bool isChildTransaction;
  final CategoryItem category;
  final OnCategoryChanged onCategoryChanged;

  const AddEditTransactionHeader({
    Key? key,
    required this.isParentTransaction,
    required this.nextRecurringDate,
    required this.isRecurringTransactionRunning,
    required this.transactionDateString,
    required this.amount,
    required this.repetitionCycle,
    required this.description,
    required this.isChildTransaction,
    required this.category,
    required this.onCategoryChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const cornerRadius = Radius.circular(20);
    final theme = Theme.of(context);
    final i18n = S.of(context);
    final dateString = isParentTransaction && nextRecurringDate != null && isRecurringTransactionRunning
        ? i18n.nextDateOn(utils.DateUtils.formatDateWithoutLocale(
            nextRecurringDate!,
            utils.DateUtils.monthDayAndYearFormat,
          ))
        : '${i18n.date}: $transactionDateString';

    final formattedAmount = context.watch<CurrencyBloc>().format(amount);
    final categoryType = category.isAnIncome ? i18n.income : i18n.expense;
    final repetitionCycleType = i18n.translateRepetitionCycleType(repetitionCycle);

    return SizedBox(
      height: 260.0,
      child: Stack(
        children: <Widget>[
          Container(height: 150, color: theme.primaryColorDark),
          Container(
            padding: const EdgeInsets.only(
              top: 60.0,
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
                    description,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    dateString,
                    style: theme.textTheme.subtitle2,
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  SizedBox(
                    height: 40.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: ListTile(
                            title: Tooltip(
                              message: formattedAmount,
                              child: Text(
                                formattedAmount,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.headline6,
                              ),
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
                            title: Tooltip(
                              message: categoryType,
                              child: Text(
                                categoryType,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.headline6,
                              ),
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
                            title: Tooltip(
                              message: repetitionCycleType,
                              child: Text(
                                repetitionCycleType,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.headline6,
                              ),
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
                  color: theme.cardColor.withOpacity(0.8),
                  type: MaterialType.circle,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: !isChildTransaction
                        ? IconButton(
                            iconSize: 60,
                            icon: Icon(category.icon),
                            color: category.iconColor,
                            onPressed: () => _changeCategory(context),
                          )
                        : Icon(
                            category.icon,
                            size: 75,
                            color: category.iconColor,
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

  Future<void> _changeCategory(BuildContext context) async {
    final selectedCatProvider = Provider.of<CurrentSelectedCategory>(context, listen: false);

    if (category.id > 0) {
      selectedCatProvider.currentSelectedItem = category;
    }

    final route = MaterialPageRoute<CategoryItem>(
      builder: (ctx) => CategoriesPage(isInSelectionMode: true, selectedCategory: category),
    );
    final selectedCat = await Navigator.of(context).push(route);

    selectedCatProvider.currentSelectedItem = null;

    if (selectedCat != null) {
      onCategoryChanged(selectedCat);
    }
  }
}

class AddEditTransactionForm extends StatefulWidget {
  final TransactionItem? item;
  final bool isChildTransaction;
  final bool isAmountValid;
  final bool isDescriptionDirty;
  final bool isDescriptionValid;
  final bool isLongDescriptionDirty;
  final bool isLongDescriptionValid;
  final String transactionDateString;
  final bool isTransactionDateValid;
  final bool isParentTransaction;
  final RepetitionCycleType repetitionCycle;
  final DateTime transactionDate;
  final AppLanguageType language;
  final bool isRecurringTransactionRunning;
  final String? imagePath;
  final bool imageExists;
  final DateTime firstDate;
  final DateTime lastDate;

  const AddEditTransactionForm({
    Key? key,
    required this.item,
    required this.isChildTransaction,
    required this.isAmountValid,
    required this.isDescriptionDirty,
    required this.isDescriptionValid,
    required this.isLongDescriptionDirty,
    required this.isLongDescriptionValid,
    required this.transactionDateString,
    required this.isTransactionDateValid,
    required this.isParentTransaction,
    required this.repetitionCycle,
    required this.transactionDate,
    required this.language,
    required this.isRecurringTransactionRunning,
    this.imagePath,
    required this.imageExists,
    required this.firstDate,
    required this.lastDate,
  }) : super(key: key);

  @override
  _AddEditTransactionFormState createState() => _AddEditTransactionFormState();
}

class _AddEditTransactionFormState extends State<AddEditTransactionForm> {
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late TextEditingController _longDescriptionController;

  final FocusNode _amountFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();
  final FocusNode _longDescriptionFocus = FocusNode();
  final FocusNode _repetitionsFocus = FocusNode();

  final _formKey = GlobalKey<FormState>();
  bool _didChangeDependencies = false;

  final _repetitionCycles = [
    RepetitionCycleType.none,
    RepetitionCycleType.eachDay,
    RepetitionCycleType.eachWeek,
    RepetitionCycleType.biweekly,
    RepetitionCycleType.eachMonth,
  ];

  @override
  void initState() {
    final double amount = widget.item?.amount ?? 0;
    final description = widget.item?.description ?? '';

    _amountController = TextEditingController(text: '$amount');
    _descriptionController = TextEditingController(text: description);
    _longDescriptionController = TextEditingController(text: widget.item?.longDescription ?? '');

    _amountController.addListener(_amountChanged);
    _descriptionController.addListener(_descriptionChanged);
    _longDescriptionController.addListener(_longDescriptionChanged);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didChangeDependencies) return;
    if (widget.item != null) {
      context.read<TransactionFormBloc>().add(TransactionFormEvent.edit(id: widget.item!.id));
    } else {
      context.read<TransactionFormBloc>().add(const TransactionFormEvent.add());
    }

    _didChangeDependencies = true;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (widget.isParentTransaction) _buildRecurringSwitch(),
            _buildAmountInput(),
            _buildDescriptionInput(),
            _buildLongDescriptionInput(),
            _buildTransactionDateButton(),
            _buildRepetitionCyclesDropDown(),
            ..._buildPickImageButtons(),
          ],
        ),
      ),
    );
  }

  Widget? _buildSuffixIconButton(
    TextEditingController controller,
    FocusNode focusNode,
  ) {
    final suffixIcon = !controller.text.isNullEmptyOrWhitespace && focusNode.hasFocus
        ? IconButton(
            alignment: Alignment.bottomCenter,
            icon: const Icon(Icons.close),
            onPressed: () => controller.clear(),
          )
        : null;

    return suffixIcon;
  }

  Widget _buildRecurringSwitch() {
    final theme = Theme.of(context);
    final i18n = S.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SwitchListTile(
            activeColor: theme.accentColor,
            value: widget.isRecurringTransactionRunning,
            title: Text(
              widget.isRecurringTransactionRunning ? i18n.running : i18n.stopped,
            ),
            secondary: Icon(
              widget.isRecurringTransactionRunning ? Icons.play_arrow : Icons.stop,
              size: 30,
            ),
            subtitle: Text(
              widget.isRecurringTransactionRunning ? i18n.recurringTransactionIsNowRunning : i18n.recurringTransactionIsNowStopped,
            ),
            onChanged: _isRunningChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput() {
    final suffixIcon = _buildSuffixIconButton(_amountController, _amountFocus);
    final i18n = S.of(context);

    return Row(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(right: 10),
          child: const Icon(
            Icons.attach_money,
            size: 30,
          ),
        ),
        Expanded(
          child: TextFormField(
            enabled: !widget.isChildTransaction,
            controller: _amountController,
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
            // autovalidate: state.isAmountDirty,
            onFieldSubmitted: (_) => _fieldFocusChange(context, _amountFocus, _descriptionFocus),
            validator: (_) => widget.isAmountValid ? null : i18n.invalidAmount,
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionInput() {
    final suffixIcon = _buildSuffixIconButton(_descriptionController, _descriptionFocus);
    final i18n = S.of(context);

    return Row(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(right: 10),
          child: const Icon(Icons.note, size: 30),
        ),
        Expanded(
          child: TextFormField(
            enabled: !widget.isChildTransaction,
            controller: _descriptionController,
            keyboardType: TextInputType.text,
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
            autovalidate: widget.isDescriptionDirty,
            onFieldSubmitted: (_) => _fieldFocusChange(context, _descriptionFocus, _longDescriptionFocus),
            validator: (_) => widget.isDescriptionValid ? null : i18n.invalidDescription,
          ),
        ),
      ],
    );
  }

  Widget _buildLongDescriptionInput() {
    final suffixIcon = _buildSuffixIconButton(_longDescriptionController, _longDescriptionFocus);
    final i18n = S.of(context);

    return Row(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(right: 10),
          child: const Icon(Icons.note, size: 30),
        ),
        Expanded(
          child: TextFormField(
            enabled: !widget.isChildTransaction,
            controller: _longDescriptionController,
            keyboardType: TextInputType.text,
            maxLines: 5,
            minLines: 1,
            maxLength: 500,
            focusNode: _longDescriptionFocus,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              suffixIcon: suffixIcon,
              alignLabelWithHint: true,
              labelText: i18n.longDescription,
              hintText: i18n.descriptionOfThisTransaction,
            ),
            autovalidate: widget.isLongDescriptionDirty,
            onFieldSubmitted: (_) => _fieldFocusChange(context, _longDescriptionFocus, _repetitionsFocus),
            validator: (_) => widget.isLongDescriptionValid ? null : i18n.invalidDescription,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionDateButton() {
    final i18n = S.of(context);
    final theme = Theme.of(context);
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            const Icon(Icons.calendar_today, size: 30),
            Expanded(
              child: FlatButton(
                onPressed: !widget.isChildTransaction ? () => _transactionDateClicked() : null,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(widget.transactionDateString),
                ),
              ),
            ),
          ],
        ),
        if (!widget.isChildTransaction && !widget.isTransactionDateValid && widget.repetitionCycle != RepetitionCycleType.none)
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: Text(
              i18n.recurringDateMustStartFromTomorrow,
              textAlign: TextAlign.center,
              style: theme.textTheme.caption!.copyWith(color: theme.primaryColorDark),
            ),
          ),
      ],
    );
  }

  Widget _buildRepetitionCyclesDropDown() {
    final i18n = S.of(context);
    final theme = Theme.of(context);

    //This is to avoid loosing the isParentTransaction property and
    //to avoid a potential bug
    final repetitionCyclesToUse =
        widget.isParentTransaction ? _repetitionCycles.where((c) => c.index != RepetitionCycleType.none.index) : _repetitionCycles;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.repeat, size: 30),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                  ),
                  child: DropdownButton<RepetitionCycleType>(
                    isExpanded: true,
                    hint: Text(
                      i18n.translateRepetitionCycleType(widget.repetitionCycle),
                    ),
                    value: widget.repetitionCycle,
                    underline: Container(
                      height: 0,
                      color: Colors.transparent,
                    ),
                    onChanged: (v) => !widget.isChildTransaction ? _repetitionCycleChanged(v!) : null,
                    items: repetitionCyclesToUse.map<DropdownMenuItem<RepetitionCycleType>>((value) {
                      return DropdownMenuItem<RepetitionCycleType>(
                        value: value,
                        child: Text(
                          i18n.translateRepetitionCycleType(value),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          if (!widget.isChildTransaction && widget.repetitionCycle != RepetitionCycleType.none)
            Padding(
              padding: const EdgeInsets.only(bottom: 5, left: 8, right: 8),
              child: Text(
                i18n.recurringTransactionStartsOn(
                  utils.DateUtils.formatAppDate(
                    widget.transactionDate,
                    widget.language,
                    utils.DateUtils.monthDayAndYearFormat,
                  ),
                  i18n.translateRepetitionCycleType(widget.repetitionCycle).toLowerCase(),
                ),
                textAlign: TextAlign.center,
                style: theme.textTheme.caption!.copyWith(color: theme.primaryColorDark),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildPickImageButtons() {
    final theme = Theme.of(context);
    final i18n = S.of(context);

    return [
      Text(
        i18n.addPicture,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      ButtonBar(
        alignment: MainAxisAlignment.center,
        children: <Widget>[
          FlatButton.icon(
            textColor: theme.primaryColor,
            onPressed: !widget.isChildTransaction ? () => _pickPicture(true, i18n) : null,
            icon: const Icon(Icons.photo_library),
            label: Text(i18n.fromGallery),
          ),
          FlatButton.icon(
            textColor: theme.primaryColor,
            onPressed: !widget.isChildTransaction ? () => _pickPicture(false, i18n) : null,
            icon: const Icon(Icons.camera_enhance),
            label: Text(i18n.fromCamera),
          ),
        ],
      ),
      if (widget.imageExists)
        Container(
          margin: const EdgeInsets.only(
            left: 10,
            right: 10,
            bottom: 30,
          ),
          child: Stack(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: const Center(child: CircularProgressIndicator()),
              ),
              GestureDetector(
                onTap: () => _showImageDialog(widget.imagePath!),
                child: FadeInImage(
                  fit: BoxFit.fill,
                  fadeInDuration: const Duration(seconds: 1),
                  placeholder: MemoryImage(kTransparentImage),
                  image: FileImage(File(widget.imagePath!)),
                ),
              ),
            ],
          ),
        ),
    ];
  }

  void _amountChanged() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    context.read<TransactionFormBloc>().add(TransactionFormEvent.amountChanged(amount: amount));
  }

  void _descriptionChanged() {
    context.read<TransactionFormBloc>().add(TransactionFormEvent.descriptionChanged(description: _descriptionController.text));
  }

  void _longDescriptionChanged() =>
      context.read<TransactionFormBloc>().add(TransactionFormEvent.longDescriptionChanged(longDescription: _longDescriptionController.text));

  void _repetitionCycleChanged(RepetitionCycleType newValue) =>
      context.read<TransactionFormBloc>().add(TransactionFormEvent.repetitionCycleChanged(repetitionCycle: newValue));

  Future<void> _transactionDateClicked() async {
    DateTime? selectedDate;
    if (widget.repetitionCycle != RepetitionCycleType.biweekly) {
      selectedDate = await showDatePicker(
        context: context,
        initialDate: widget.transactionDate,
        firstDate: widget.firstDate,
        lastDate: widget.lastDate,
        locale: currentLocale(widget.language),
      );
    } else {
      selectedDate = await showDatePicker(
        context: context,
        initialDate: widget.transactionDate,
        firstDate: widget.firstDate,
        lastDate: widget.lastDate,
        locale: currentLocale(widget.language),
        selectableDayPredicate: (date) {
          if (date.isAtSameMomentAs(widget.transactionDate) || date.day == 1) {
            return true;
          }

          final biweeklyDate = utils.DateUtils.getNextBiweeklyDate(
            date.subtract(const Duration(days: 1)),
          );

          return biweeklyDate.day == date.day;
        },
      );
    }

    if (selectedDate == null) {
      return;
    }
    context.read<TransactionFormBloc>().add(TransactionFormEvent.transactionDateChanged(transactionDate: selectedDate));
  }

  Future<void> _showDeleteImageDialog() {
    final i18n = S.of(context);
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(i18n.removeImg),
        content: Text(i18n.areYouSure),
        actions: <Widget>[
          OutlineButton(
            textColor: Theme.of(context).primaryColor,
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text(i18n.cancel),
          ),
          RaisedButton(
            color: Theme.of(ctx).primaryColor,
            onPressed: () {
              context.read<TransactionFormBloc>().add(const TransactionFormEvent.imageChanged(path: '', imageExists: false));
              //One for this dialog and the other for the preview
              Navigator.of(ctx).pop();
              Navigator.of(ctx).pop();
            },
            child: Text(i18n.yes),
          ),
        ],
      ),
    );
  }

  Future<void> _pickPicture(bool fromGallery, S i18n) async {
    try {
      final image = await ImagePicker().getImage(
        source: fromGallery ? ImageSource.gallery : ImageSource.camera,
        maxHeight: 600,
        maxWidth: 600,
      );
      if (image == null) return;
      context.read<TransactionFormBloc>().add(TransactionFormEvent.imageChanged(path: image.path, imageExists: true));
    } catch (e) {
      ToastUtils.showWarningToast(context, i18n.acceptPermissionsToUseThisFeature);
    }
  }

  void _isRunningChanged(bool newValue) => context.read<TransactionFormBloc>().add(TransactionFormEvent.isRunningChanged(isRunning: newValue));

  void _showImageDialog(String imagePath) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (_) => Material(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            PhotoView(imageProvider: FileImage(File(imagePath))),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    color: Colors.white,
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                  IconButton(
                    color: Theme.of(context).primaryColor,
                    icon: const Icon(Icons.delete),
                    onPressed: _showDeleteImageDialog,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _fieldFocusChange(BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }
}
