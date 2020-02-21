import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/block_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_colorpicker/material_picker.dart';

import '../../common/enums/transaction_type.dart';
import '../../common/presentation/custom_icons.dart';
import '../../generated/i18n.dart';
import '../pages/category_icons_page.dart';

class AddEditCategoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final i18n = I18n.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(i18n.addCategory),
        leading: const BackButton(),
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

  Container _buildHeader(BuildContext context) {
    final i18n = I18n.of(context);

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
                    i18n.categoryName,
                    style: Theme.of(context).textTheme.title,
                  ),
                  const SizedBox(
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
                              i18n.income,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              i18n.category.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 11.0),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: Text(
                              i18n.na,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              i18n.parent.toUpperCase(),
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
            margin: const EdgeInsets.only(top: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Material(
                  elevation: 10,
                  shape: const CircleBorder(),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      iconSize: 65,
                      icon: Icon(CustomIcons.help_circled),
                      color: Colors.lightBlue,
                      onPressed: () {
                        final route = MaterialPageRoute(
                          builder: (ctx) => CategoryIconsPage(),
                        );
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
    final i18n = I18n.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(right: 10),
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
                    hintText: i18n.categoryName,
                    labelText: i18n.name,
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Radio<TransactionType>(
                value: TransactionType.incomes,
                groupValue: TransactionType.incomes,
                onChanged: (value) {},
              ),
              Text(i18n.income),
              Radio<TransactionType>(
                value: TransactionType.expenses,
                groupValue: TransactionType.incomes,
                onChanged: (value) {},
              ),
              Text(i18n.expense),
            ],
          ),
          ListTile(
            contentPadding: EdgeInsets.only(left: 10),
            leading: Icon(
              CustomIcons.flow_split,
              size: 30,
              color: Colors.blue,
            ),
            title: Text(i18n.parent),
            onTap: () {},
          )
        ],
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    final i18n = I18n.of(context);
    showDialog(
      context: context,
      child: AlertDialog(
        title: Text(i18n.pickColor),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: Colors.red,
            onColorChanged: (newColor) {},
            // enableLabel: true,
          ),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(i18n.ok),
          ),
        ],
      ),
    );
  }
}
