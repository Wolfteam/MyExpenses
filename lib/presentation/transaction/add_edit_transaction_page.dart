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
import 'package:my_expenses/presentation/shared/payment_method_picker_sheet.dart';
import 'package:my_expenses/presentation/shared/styles.dart';
import 'package:my_expenses/presentation/shared/utils/bloc_utils.dart';
import 'package:my_expenses/presentation/shared/utils/toast_utils.dart';
import 'package:my_expenses/presentation/transaction/widgets/form_app_bar.dart';
import 'package:my_expenses/presentation/transaction/widgets/form_date_button.dart';
import 'package:my_expenses/presentation/transaction/widgets/form_image_preview.dart';
import 'package:my_expenses/presentation/transaction/widgets/form_repetition_cycle_dropdown.dart';
import 'package:provider/provider.dart';

part 'widgets/_amount_input.dart';
part 'widgets/_description_input.dart';
part 'widgets/_long_description_input.dart';
part 'widgets/_recurring_switch.dart';
part 'widgets/_payment_method_selector.dart';
part 'widgets/_add_edit_transaction_header.dart';

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
      listener: (ctx, state) {
        switch (state) {
          case TransactionFormStateInitialState():
            if (state.errorOccurred) {
              ToastUtils.showWarningToast(ctx, i18n.unknownErrorOcurred);
            }

            if (state.nextRecurringDateWasUpdated) {
              BlocUtils.raiseCommonBlocEvents(context, reloadTransactions: true);
            }
          case TransactionFormStateTransactionChanged():
            final msg = state.wasUpdated || state.wasCreated
                ? i18n.transactionsWasSuccessfullySaved
                : i18n.transactionsWasSuccessfullyDeleted;
            ToastUtils.showSucceedToast(ctx, msg);
            BlocUtils.raiseCommonBlocEvents(context, reloadTransactions: true);
            Navigator.of(ctx).pop();
          default:
            break;
        }
      },

      builder: (ctx, state) {
        switch (state) {
          case TransactionFormStateInitialState():
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
                      context.read<TransactionFormBloc>().add(
                        TransactionFormEvent.categoryWasUpdated(category: selectedCat),
                      );
                    },
                  ),
                  if (isChildTransaction)
                    Text(
                      i18n.childTransactionCantBeDeleted,
                      style: theme.textTheme.bodySmall!.copyWith(color: theme.colorScheme.primary),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          if (state.isParentTransaction)
                            _RecurringSwitch(isRecurringTransactionRunning: state.isRecurringTransactionRunning),
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
                          const SizedBox(height: 10),
                          _PaymentMethodSelector(
                            paymentMethodId: state.paymentMethodId,
                            isChildTransaction: isChildTransaction,
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
                          OverflowBar(
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
              appBar: FormAppBar(
                isNewTransaction: TransactionFormState.isNewTransaction(state),
                isParentTransaction: state.isParentTransaction,
                toEditTransaction: widget.item != null,
                isChildTransaction: TransactionFormState.isChildTransaction(state),
                isFormValid: TransactionFormState.isFormValid(state),
                description: state.description,
              ),
              body: SafeArea(child: scrollView),
            );

            if (state.isSavingForm) {
              return Stack(
                children: [
                  scaffold,
                  const Opacity(opacity: 0.5, child: ModalBarrier(dismissible: false, color: Colors.black)),
                  const Center(child: CircularProgressIndicator()),
                ],
              );
            }

            return scaffold;
          default:
            return const Center(child: CircularProgressIndicator());
        }
      },
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
    context.read<TransactionFormBloc>().add(
      TransactionFormEvent.descriptionChanged(description: _descriptionController.text),
    );
  }

  void _longDescriptionChanged() {
    if (_currentLongDescription == _longDescriptionController.text) {
      return;
    }
    _currentLongDescription = _longDescriptionController.text;
    context.read<TransactionFormBloc>().add(
      TransactionFormEvent.longDescriptionChanged(longDescription: _longDescriptionController.text),
    );
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
      if (context.mounted && mounted) {
        ToastUtils.showWarningToast(context, i18n.acceptPermissionsToUseThisFeature);
      }
    }
  }
}
