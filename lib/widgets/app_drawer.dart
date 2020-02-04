import 'dart:ui';

import 'package:flutter/material.dart';

import 'reports/reports_bottom_sheet_dialog.dart';

class AppDrawer extends StatelessWidget {
  void _onSelectedItem(int index, BuildContext context) {
    Navigator.pop(context);
    //TODO: IF THE CONTENT IS TO LARGE, WE CANT CLOSE THE SHEET
    var isInLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(35),
          topLeft: Radius.circular(35),
        ),
      ),
      isDismissible: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => ReportsBottomSheetDialog()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Image.asset(
                    "assets/images/cost.png",
                    width: 80,
                    height: 80,
                  ),
                  Flexible(
                    child: Text(
                      "Efrain Bastidas",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      "ebastidas@smartersolutions.com.ve",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            ),
            decoration: BoxDecoration(color: Colors.blue),
          ),
          Ink(
            color: Colors.red,
            child: ListTile(
              selected: true,
              title: Text("Transactions"),
              leading: Icon(Icons.account_balance),
              onTap: () {
                _onSelectedItem(0, context);
              },
            ),
          ),
          ListTile(
            title: Text("Reports"),
            leading: Icon(Icons.insert_drive_file),
            onTap: () {
              _onSelectedItem(1, context);
            },
          ),
          ListTile(
            title: Text("Charts"),
            leading: Icon(Icons.pie_chart),
            onTap: () {
              _onSelectedItem(2, context);
            },
          ),
          ListTile(
            title: Text("Categories"),
            leading: Icon(Icons.category),
            onTap: () {
              _onSelectedItem(3, context);
            },
          ),
          Divider(),
          ListTile(
            title: Text("Settings"),
            leading: Icon(Icons.settings),
            onTap: () {
              _onSelectedItem(4, context);
            },
          ),
          ListTile(
            title: Text("Logout"),
            leading: Icon(Icons.arrow_back),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
