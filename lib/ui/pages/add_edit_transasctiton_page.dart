import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../bloc/charts/charts_bloc.dart';
import '../../bloc/transaction_form/transaction_form_bloc.dart';
import '../../bloc/transactions/transactions_bloc.dart';
import '../../common/enums/repetition_cycle_type.dart';
import '../../common/extensions/i18n_extensions.dart';
import '../../common/extensions/string_extensions.dart';
import '../../common/utils/bloc_utils.dart';
import '../../common/utils/date_utils.dart';
import '../../common/utils/i18n_utils.dart';
import '../../common/utils/toast_utils.dart';
import '../../generated/i18n.dart';
import '../../models/category_item.dart';
import '../../models/current_selected_category.dart';
import '../../models/transaction_item.dart';
import 'categories_page.dart';

class AddEditTransactionPage extends StatefulWidget {
  final TransactionItem item;

  const AddEditTransactionPage({this.item});

  @override
  _AddEditTransactionPageState createState() => _AddEditTransactionPageState();
}

class _AddEditTransactionPageState extends State<AddEditTransactionPage> {
  TextEditingController _amountController;
  TextEditingController _descriptionController;
  TextEditingController _longDescriptionController;

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
      context.bloc<TransactionFormBloc>().add(EditTransaction(widget.item.id));
    } else {
      context.bloc<TransactionFormBloc>().add(AddTransaction());
    }

    _didChangeDependencies = true;
  }

  @override
  Widget build(BuildContext context) {
    final i18n = I18n.of(context);

    return BlocConsumer<TransactionFormBloc, TransactionFormState>(
      listener: (ctx, state) async {
        if (state is TransactionFormLoadedState) {
          if (state.errorOccurred) {
            showWarningToast(i18n.unknownErrorOcurred);
          }

          if (state.nextRecurringDateWasUpdated) {
            BlocUtils.raiseCommonBlocEvents(
              context,
              reloadTransactions: true,
            );
          }
        }

        if (state is TransactionChangedState) {
          final msg = state.wasUpdated || state.wasCreated
              ? i18n.transactionsWasSuccessfullySaved
              : i18n.transactionsWasSuccessfullyDeleted;
          showSucceedToast(msg);

          ctx.bloc<TransactionsBloc>().add(GetTransactions(inThisDate: state.transactionDate));
          ctx.bloc<ChartsBloc>().add(LoadChart(state.transactionDate));

          Navigator.of(ctx).pop();
        }
      },
      builder: (ctx, state) {
        return _buildPage(ctx, state);
      },
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _longDescriptionController.dispose();
    super.dispose();
  }

  AppBar _buildAppBar(TransactionFormState state) {
    final i18n = I18n.of(context);
    if (state is TransactionFormLoadedState) {
      return AppBar(
        title: Text(
          widget.item == null ? i18n.addTransaction : i18n.editTransaction,
        ),
        leading: const BackButton(),
        actions: [
          if (!state.isChildTransaction)
            IconButton(
              icon: Icon(
                Icons.save,
              ),
              onPressed: state.isFormValid ? _saveTransaction : null,
            ),
          if (!state.isNewTransaction && !state.isChildTransaction)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _showDeleteConfirmationDialog(state),
            ),
        ],
      );
    }
    return null;
  }

  Widget _buildPage(BuildContext context, TransactionFormState state) {
    final i18n = I18n.of(context);
    final theme = Theme.of(context);

    const loadingIndicator = Center(
      child: CircularProgressIndicator(),
    );

    if (state is TransactionFormLoadedState) {
      if (state.errorOccurred) {
        showWarningToast(i18n.unknownErrorOcurred);
      }

      final scrollView = SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context, state),
            if (state.isChildTransaction)
              Text(
                i18n.childTransactionCantBeDeleted,
                style: theme.textTheme.caption.copyWith(color: theme.primaryColorDark),
              ),
            _buildForm(context, state),
          ],
        ),
      );

      final scaffold = Scaffold(
        appBar: _buildAppBar(state),
        body: scrollView,
      );

      if (state.isSavingForm) {
        return Stack(
          children: [
            scaffold,
            const Opacity(
              opacity: 0.5,
              child: ModalBarrier(
                dismissible: false,
                color: Colors.black,
              ),
            ),
            loadingIndicator,
          ],
        );
      }

      return scaffold;
    }

    return loadingIndicator;
  }

  Container _buildHeader(
    final BuildContext context,
    final TransactionFormLoadedState state,
  ) {
    const cornerRadius = Radius.circular(20);
    final theme = Theme.of(context);
    final i18n = I18n.of(context);
    final dateString =
        state.isParentTransaction && state.nextRecurringDate != null && state.isRecurringTransactionRunning
            ? i18n.nextDateOn(DateUtils.formatDateWithoutLocale(
                state.nextRecurringDate,
                DateUtils.monthDayAndYearFormat,
              ))
            : '${i18n.date}: ${state.transactionDateString}';

    return Container(
      height: 260.0,
      child: Stack(
        children: <Widget>[
          Container(
            height: 150,
            color: theme.primaryColorDark,
          ),
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
                    state.description,
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
                              style: theme.textTheme.headline6,
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
                              state.category.isAnIncome ? i18n.income : i18n.expense,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.headline6,
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
                              i18n.translateRepetitionCycleType(
                                state.repetitionCycle,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.headline6,
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
                  borderOnForeground: true,
                  type: MaterialType.circle,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: !state.isChildTransaction
                        ? IconButton(
                            iconSize: 60,
                            icon: Icon(state.category.icon),
                            color: state.category.iconColor,
                            onPressed: () => _changeCategory(state),
                          )
                        : Icon(
                            state.category.icon,
                            size: 75,
                            color: state.category.iconColor,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (state.isParentTransaction) _buildRecurringSwitch(context, state),
            _buildAmountInput(context, state),
            _buildDescriptionInput(state),
            _buildLongDescriptionInput(state),
            _buildTransactionDateButton(context, state),
            _buildRepetitionCyclesDropDown(state),
            ..._buildPickImageButtons(context, state),
          ],
        ),
      ),
    );
  }

  Widget _buildRecurringSwitch(
    final BuildContext context,
    final TransactionFormLoadedState state,
  ) {
    final theme = Theme.of(context);
    final i18n = I18n.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SwitchListTile(
            activeColor: theme.accentColor,
            value: state.isRecurringTransactionRunning,
            title: Text(
              state.isRecurringTransactionRunning ? i18n.running : i18n.stopped,
            ),
            secondary: Icon(
              state.isRecurringTransactionRunning ? Icons.play_arrow : Icons.stop,
              size: 30,
            ),
            subtitle: Text(
              state.isRecurringTransactionRunning
                  ? i18n.recurringTransactionIsNowRunning
                  : i18n.recurringTransactionIsNowStopped,
            ),
            onChanged: _isRunningChanged,
          ),
        ],
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
            enabled: !state.isChildTransaction,
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
            enabled: !state.isChildTransaction,
            controller: _descriptionController,
            keyboardType: TextInputType.text,
            maxLines: 1,
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
            onFieldSubmitted: (_) => _fieldFocusChange(context, _descriptionFocus, _longDescriptionFocus),
            validator: (_) => state.isDescriptionValid ? null : i18n.invalidDescription,
          ),
        ),
      ],
    );
  }

  Widget _buildLongDescriptionInput(final TransactionFormLoadedState state) {
    final suffixIcon = _buildSuffixIconButton(
      _longDescriptionController,
      _longDescriptionFocus,
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
            enabled: !state.isChildTransaction,
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
            autovalidate: state.isLongDescriptionDirty,
            onFieldSubmitted: (_) => _fieldFocusChange(context, _longDescriptionFocus, _repetitionsFocus),
            validator: (_) => state.isLongDescriptionValid ? null : i18n.invalidDescription,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionDateButton(
    final BuildContext context,
    final TransactionFormLoadedState state,
  ) {
    final i18n = I18n.of(context);
    final theme = Theme.of(context);
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Icon(
              Icons.calendar_today,
              size: 30,
            ),
            Expanded(
              child: FlatButton(
                onPressed: !state.isChildTransaction ? () => _transactionDateClicked(state) : null,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(state.transactionDateString),
                ),
              ),
            ),
          ],
        ),
        if (!state.isChildTransaction &&
            !state.isTransactionDateValid &&
            state.repetitionCycle != RepetitionCycleType.none)
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: Text(
              i18n.recurringDateMustStartFromTomorrow,
              textAlign: TextAlign.center,
              style: theme.textTheme.caption.copyWith(color: theme.primaryColorDark),
            ),
          ),
      ],
    );
  }

  Widget _buildRepetitionCyclesDropDown(
    final TransactionFormLoadedState state,
  ) {
    final i18n = I18n.of(context);
    final theme = Theme.of(context);

    //This is to avoid loosing the isParentTransaction property and
    //to avoid a potential bug
    final repetitionCyclesToUse = state.isParentTransaction
        ? _repetitionCycles.where((c) => c.index != RepetitionCycleType.none.index)
        : _repetitionCycles;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Icon(
                Icons.repeat,
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
                      i18n.translateRepetitionCycleType(state.repetitionCycle),
                    ),
                    value: state.repetitionCycle,
                    iconSize: 24,
                    underline: Container(
                      height: 0,
                      color: Colors.transparent,
                    ),
                    onChanged: !state.isChildTransaction ? _repetitionCycleChanged : null,
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
          if (!state.isChildTransaction && state.repetitionCycle != RepetitionCycleType.none)
            Padding(
              padding: const EdgeInsets.only(bottom: 5, left: 8, right: 8),
              child: Text(
                i18n.recurringTransactionStartsOn(
                  DateUtils.formatAppDate(
                    state.transactionDate,
                    state.language,
                    DateUtils.monthDayAndYearFormat,
                  ),
                  i18n.translateRepetitionCycleType(state.repetitionCycle).toLowerCase(),
                ),
                textAlign: TextAlign.center,
                style: theme.textTheme.caption.copyWith(color: theme.primaryColorDark),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSuffixIconButton(
    TextEditingController controller,
    FocusNode focusNode,
  ) {
    final suffixIcon = !controller.text.isNullEmptyOrWhitespace && focusNode.hasFocus
        ? IconButton(
            alignment: Alignment.bottomCenter,
            icon: Icon(Icons.close),
            onPressed: () => controller.clear(),
          )
        : null;

    return suffixIcon;
  }

  List<Widget> _buildPickImageButtons(
    BuildContext context,
    TransactionFormLoadedState state,
  ) {
    final theme = Theme.of(context);
    final i18n = I18n.of(context);

    return [
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
            onPressed: !state.isChildTransaction ? () => _pickPicture(true, i18n) : null,
            icon: Icon(Icons.photo_library),
            label: Text(i18n.fromGallery),
          ),
          FlatButton.icon(
            textColor: theme.primaryColor,
            onPressed: !state.isChildTransaction ? () => _pickPicture(false, i18n) : null,
            icon: Icon(Icons.camera_enhance),
            label: Text(i18n.fromCamera),
          ),
        ],
      ),
      if (state.imageExists)
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
                onTap: () => _showImageDialog(state.imagePath),
                child: FadeInImage(
                  fit: BoxFit.fill,
                  fadeInDuration: const Duration(seconds: 1),
                  placeholder: MemoryImage(kTransparentImage),
                  image: FileImage(File(state.imagePath)),
                ),
              ),
            ],
          ),
        ),
    ];
  }

  void _amountChanged() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    context.bloc<TransactionFormBloc>().add(AmountChanged(amount));
  }

  void _descriptionChanged() {
    context.bloc<TransactionFormBloc>().add(DescriptionChanged(_descriptionController.text));
  }

  void _longDescriptionChanged() =>
      context.bloc<TransactionFormBloc>().add(LongDescriptionChanged(_longDescriptionController.text));

  void _repetitionCycleChanged(RepetitionCycleType newValue) {
    context.bloc<TransactionFormBloc>().add(RepetitionCycleChanged(newValue));
  }

  Future _transactionDateClicked(TransactionFormLoadedState state) async {
    DateTime selectedDate;
    if (state.repetitionCycle != RepetitionCycleType.biweekly) {
      selectedDate = await showDatePicker(
        context: context,
        initialDate: state.transactionDate,
        firstDate: state.firstDate,
        lastDate: state.lastDate,
        locale: currentLocale(state.language),
      );
    } else {
      selectedDate = await showDatePicker(
          context: context,
          initialDate: state.transactionDate,
          firstDate: state.firstDate,
          lastDate: state.lastDate,
          locale: currentLocale(state.language),
          selectableDayPredicate: (date) {
            if (date.isAtSameMomentAs(state.transactionDate) || date.day == 1) {
              return true;
            }

            final biweeklyDate = DateUtils.getNextBiweeklyDate(
              date.subtract(const Duration(days: 1)),
            );

            return biweeklyDate.day == date.day;
          });
    }

    if (selectedDate == null) return;
    context.bloc<TransactionFormBloc>().add(TransactionDateChanged(selectedDate));
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
      final amount = (double.tryParse(_amountController.text) ?? 0).abs();
      final amountText = selectedCat.isAnIncome ? '$amount' : '${amount * -1}';
      _amountController.text = amountText;
      if (_descriptionController.text.isNullEmptyOrWhitespace) {
        _descriptionController.text = selectedCat.name;
      }
      context.bloc<TransactionFormBloc>().add(CategoryWasUpdated(selectedCat));
    }
  }

  void _saveTransaction() {
    context.bloc<TransactionFormBloc>().add(FormSubmitted());
  }

  void _showDeleteConfirmationDialog(
    TransactionFormLoadedState state,
  ) {
    final i18n = I18n.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(i18n.deleteX(state.description)),
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

              if (state.isParentTransaction) {
                _showDeleteChildsConfirmationDialog();
              } else {
                context.bloc<TransactionFormBloc>().add(const DeleteTransaction());
              }
            },
            child: Text(i18n.yes),
          ),
        ],
      ),
    );
  }

  void _showDeleteChildsConfirmationDialog() {
    final i18n = I18n.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(i18n.deleteX(i18n.childTransactions.toLowerCase())),
        content: Text(i18n.deleteChildTransactionsConfirmation),
        actions: <Widget>[
          OutlineButton(
            textColor: Theme.of(context).primaryColor,
            onPressed: () {
              context.bloc<TransactionFormBloc>().add(const DeleteTransaction(keepChilds: true));
              Navigator.of(ctx).pop();
            },
            child: Text(i18n.no),
          ),
          RaisedButton(
            color: Theme.of(ctx).primaryColor,
            onPressed: () {
              context.bloc<TransactionFormBloc>().add(const DeleteTransaction(keepChilds: false));
              Navigator.of(ctx).pop();
            },
            child: Text(i18n.yes),
          ),
        ],
      ),
    );
  }

  void _showImageDialog(String imagePath) {
    showDialog(
      barrierDismissible: true,
      context: context,
      child: Material(
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
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                  IconButton(
                    color: Theme.of(context).primaryColor,
                    icon: Icon(Icons.delete),
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

  void _showDeleteImageDialog() {
    final i18n = I18n.of(context);
    showDialog(
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
              context.bloc<TransactionFormBloc>().add(const ImageChanged(path: '', imageExists: false));
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

  Future<void> _pickPicture(bool fromGallery, I18n i18n) async {
    try {
      final image = await ImagePicker().getImage(
        source: fromGallery ? ImageSource.gallery : ImageSource.camera,
        maxHeight: 600,
        maxWidth: 600,
      );
      if (image == null) return;
      context.bloc<TransactionFormBloc>().add(ImageChanged(path: image.path, imageExists: true));
    } catch (e) {
      showWarningToast(i18n.acceptPermissionsToUseThisFeature);
    }
  }

  void _isRunningChanged(bool newValue) =>
      context.bloc<TransactionFormBloc>().add(IsRunningChanged(isRunning: newValue));
}
