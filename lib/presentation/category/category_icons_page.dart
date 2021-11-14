import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/shared/extensions/i18n_extensions.dart';
import 'package:my_expenses/presentation/shared/utils/category_utils.dart';

final _selectedKey = GlobalKey();
final _icons = CategoryUtils.getAllCategoryIcons();

class CategoryIconsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance!.addPostFrameCallback((_) => _animateToIndex());

    final i18n = S.of(context);
    final icons = CategoryUtils.getAllCategoryIcons();

    final types = CategoryIconType.values.where((el) => icons.any((i) => i.type == el)).toList()
      ..sort((x, y) => i18n.getCategoryIconTypeName(x).compareTo(i18n.getCategoryIconTypeName(y)));

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
            children: types.map((e) => _CategoryIconsPerType(type: e, selectedIcon: state.selectedIcon)).toList(),
          ),
        ),
      ),
    );
  }

  void _animateToIndex() => Scrollable.ensureVisible(
        _selectedKey.currentContext!,
        duration: const Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );

  void _onIconSelected(BuildContext context, CategoryIconState state) => Navigator.of(context).pop<CategoryIcon>(state.selectedIcon);
}

class _CategoryIconsPerType extends StatelessWidget {
  final CategoryIconType type;
  final CategoryIcon selectedIcon;

  const _CategoryIconsPerType({
    Key? key,
    required this.type,
    required this.selectedIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    final theme = Theme.of(context);
    final orientation = MediaQuery.of(context).orientation;
    final icons = _icons.where((i) => i.type == type).toList();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: Text(
              i18n.getCategoryIconTypeName(type),
              style: theme.textTheme.headline6!.copyWith(fontSize: 17),
              textAlign: TextAlign.center,
            ),
          ),
          GridView.count(
            childAspectRatio: orientation == Orientation.portrait ? 1.5 : 2,
            crossAxisCount: 4,
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(
              icons.length,
              (index) => _Icon(
                icon: icons[index],
                isSelected: icons[index].name == selectedIcon.name,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Icon extends StatelessWidget {
  final CategoryIcon icon;
  final bool isSelected;

  const _Icon({
    Key? key,
    required this.icon,
    required this.isSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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

  void _onIconClick(CategoryIcon icon, BuildContext context) =>
      context.read<CategoryIconBloc>().add(CategoryIconEvent.selectionChanged(selectedIcon: icon));
}
