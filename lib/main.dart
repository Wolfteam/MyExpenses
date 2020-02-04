import 'package:flutter/material.dart';
import 'pages/main_page.dart';

//TODO: USE THE CONST KEYWORD!!!
//TODO: MOVE THE ASSETS TO A COMMON CLASS
//
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Expenses',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        accentColor: Colors.amber
      ),
      home: HomePage(),
    );
  }
}