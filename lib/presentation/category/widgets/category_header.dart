import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/category/category_icons_page.dart';
import 'package:my_expenses/presentation/shared/styles.dart';
import 'package:my_expenses/presentation/shared/utils/category_utils.dart';

class CategoryHeader extends StatelessWidget {
  final String name;
  final TransactionType type;
  final IconData iconData;
  final Color iconColor;

  const CategoryHeader({
    super.key,
    required this.name,
    required this.type,
    required this.iconData,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final i18n = S.of(context);
    return SizedBox(
      height: 220.0,
      child: Stack(
        children: <Widget>[
          Container(
            height: 150,
            color: theme.colorScheme.primary,
          ),
          Container(
            padding: const EdgeInsets.only(
              top: 40.0,
              left: 10.0,
              right: 10.0,
              bottom: 10.0,
            ),
            child: Material(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 5.0,
              child: Container(
                margin: Styles.edgeInsetHorizontal16,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 50.0),
                    Padding(
                      padding: Styles.edgeInsetHorizontal16,
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Expanded(
                          child: ListTile(
                            title: Text(
                              type == TransactionType.incomes ? i18n.income : i18n.expense,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              i18n.category.toUpperCase(),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
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
                              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              i18n.parent.toUpperCase(),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            alignment: Alignment.topCenter,
            child: Material(
              elevation: 10,
              color: theme.cardColor.withOpacity(0.8),
              type: MaterialType.circle,
              child: IconButton(
                iconSize: 80,
                icon: FaIcon(iconData),
                color: iconColor,
                onPressed: () => _gotoIconsPage(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _gotoIconsPage(BuildContext context) async {
    final route = MaterialPageRoute<CategoryIcon>(
      builder: (ctx) => CategoryIconsPage(),
    );

    final currentIcon = CategoryUtils.getByIconData(iconData);
    context.read<CategoryIconBloc>().add(CategoryIconEvent.selectionChanged(selectedIcon: currentIcon));

    await Navigator.of(context).push(route).then((selectedIcon) {
      if (selectedIcon == null) {
        return;
      }

      _iconChanged(context, selectedIcon.icon.icon!);
    });
  }

  void _iconChanged(BuildContext context, IconData icon) => context.read<CategoryFormBloc>().add(CategoryFormEvent.iconChanged(selectedIcon: icon));
}
