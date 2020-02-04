import 'package:flutter/material.dart';

import '../models/category_item.dart';

class CategoriesListPage extends StatelessWidget {
  final _incomes = <CategoryItem>[
    CategoryItem(true, "Category A", Icons.attach_money, Colors.green),
    CategoryItem(true, "Category B", Icons.flag, Colors.red),
    CategoryItem(true, "Category C", Icons.gamepad, Colors.black),
    CategoryItem(true, "Category D", Icons.image, Colors.blue),
    CategoryItem(true, "Category E", Icons.attachment, Colors.amber),
    CategoryItem(true, "Category F", Icons.backup, Colors.orange),
    CategoryItem(true, "Category G", Icons.pages, Colors.indigo),
    CategoryItem(true, "Category H", Icons.attach_money, Colors.green),
    CategoryItem(true, "Category I", Icons.flag, Colors.red),
    CategoryItem(true, "Category J", Icons.gamepad, Colors.black),
    CategoryItem(true, "Category K", Icons.image, Colors.blue),
    CategoryItem(true, "Category L", Icons.attachment, Colors.amber),
    CategoryItem(true, "Category M", Icons.backup, Colors.orange),
    CategoryItem(true, "Category N", Icons.pages, Colors.indigo),
  ];

  Widget _buildCategoryItem(CategoryItem category) {
    var icon = IconTheme(
      data: new IconThemeData(color: category.iconColor),
      child: new Icon(category.icon),
    );
    return ListTile(
      leading: icon,
      title: Text(category.name),
      onTap: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _incomes.length,
        itemBuilder: (ctx, index) => _buildCategoryItem(_incomes[index]),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: Icon(Icons.add),
        onPressed: () {},
      ),
    );
  }
}


