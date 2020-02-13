import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:my_expenses/common/utils/category_utils.dart';

import '../common/enums/category_icon_type.dart';
import '../models/category_icon.dart';

class CategoryIconsPage extends StatelessWidget {
  final _controller = ScrollController();

  final _selectedKey = new GlobalKey();

  List<Widget> _buildCategoryIconsPerType(
    BuildContext context,
    String categoryType,
    List<CategoryIcon> icons,
  ) {
    var textTheme = Theme.of(context).textTheme;
    var orientation = MediaQuery.of(context).orientation;
    var grid = GridView.count(
      childAspectRatio: orientation == Orientation.portrait ? 1.5 : 2,
      crossAxisCount: 4,
      padding: EdgeInsets.all(0),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: List.generate(
        icons.length,
        (index) {
          return IconButton(
            key: icons[index].isSelected ? _selectedKey : null,
            iconSize: 30,
            color: icons[index].isSelected ? Colors.redAccent : Colors.black87,
            icon: icons[index].icon,
            onPressed: () {},
          );
        },
      ),
    );
    var widgets = [
      Container(
        margin: EdgeInsets.only(top: 10),
        child: Text(
          categoryType,
          style: textTheme.subhead,
          textAlign: TextAlign.center,
        ),
      ),
      grid
    ];

    return widgets;
  }

  List<Widget> _buildCategoryIcons(BuildContext context) {
    var categoryIcons = List<Widget>();
    var icons = CategoryUtils.getAllCategoryIcons();

    for (CategoryIconType type in CategoryIconType.values) {
      var filteredIcons = icons.where((i) => i.type == type).toList();
      if (filteredIcons.length <= 0) {
        print("Couldnt find categories icon for type = $type");
        continue;
      }

      String categoryType = CategoryUtils.getCategoryIconTypeName(type);
      var widgets = _buildCategoryIconsPerType(
        context,
        categoryType,
        filteredIcons,
      );
      categoryIcons.addAll(widgets);
    }

    return categoryIcons;
  }

  _animateToIndex() => Scrollable.ensureVisible(
        _selectedKey.currentContext,
        duration: Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) => _animateToIndex());

    return Scaffold(
      appBar: AppBar(
        title: Text("Pick an icon"),
        leading: BackButton(),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _animateToIndex,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _buildCategoryIcons(context),
        ),
      ),
    );
  }
}
