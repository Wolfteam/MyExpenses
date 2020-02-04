import 'dart:ffi';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  final String _selectedLanguage = 'English';
  final String _selectedAppTheme = 'Dark';
  final String _selectedSyncInterval = 'Each hour';
  final List<Color> _accentColors = [
    Colors.blue,
    Colors.green,
    Colors.pink,
    Colors.brown,
    Colors.red,
    Colors.cyan,
    Colors.greenAccent,
    Colors.purple,
    Colors.deepPurple,
    Colors.grey,
    Colors.orange,
    Colors.yellow,
    Colors.blueGrey,
    Colors.deepPurpleAccent,
    Colors.amberAccent,
  ];

  Widget _buildThemeSettings(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.all(10),
      elevation: 3,
      child: Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.color_lens),
                Container(
                  margin: EdgeInsets.only(left: 5),
                  child: Text(
                    "Theme",
                    style: Theme.of(context).textTheme.title,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                "Choose a base app color",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
              ),
              child: DropdownButton<String>(
                isExpanded: true,
                hint: Text("Please select an app theme"),
                value: _selectedAppTheme,
                icon: Icon(Icons.arrow_downward),
                iconSize: 24,
                style: TextStyle(color: Colors.deepPurple),
                underline: Container(
                  height: 0,
                  color: Colors.transparent,
                ),
                onChanged: (newValue) {},
                items: <String>['Dark', 'Ligth']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            SwitchListTile(
              title: Text("Use dark amoled theme"),
              // subtitle: Text("Usefull on amoled screens"),
              value: true,
              onChanged: (newValue) {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSettings(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.all(10),
      elevation: 3,
      child: Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.language),
                Container(
                  margin: EdgeInsets.only(left: 5),
                  child: Text(
                    "Language",
                    style: Theme.of(context).textTheme.title,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                "Choose a language",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
              ),
              child: DropdownButton<String>(
                isExpanded: true,
                hint: Text("Please select a language"),
                value: _selectedLanguage,
                icon: Icon(Icons.arrow_downward),
                iconSize: 24,
                style: TextStyle(color: Colors.deepPurple),
                underline: Container(
                  height: 0,
                  color: Colors.transparent,
                ),
                onChanged: (newValue) {},
                items: <String>['English', 'Spanish']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccentColorSettings(BuildContext context) {
    bool isSelected = true;
    var accentColors = _accentColors.map((color) {
      var widget = Container(
        padding: const EdgeInsets.all(8),
        child: isSelected ? Icon(Icons.check) : null,
        color: color,
      );

      isSelected = false;

      return widget;
    }).toList();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.all(10),
      elevation: 3,
      child: Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.colorize),
                Container(
                  margin: EdgeInsets.only(left: 5),
                  child: Text(
                    "Accent Color",
                    style: Theme.of(context).textTheme.title,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 5,
              ),
              child: Text(
                "Choose an accent color",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            Container(
              height: 235,
              child: GridView.count(
                  physics: NeverScrollableScrollPhysics(),
                  primary: false,
                  padding: const EdgeInsets.all(20),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  crossAxisCount: 5,
                  children: accentColors),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSyncSettings(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.all(10),
      elevation: 3,
      child: Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.sync),
                Container(
                  margin: EdgeInsets.only(left: 5),
                  child: Text(
                    "Sync",
                    style: Theme.of(context).textTheme.title,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 5,
              ),
              child: Text(
                "Choose a sync interval",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
              ),
              child: DropdownButton<String>(
                isExpanded: true,
                hint: Text("Please select an interval"),
                value: _selectedSyncInterval,
                icon: Icon(Icons.arrow_downward),
                iconSize: 24,
                style: TextStyle(color: Colors.deepPurple),
                underline: Container(
                  height: 0,
                  color: Colors.transparent,
                ),
                onChanged: (newValue) {},
                items: <String>[
                  'Each hour',
                  'Each 3 hours',
                  'Each 6 hours',
                  'Each 12 hours',
                  'Each day'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSettings(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.all(10),
      elevation: 3,
      child: Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.info_outline),
                Container(
                  margin: EdgeInsets.only(left: 5),
                  child: Text(
                    "About",
                    style: textTheme.title,
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: 5, left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Image.asset(
                    "assets/images/cost.png",
                    width: 70,
                    height: 70,
                  ),
                  Text(
                    "My Expenses",
                    textAlign: TextAlign.center,
                    style: textTheme.subtitle,
                  ),
                  Text(
                    "Version: 1.0.0.0",
                    textAlign: TextAlign.center,
                    style: textTheme.subtitle,
                  ),
                  Text(
                    "An app that helps you to keep track of your expenses.",
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 5),
                    child: Text(
                      "Donations",
                      style: textTheme.subtitle,
                    ),
                  ),
                  Text(
                    "I hope you are enjoying using this app, if you would like to buy me a coffee/beer, just send me an email.",
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 5),
                    child: Text(
                      "Support",
                      style: textTheme.subtitle,
                    ),
                  ),
                  Text(
                      "I made this app in my free time and it is also open source. If you would like to help me, report an issue, have an idea, want a feature to be implemented, etc please open an issue here:"),
                  Container(
                    margin: EdgeInsets.only(top: 5),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Github Issue Page',
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.blue,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                _lauchUrl(
                                    "https://github.com/Wolfteam/MyExpenses/Issues");
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future _lauchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white54,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: ListView(
          children: <Widget>[
            _buildThemeSettings(context),
            // Divider(
            //   color: Colors.black,
            //   thickness: 1,
            // ),
            _buildAccentColorSettings(context),
            // Divider(
            //   color: Colors.black,
            //   thickness: 1,
            // ),
            _buildLanguageSettings(context),
            // Divider(
            //   color: Colors.black,
            //   thickness: 1,
            // ),
            _buildSyncSettings(context),

            _buildAboutSettings(context),
          ],
        ),
      ),
    );
  }
}
