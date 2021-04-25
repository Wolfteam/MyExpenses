import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/generated/l10n.dart';

import '../../bloc/category_icon/category_icon_bloc.dart';
import '../../common/enums/category_icon_type.dart';
import '../../common/extensions/i18n_extensions.dart';
import '../../common/utils/category_utils.dart';
import '../../models/category_icon.dart';

class CategoryIconsPage extends StatelessWidget {
  final _selectedKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance!.addPostFrameCallback((_) => _animateToIndex());

    final i18n = S.of(context);

    return BlocBuilder<CategoryIconBloc, CategoryIconState>(
        builder: (ctx, state) => Scaffold(
              appBar: AppBar(
                title: Text(i18n.pickIcon),
                leading: const BackButton(),
                actions: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: () => _onIconSelected(context, state),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _buildCategoryIcons(context, state),
                ),
              ),
            ));
  }

  List<Widget> _buildCategoryIcons(BuildContext context, CategoryIconState state) {
    final categoryIcons = <Widget>[];
    final i18n = S.of(context);
    final icons = CategoryUtils.getAllCategoryIcons();

    for (final type in CategoryIconType.values) {
      final filteredIcons = icons.where((i) => i.type == type).toList();
      if (filteredIcons.isEmpty) {
        continue;
      }

      final categoryType = i18n.getCategoryIconTypeName(type);
      final widgets = _buildCategoryIconsPerType(
        context,
        categoryType,
        filteredIcons,
        state,
      );
      categoryIcons.add(widgets);
    }

    return categoryIcons;
  }

  Widget _buildCategoryIconsPerType(
    BuildContext context,
    String categoryType,
    List<CategoryIcon> icons,
    CategoryIconState state,
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
        (index) => _buildIcon(icons[index], theme, context, state),
      ),
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: Text(
              categoryType,
              style: theme.textTheme.headline6!.copyWith(fontSize: 17),
              textAlign: TextAlign.center,
            ),
          ),
          grid,
        ],
      ),
    );
  }

  Widget _buildIcon(
    CategoryIcon icon,
    ThemeData theme,
    BuildContext context,
    CategoryIconState state,
  ) {
    final isSelected = icon.name == state.selectedIcon.name;
    return IconButton(
      key: isSelected ? _selectedKey : null,
      iconSize: 30,
      color: isSelected
          ? theme.primaryColor
          : theme.brightness == Brightness.dark
              ? Colors.white
              : Colors.black87,
      icon: icon.icon,
      onPressed: () => _onIconClick(icon, context),
    );
  }

  void _animateToIndex() => Scrollable.ensureVisible(
        _selectedKey.currentContext!,
        duration: const Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );

  void _onIconClick(CategoryIcon icon, BuildContext context) =>
      context.read<CategoryIconBloc>().add(CategoryIconEvent.selectionChanged(selectedIcon: icon));

  void _onIconSelected(BuildContext context, CategoryIconState state) => Navigator.of(context).pop<CategoryIcon>(state.selectedIcon);
}
