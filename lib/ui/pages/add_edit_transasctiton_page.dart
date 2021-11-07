import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_expenses/common/enums/app_language_type.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/ui/widgets/input_suffix_icon.dart';
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

class AddEditTransactionPage extends StatefulWidget {
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
  _AddEditTransactionPageState createState() => _AddEditTransactionPageState();
}

class _AddEditTransactionPageState extends State<AddEditTransactionPage> {
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late TextEditingController _longDescriptionController;

  final FocusNode _amountFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();
  final FocusNode _longDescriptionFocus = FocusNode();
  final FocusNode _repetitionsFocus = FocusNode();

  final _formKey = GlobalKey<FormState>();
  bool _didChangeDependencies = false;

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
    final i18n = S.of(context);
    final theme = Theme.of(context);

    const loadingIndicator = Center(child: CircularProgressIndicator());

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
            ctx.read<ChartsBloc>().add(ChartsEvent.loadChart(selectedMonthDate: state.transactionDate, selectedYear: state.transactionDate.year));

            Navigator.of(ctx).pop();
          },
          orElse: () => {},
        );
      },
      builder: (ctx, state) => state.maybeMap(
        initial: (state) {
          if (state.errorOccurred) {
            ToastUtils.showWarningToast(context, i18n.unknownErrorOcurred);
          }

          final isChildTransaction = TransactionFormState.isChildTransaction(state);

          final scrollView = SingleChildScrollView(
            child: Column(
              children: [
                AddEditTransactionHeader(
                  description: state.description,
                  amount: state.amount,
                  category: state.category,
                  isChildTransaction: isChildTransaction,
                  nextRecurringDate: state.nextRecurringDate,
                  repetitionCycle: state.repetitionCycle,
                  transactionDateString: state.transactionDateString,
                  isParentTransaction: state.isParentTransaction,
                  isRecurringTransactionRunning: state.isRecurringTransactionRunning,
                  onCategoryChanged: (selectedCat) {
                    final amount = (double.tryParse(_amountController.text) ?? 0).abs();
                    final amountText = selectedCat.isAnIncome ? '$amount' : '${amount * -1}';
                    _amountController.text = amountText;
                    if (_descriptionController.text.isNullEmptyOrWhitespace) {
                      _descriptionController.text = selectedCat.name;
                    }
                    context.read<TransactionFormBloc>().add(TransactionFormEvent.categoryWasUpdated(category: selectedCat));
                  },
                ),
                if (isChildTransaction)
                  Text(
                    i18n.childTransactionCantBeDeleted,
                    style: theme.textTheme.caption!.copyWith(color: theme.primaryColorDark),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        if (state.isParentTransaction) _RecurringSwitch(isRecurringTransactionRunning: state.isRecurringTransactionRunning),
                        _AmountInput(
                          amountController: _amountController,
                          amountFocus: _amountFocus,
                          isChildTransaction: isChildTransaction,
                          isAmountValid: state.isAmountValid,
                          isAmountDirty: state.isAmountDirty,
                          onSubmit: () => _fieldFocusChange(context, _amountFocus, _descriptionFocus),
                        ),
                        _DescriptionInput(
                          descriptionController: _descriptionController,
                          descriptionFocus: _descriptionFocus,
                          isChildTransaction: isChildTransaction,
                          isDescriptionDirty: state.isDescriptionDirty,
                          isDescriptionValid: state.isDescriptionValid,
                          onSubmit: () => _fieldFocusChange(context, _descriptionFocus, _longDescriptionFocus),
                        ),
                        _LongDescriptionInput(
                          longDescriptionController: _longDescriptionController,
                          longDescriptionFocus: _longDescriptionFocus,
                          isChildTransaction: isChildTransaction,
                          isLongDescriptionDirty: state.isLongDescriptionDirty,
                          isLongDescriptionValid: state.isLongDescriptionValid,
                          onSubmit: () => _fieldFocusChange(context, _longDescriptionFocus, _repetitionsFocus),
                        ),
                        _DateButton(
                          isChildTransaction: isChildTransaction,
                          repetitionCycle: state.repetitionCycle,
                          transactionDate: state.transactionDate,
                          transactionDateString: state.transactionDateString,
                          isTransactionDateValid: state.isTransactionDateValid,
                          language: state.language,
                          firstDate: state.firstDate,
                          lastDate: state.lastDate,
                        ),
                        _RepetitionCycleDropdown(
                          isChildTransaction: isChildTransaction,
                          isParentTransaction: state.isParentTransaction,
                          repetitionCycle: state.repetitionCycle,
                          language: state.language,
                          transactionDate: state.transactionDate,
                        ),
                        ..._buildPickImageButtons(isChildTransaction, state.imageExists, state.imagePath)
                      ],
                    ),
                  ),
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
      ),
    );
  }

  AppBar? _buildAppBar(BuildContext context, TransactionFormState state) {
    final i18n = S.of(context);
    return state.maybeMap(
      initial: (state) {
        return AppBar(
          title: Text(widget.item == null ? i18n.addTransaction : i18n.editTransaction),
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

  void _fieldFocusChange(BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  List<Widget> _buildPickImageButtons(bool isChildTransaction, bool imageExists, String? imagePath) {
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
          TextButton.icon(
            onPressed: !isChildTransaction ? () => _pickPicture(true, i18n) : null,
            icon: const Icon(Icons.photo_library),
            label: Text(i18n.fromGallery),
          ),
          TextButton.icon(
            onPressed: !isChildTransaction ? () => _pickPicture(false, i18n) : null,
            icon: const Icon(Icons.camera_enhance),
            label: Text(i18n.fromCamera),
          ),
        ],
      ),
      if (imageExists) _ImagePreview(imagePath: imagePath),
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

  Future<void> _pickPicture(bool fromGallery, S i18n) async {
    try {
      final image = await ImagePicker().pickImage(
        source: fromGallery ? ImageSource.gallery : ImageSource.camera,
        maxHeight: 600,
        maxWidth: 600,
      );
      if (image == null) {
        return;
      }

      if (mounted) {
        context.read<TransactionFormBloc>().add(TransactionFormEvent.imageChanged(path: image.path, imageExists: true));
      }
    } catch (e) {
      ToastUtils.showWarningToast(context, i18n.acceptPermissionsToUseThisFeature);
    }
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
          OutlinedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text(i18n.close),
          ),
          ElevatedButton(
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
          OutlinedButton(
            onPressed: () {
              context.read<TransactionFormBloc>().add(const TransactionFormEvent.deleteTransaction(keepChildren: true));
              Navigator.of(ctx).pop();
            },
            child: Text(i18n.no),
          ),
          ElevatedButton(
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
    this.nextRecurringDate,
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
        ? i18n.nextDateOn(utils.DateUtils.formatDateWithoutLocale(nextRecurringDate, utils.DateUtils.monthDayAndYearFormat))
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

class _RecurringSwitch extends StatelessWidget {
  final bool isRecurringTransactionRunning;

  const _RecurringSwitch({
    Key? key,
    required this.isRecurringTransactionRunning,
  }) : super(key: key);

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
            activeColor: theme.colorScheme.secondary,
            value: isRecurringTransactionRunning,
            title: Text(
              isRecurringTransactionRunning ? i18n.running : i18n.stopped,
            ),
            secondary: Icon(
              isRecurringTransactionRunning ? Icons.play_arrow : Icons.stop,
              size: 30,
            ),
            subtitle: Text(
              isRecurringTransactionRunning ? i18n.recurringTransactionIsNowRunning : i18n.recurringTransactionIsNowStopped,
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

typedef OnInputSubmit = void Function();

class _AmountInput extends StatelessWidget {
  final TextEditingController amountController;
  final FocusNode amountFocus;
  final bool isChildTransaction;
  final bool isAmountValid;
  final bool isAmountDirty;
  final OnInputSubmit onSubmit;

  const _AmountInput({
    Key? key,
    required this.amountController,
    required this.amountFocus,
    required this.isChildTransaction,
    required this.isAmountValid,
    required this.isAmountDirty,
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            enabled: !isChildTransaction,
            controller: amountController,
            minLines: 1,
            maxLength: 255,
            focusNode: amountFocus,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.number,
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

class _DescriptionInput extends StatelessWidget {
  final TextEditingController descriptionController;
  final FocusNode descriptionFocus;
  final bool isChildTransaction;
  final bool isDescriptionDirty;
  final bool isDescriptionValid;
  final OnInputSubmit onSubmit;

  const _DescriptionInput({
    Key? key,
    required this.descriptionController,
    required this.descriptionFocus,
    required this.isChildTransaction,
    required this.isDescriptionDirty,
    required this.isDescriptionValid,
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);

    return Row(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(right: 10),
          child: const Icon(Icons.note, size: 30),
        ),
        Expanded(
          child: TextFormField(
            enabled: !isChildTransaction,
            controller: descriptionController,
            keyboardType: TextInputType.text,
            minLines: 1,
            maxLength: 255,
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

class _LongDescriptionInput extends StatelessWidget {
  final TextEditingController longDescriptionController;
  final FocusNode longDescriptionFocus;
  final bool isChildTransaction;
  final bool isLongDescriptionDirty;
  final bool isLongDescriptionValid;
  final OnInputSubmit onSubmit;

  const _LongDescriptionInput({
    Key? key,
    required this.longDescriptionController,
    required this.longDescriptionFocus,
    required this.isChildTransaction,
    required this.isLongDescriptionDirty,
    required this.isLongDescriptionValid,
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);

    return Row(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(right: 10),
          child: const Icon(Icons.note, size: 30),
        ),
        Expanded(
          child: TextFormField(
            enabled: !isChildTransaction,
            controller: longDescriptionController,
            keyboardType: TextInputType.text,
            maxLines: 5,
            minLines: 1,
            maxLength: 500,
            focusNode: longDescriptionFocus,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              suffixIcon: InputSuffixIcon(controller: longDescriptionController, focusNode: longDescriptionFocus),
              alignLabelWithHint: true,
              labelText: i18n.longDescription,
              hintText: i18n.descriptionOfThisTransaction,
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

class _DateButton extends StatelessWidget {
  final bool isChildTransaction;
  final RepetitionCycleType repetitionCycle;

  final DateTime transactionDate;
  final String transactionDateString;
  final bool isTransactionDateValid;

  final AppLanguageType language;
  final DateTime firstDate;
  final DateTime lastDate;

  const _DateButton({
    Key? key,
    required this.isChildTransaction,
    required this.repetitionCycle,
    required this.transactionDate,
    required this.transactionDateString,
    required this.isTransactionDateValid,
    required this.language,
    required this.firstDate,
    required this.lastDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            const Icon(Icons.calendar_today, size: 30),
            Expanded(
              child: TextButton(
                style: ButtonStyle(foregroundColor: MaterialStateProperty.all<Color>(textColor)),
                onPressed: !isChildTransaction ? () => _transactionDateClicked(context) : null,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(transactionDateString),
                ),
              ),
            ),
          ],
        ),
        if (!isChildTransaction && !isTransactionDateValid && repetitionCycle != RepetitionCycleType.none)
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

  Future<void> _transactionDateClicked(BuildContext context) async {
    DateTime? selectedDate;
    if (repetitionCycle != RepetitionCycleType.biweekly) {
      selectedDate = await showDatePicker(
        context: context,
        initialDate: transactionDate,
        firstDate: firstDate,
        lastDate: lastDate,
        locale: currentLocale(language),
      );
    } else {
      selectedDate = await showDatePicker(
        context: context,
        initialDate: transactionDate,
        firstDate: firstDate,
        lastDate: lastDate,
        locale: currentLocale(language),
        selectableDayPredicate: (date) {
          if (date.isAtSameMomentAs(transactionDate) || date.day == 1) {
            return true;
          }

          final biweeklyDate = utils.DateUtils.getNextBiweeklyDate(date.subtract(const Duration(days: 1)));

          return biweeklyDate.day == date.day;
        },
      );
    }

    if (selectedDate == null) {
      return;
    }
    context.read<TransactionFormBloc>().add(TransactionFormEvent.transactionDateChanged(transactionDate: selectedDate));
  }
}

class _RepetitionCycleDropdown extends StatelessWidget {
  final bool isChildTransaction;
  final bool isParentTransaction;
  final RepetitionCycleType repetitionCycle;
  final AppLanguageType language;
  final DateTime transactionDate;

  final _repetitionCycles = [
    RepetitionCycleType.none,
    RepetitionCycleType.eachDay,
    RepetitionCycleType.eachWeek,
    RepetitionCycleType.biweekly,
    RepetitionCycleType.eachMonth,
  ];

  _RepetitionCycleDropdown({
    Key? key,
    required this.isChildTransaction,
    required this.isParentTransaction,
    required this.repetitionCycle,
    required this.language,
    required this.transactionDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    final theme = Theme.of(context);

    //This is to avoid loosing the isParentTransaction property and
    //to avoid a potential bug
    final repetitionCyclesToUse = isParentTransaction ? _repetitionCycles.where((c) => c.index != RepetitionCycleType.none.index) : _repetitionCycles;

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
                  padding: const EdgeInsets.only(left: 8),
                  child: DropdownButton<RepetitionCycleType>(
                    isExpanded: true,
                    hint: Text(
                      i18n.translateRepetitionCycleType(repetitionCycle),
                    ),
                    value: repetitionCycle,
                    underline: Container(
                      height: 0,
                      color: Colors.transparent,
                    ),
                    onChanged: (v) => !isChildTransaction ? _repetitionCycleChanged(v!, context) : null,
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
          if (!isChildTransaction && repetitionCycle != RepetitionCycleType.none)
            Padding(
              padding: const EdgeInsets.only(bottom: 5, left: 8, right: 8),
              child: Text(
                i18n.recurringTransactionStartsOn(
                  utils.DateUtils.formatAppDate(
                    transactionDate,
                    language,
                    utils.DateUtils.monthDayAndYearFormat,
                  ),
                  i18n.translateRepetitionCycleType(repetitionCycle).toLowerCase(),
                ),
                textAlign: TextAlign.center,
                style: theme.textTheme.caption!.copyWith(color: theme.primaryColorDark),
              ),
            ),
        ],
      ),
    );
  }

  void _repetitionCycleChanged(RepetitionCycleType newValue, BuildContext context) =>
      context.read<TransactionFormBloc>().add(TransactionFormEvent.repetitionCycleChanged(repetitionCycle: newValue));
}

class _ImagePreview extends StatelessWidget {
  final String? imagePath;

  const _ImagePreview({
    Key? key,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 30),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 10),
            child: const Center(child: CircularProgressIndicator()),
          ),
          GestureDetector(
            onTap: () => _showImageDialog(imagePath!, context),
            child: FadeInImage(
              fit: BoxFit.fill,
              fadeInDuration: const Duration(seconds: 1),
              placeholder: MemoryImage(kTransparentImage),
              image: FileImage(File(imagePath!)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showImageDialog(String imagePath, BuildContext context) {
    return showDialog(
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
                    onPressed: () => _showDeleteImageDialog(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteImageDialog(BuildContext context) {
    final i18n = S.of(context);
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(i18n.removeImg),
        content: Text(i18n.areYouSure),
        actions: <Widget>[
          OutlinedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text(i18n.cancel),
          ),
          ElevatedButton(
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
}
