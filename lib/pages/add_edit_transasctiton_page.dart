import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/bloc.dart';

class AddEditTransactionPage extends StatefulWidget {
  @override
  _AddEditTransactionPageState createState() => _AddEditTransactionPageState();
}

class _AddEditTransactionPageState extends State<AddEditTransactionPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _repetitionsController = TextEditingController();

  @override
  void initState() {
    print("init");
    _amountController.addListener(_amountChanged);
    _descriptionController.addListener(_descriptionChanged);
    _repetitionsController.addListener(_repetitionsChanged);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add transaction"),
        leading: BackButton(),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildHeader(context),
            _buildForm(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Container _buildHeader(BuildContext context) {
    return Container(
      height: 240.0,
      child: Stack(
        children: <Widget>[
          Container(
            height: 150,
            color: Colors.green,
          ),
          Container(
            padding: EdgeInsets.only(
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
                  SizedBox(
                    height: 50.0,
                  ),
                  Text(
                    "Description",
                    style: Theme.of(context).textTheme.title,
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Text("Created at: 01/12/2020"),
                  SizedBox(
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
                              "400 \$",
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "Amount".toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 11.0),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: Text(
                              "Income",
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "Category".toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 11.0),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: Text(
                              "Each Month",
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "Repetitons".toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 11.0),
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
            margin: EdgeInsets.only(top: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Material(
                  elevation: 5.0,
                  shape: CircleBorder(),
                  child: CircleAvatar(
                    radius: 40.0,
                    child: Icon(Icons.add),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return BlocBuilder<TransactionFormBloc, TransactionFormState>(
      builder: (ctx, state) {
        if (state is TransactionFormInitial)
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(right: 10),
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
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            alignLabelWithHint: true,
                            hintText: "0\$",
                            labelText: "Amount",
                          ),
                          autovalidate: true,
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
                        margin: EdgeInsets.only(right: 10),
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
                          decoration: InputDecoration(
                            alignLabelWithHint: true,
                            labelText: "Description",
                            hintText: "A description of this transaction",
                          ),
                          autovalidate: true,
                          validator: (_) => state.isDescriptionValid
                              ? null
                              : 'Invalid Description',
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Icon(
                        Icons.category,
                        size: 30,
                      ),
                      Expanded(
                        child: FlatButton(
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text("Incomes")),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Icon(
                        Icons.calendar_today,
                        size: 30,
                      ),
                      Expanded(
                        child: FlatButton(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Today"),
                          ),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(right: 10),
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
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "0",
                            alignLabelWithHint: true,
                            labelText: "Repetitions",
                          ),
                          autovalidate: true,
                          validator: (_) => state.isDescriptionValid
                              ? null
                              : 'Invalid Repetitions',
                        ),
                      ),
                    ],
                  ),
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
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: Text("Please select an app theme"),
                            value: "Each Month",
                            icon: Icon(Icons.arrow_downward),
                            iconSize: 24,
                            style: TextStyle(color: Colors.deepPurple),
                            underline: Container(
                              height: 0,
                              color: Colors.transparent,
                            ),
                            onChanged: (newValue) {},
                            items: <String>[
                              "None",
                              "Each Day",
                              "Each Week",
                              "Each Month",
                              "Each Year"
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
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
        return null;
      },
    );
  }

  void _amountChanged() {
    var amount = double.tryParse(_amountController.text) ?? 0;
    context.bloc<TransactionFormBloc>().add(AmountChanged(amount));
  }

  void _descriptionChanged() {
    context
        .bloc<TransactionFormBloc>()
        .add(DescriptionChanged(_descriptionController.text));
  }

  void _repetitionsChanged() {
    var repetitions = int.tryParse(_repetitionsController.text) ?? 0;
    context.bloc<TransactionFormBloc>().add(RepetitionsChanged(repetitions));
  }
}
