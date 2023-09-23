import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/extensions/string_extensions.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/domain/utils/date_utils.dart' as utils;
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/injection.dart';
import 'package:my_expenses/presentation/categories/categories_page.dart';
import 'package:my_expenses/presentation/shared/extensions/i18n_extensions.dart';
import 'package:my_expenses/presentation/shared/input_suffix_icon.dart';
import 'package:my_expenses/presentation/shared/utils/bloc_utils.dart';
import 'package:my_expenses/presentation/shared/utils/toast_utils.dart';
import 'package:my_expenses/presentation/transaction/widgets/form_app_bar.dart';
import 'package:my_expenses/presentation/transaction/widgets/form_date_button.dart';
import 'package:my_expenses/presentation/transaction/widgets/form_image_preview.dart';
import 'package:my_expenses/presentation/transaction/widgets/form_repetition_cycle_dropdown.dart';
import 'package:provider/provider.dart';

class AddEditTransactionPage extends StatefulWidget {
  final TransactionItem? item;

  const AddEditTransactionPage({this.item});

  static MaterialPageRoute addRoute(BuildContext context) {
    return MaterialPageRoute(
      builder: (ctx) => BlocProvider<TransactionFormBloc>(
        create: (ctx) => Injection.transactionFormBloc..add(const TransactionFormEvent.add()),
        child: const AddEditTransactionPage(),
      ),
    );
  }

  static MaterialPageRoute editRoute(TransactionItem transaction, BuildContext context) {
    return MaterialPageRoute(
      builder: (ctx) => BlocProvider<TransactionFormBloc>(
        create: (ctx) => Injection.transactionFormBloc..add(TransactionFormEvent.edit(id: transaction.id)),
        child: AddEditTransactionPage(item: transaction),
      ),
    );
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

  late double _currentAmount;
  late String _currentDescription;
  late String _currentLongDescription;

  @override
  void initState() {
    final double amount = widget.item?.amount ?? 0;
    final description = widget.item?.description ?? '';
    final longDescription = widget.item?.longDescription ?? '';

    _currentAmount = amount;
    _amountController = TextEditingController(text: '$amount');

    _currentDescription = description;
    _descriptionController = TextEditingController(text: description);

    _currentLongDescription = longDescription;
    _longDescriptionController = TextEditingController(text: longDescription);

    _amountController.addListener(_amountChanged);
    _descriptionController.addListener(_descriptionChanged);
    _longDescriptionController.addListener(_longDescriptionChanged);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    final theme = Theme.of(context);

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
                    style: theme.textTheme.bodySmall!.copyWith(color: theme.primaryColorDark),
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
                        FormDateButton(
                          isChildTransaction: isChildTransaction,
                          repetitionCycle: state.repetitionCycle,
                          transactionDate: state.transactionDate,
                          transactionDateString: state.transactionDateString,
                          isTransactionDateValid: state.isTransactionDateValid,
                          language: state.language,
                          firstDate: state.firstDate,
                          lastDate: state.lastDate,
                        ),
                        FormRepetitionCycleDropDown(
                          isChildTransaction: isChildTransaction,
                          isParentTransaction: state.isParentTransaction,
                          repetitionCycle: state.repetitionCycle,
                          language: state.languageModel,
                          transactionDate: state.transactionDate,
                        ),
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
                        if (state.imageExists) FormImagePreview(imagePath: state.imagePath!),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );

          final scaffold = Scaffold(
            appBar: state.maybeMap(
              initial: (state) => FormAppBar(
                isNewTransaction: TransactionFormState.isNewTransaction(state),
                isParentTransaction: state.isParentTransaction,
                toEditTransaction: widget.item != null,
                isChildTransaction: TransactionFormState.isChildTransaction(state),
                isFormValid: TransactionFormState.isFormValid(state),
                description: state.description,
              ),
              orElse: () => null,
            ),
            body: scrollView,
          );

          if (state.isSavingForm) {
            return Stack(
              children: [
                scaffold,
                const Opacity(
                  opacity: 0.5,
                  child: ModalBarrier(dismissible: false, color: Colors.black),
                ),
                const Center(child: CircularProgressIndicator()),
              ],
            );
          }

          return scaffold;
        },
        orElse: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  void _fieldFocusChange(BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  void _amountChanged() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (_currentAmount == amount) {
      return;
    }
    _currentAmount = amount;
    context.read<TransactionFormBloc>().add(TransactionFormEvent.amountChanged(amount: amount));
  }

  void _descriptionChanged() {
    if (_currentDescription == _descriptionController.text) {
      return;
    }
    _currentDescription = _descriptionController.text;
    context.read<TransactionFormBloc>().add(TransactionFormEvent.descriptionChanged(description: _descriptionController.text));
  }

  void _longDescriptionChanged() {
    if (_currentLongDescription == _longDescriptionController.text) {
      return;
    }
    _currentLongDescription = _longDescriptionController.text;
    context.read<TransactionFormBloc>().add(TransactionFormEvent.longDescriptionChanged(longDescription: _longDescriptionController.text));
  }

  Future<void> _pickPicture(bool fromGallery, S i18n) async {
    try {
      final image = await ImagePicker().pickImage(
        source: fromGallery ? ImageSource.gallery : ImageSource.camera,
        maxHeight: 600,
        maxWidth: 600,
        requestFullMetadata: false,
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
    super.key,
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
  });

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
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    dateString,
                    style: theme.textTheme.titleSmall,
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
                                style: theme.textTheme.titleLarge,
                              ),
                            ),
                            subtitle: Text(
                              i18n.amount.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall,
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
                                style: theme.textTheme.titleLarge,
                              ),
                            ),
                            subtitle: Text(
                              i18n.category.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall,
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
                                style: theme.textTheme.titleLarge,
                              ),
                            ),
                            subtitle: Text(
                              i18n.repetitions.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 15),
            alignment: Alignment.topCenter,
            child: Material(
              elevation: 10,
              color: theme.cardColor.withOpacity(0.8),
              type: MaterialType.circle,
              child: IconButton(
                iconSize: 75,
                icon: FaIcon(category.icon, size: 60),
                color: category.iconColor,
                onPressed: !isChildTransaction ? () => _changeCategory(context) : null,
                disabledColor: category.iconColor,
              ),
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
    required this.isRecurringTransactionRunning,
  });

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
            maxLength: TransactionFormBloc.maxLongDescriptionLength,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
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
