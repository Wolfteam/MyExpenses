import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/bloc.dart';
import '../common/enums/repetition_cycle_type.dart';
import '../common/utils/repetition_cycle_utils.dart';
import '../models/transaction_item.dart';

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
    if (widget.item != null) {
      context.bloc<TransactionFormBloc>().add(EditTransaction(widget.item));
    } else {
      context.bloc<TransactionFormBloc>().add(AddTransaction());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.item == null ? "Add transaction" : "Edit transaction"),
        leading: const BackButton(),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {},
          ),
          if (widget.item != null)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {},
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: BlocBuilder<TransactionFormBloc, TransactionFormState>(
          builder: (ctx, state) {
            return Column(
              children: _buildPage(ctx, state),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    // _amountController.dispose();
    // _descriptionController.dispose();
    // _repetitionsController.dispose();
  }

  List<Widget> _buildPage(BuildContext context, TransactionFormState state) {
    if (state is TransactionFormLoadedState) {
      return [_buildHeader(context, state), _buildForm(context, state)];
    }
    return [];
  }

  Container _buildHeader(
      final BuildContext context, final TransactionFormLoadedState state) {
    final createdAt = _dateFormat.format(state.transactionDate);

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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 5.0,
              color: Colors.white,
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
                  Text("Date: $createdAt"),
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
                              "${state.amount} \$",
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "Amount".toUpperCase(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 11.0),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: Text(
                              state.category.isAnIncome ? "Income" : "Expense",
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "Category".toUpperCase(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 11.0),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: Text(
                              getRepetitionCycleTypeName(state.repetitionCycle),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "Repetitons".toUpperCase(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 11.0),
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
                  elevation: 5.0,
                  shape: const CircleBorder(),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 40.0,
                    child: Icon(
                      state.category.icon,
                      color: state.category.iconColor,
                      size: 40,
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
      final BuildContext context, final TransactionFormLoadedState state) {
    final transactionDate = _dateFormat.format(state.transactionDate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
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
                      alignLabelWithHint: true,
                      hintText: "0\$",
                      labelText: "Amount",
                    ),
                    autovalidate: state.isAmountDirty,
                    onFieldSubmitted: (_) {
                      _fieldFocusChange(
                          context, _amountFocus, _descriptionFocus);
                    },
                    validator: (_) =>
                        state.isAmountValid ? null : 'Invalid Amount',
                  ),
                ),
              ],
            ),
            Row(
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
                      alignLabelWithHint: true,
                      labelText: "Description",
                      hintText: "A description of this transaction",
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
                        state.isDescriptionValid ? null : 'Invalid Description',
                  ),
                ),
              ],
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.start,
            //   children: <Widget>[
            //     Icon(
            //       Icons.category,
            //       size: 30,
            //     ),
            //     Expanded(
            //       child: FlatButton(
            //         child: Align(
            //             alignment: Alignment.centerLeft,
            //             child: Text("Incomes")),
            //         onPressed: () {},
            //       ),
            //     ),
            //   ],
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.calendar_today,
                  size: 30,
                ),
                Expanded(
                  child: FlatButton(
                    onPressed: () async {
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
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(transactionDate),
                    ),
                  ),
                ),
              ],
            ),
            Row(
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
                      hintText: "0",
                      alignLabelWithHint: true,
                      labelText: "Repetitions",
                    ),
                    autovalidate: state.isRepetitionsDirty,
                    onFieldSubmitted: (_) {
                      _repetitionsFocus.unfocus();
                    },
                    validator: (_) =>
                        state.isRepetitionsValid ? null : 'Invalid Repetitions',
                  ),
                ),
              ],
            ),
            if (state.areRepetitionCyclesVisible)
              Row(
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
                        icon: Icon(Icons.arrow_downward),
                        iconSize: 24,
                        style: TextStyle(color: Colors.black),
                        underline: Container(
                          height: 0,
                          color: Colors.transparent,
                        ),
                        onChanged: (newValue) {
                          context
                              .bloc<TransactionFormBloc>()
                              .add(RepetitionCycleChanged(newValue));
                        },
                        items: _repetitionCycles
                            .map<DropdownMenuItem<RepetitionCycleType>>(
                                (value) {
                          return DropdownMenuItem<RepetitionCycleType>(
                            value: value,
                            child: Text(getRepetitionCycleTypeName(value)),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            Text(
              "Add a picture",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: <Widget>[
                FlatButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.photo_library),
                  label: Text("From Gallery"),
                ),
                FlatButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.camera_enhance),
                  label: Text("From Camera"),
                ),
              ],
            )
          ],
        ),
      ),
    );
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

  _fieldFocusChange(
    BuildContext context,
    FocusNode currentFocus,
    FocusNode nextFocus,
  ) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }
}
