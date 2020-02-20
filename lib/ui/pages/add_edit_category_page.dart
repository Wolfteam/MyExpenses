import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/block_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_colorpicker/material_picker.dart';

import '../../common/presentation/custom_icons.dart';
import '../pages/category_icons_page.dart';

class AddEditCategoryPage extends StatelessWidget {
  final _selectedTransactionType = "Income";

  Container _buildHeader(BuildContext context) {
    return Container(
      height: 200.0,
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
                    "Category name",
                    style: Theme.of(context).textTheme.title,
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Container(
                    height: 40.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
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
                              "N/A",
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "Parent".toUpperCase(),
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
                  elevation: 10,
                  shape: CircleBorder(),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      iconSize: 65,
                      icon: Icon(CustomIcons.help_circled),
                      color: Colors.lightBlue,
                      onPressed: () {
                        var route = MaterialPageRoute(
                            builder: (ctx) => CategoryIconsPage());
                        Navigator.of(context).push(route);
                      },
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

  Widget _buildForm(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 10),
                child: IconButton(
                  icon: Icon(
                    CustomIcons.help_circled,
                    size: 30,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    _showColorPicker(context);
                  },
                ),
              ),
              Expanded(
                child: TextField(
                  maxLines: 1,
                  minLines: 1,
                  maxLength: 255,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    alignLabelWithHint: true,
                    hintText: "Category name",
                    labelText: "Name",
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Radio<String>(
                value: "Income",
                groupValue: _selectedTransactionType,
                onChanged: (value) {},
              ),
              Text("Income"),
              Radio<String>(
                value: "Expense",
                groupValue: _selectedTransactionType,
                onChanged: (value) {},
              ),
              Text("Expenses"),
            ],
          ),
          ListTile(
            contentPadding: EdgeInsets.only(left: 10),
            leading: Icon(
              CustomIcons.flow_split,
              size: 30,
              color: Colors.blue,
            ),
            title: Text("Parent"),
            onTap: () {},
          )
        ],
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      child: AlertDialog(
        title: const Text('Pick a color!'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: Colors.red,
            onColorChanged: (newColor) {},
            // enableLabel: true,
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: const Text('Got it'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add category"),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildHeader(context),
            _buildForm(context),
          ],
        ),
      ),
    );
  }
}
