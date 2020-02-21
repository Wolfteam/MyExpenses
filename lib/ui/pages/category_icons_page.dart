import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../common/enums/category_icon_type.dart';
import '../../common/utils/category_utils.dart';
import '../../models/category_icon.dart';

class CategoryIconsPage extends StatelessWidget {
  final _selectedKey = GlobalKey();

  List<Widget> _buildCategoryIconsPerType(
    BuildContext context,
    String categoryType,
    List<CategoryIcon> icons,
  ) {
    final theme = Theme.of(context);
    final orientation = MediaQuery.of(context).orientation;
    final grid = GridView.count(
      childAspectRatio: orientation == Orientation.portrait ? 1.5 : 2,
      crossAxisCount: 4,
      padding: const EdgeInsets.all(0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(
        icons.length,
        (index) {
          return IconButton(
            key: icons[index].isSelected ? _selectedKey : null,
            iconSize: 30,
            color: icons[index].isSelected ? theme.primaryColor : Colors.black87,
            icon: icons[index].icon,
            onPressed: () {},
          );
        },
      ),
    );
    final widgets = [
      Container(
        margin: const EdgeInsets.only(top: 10),
        child: Text(
          categoryType,
          style: theme.textTheme.subhead,
          textAlign: TextAlign.center,
        ),
      ),
      grid
    ];

    return widgets;
  }

  List<Widget> _buildCategoryIcons(BuildContext context) {
    final categoryIcons = <Widget>[];
    final icons = CategoryUtils.getAllCategoryIcons();

    for (final type in CategoryIconType.values) {
      final filteredIcons = icons.where((i) => i.type == type).toList();
      if (filteredIcons.isEmpty) {
        print('Couldnt find categories icon for type = $type');
        continue;
      }

      final categoryType = CategoryUtils.getCategoryIconTypeName(type);
      final widgets = _buildCategoryIconsPerType(
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
