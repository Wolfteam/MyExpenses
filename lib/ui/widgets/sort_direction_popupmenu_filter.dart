import 'package:flutter/material.dart';
import 'package:my_expenses/generated/l10n.dart';

import '../../common/enums/sort_direction_type.dart';
import '../../common/extensions/i18n_extensions.dart';

class SortDirectionPopupMenuFilter extends StatelessWidget {
  final SortDirectionType selectedSortDirection;
  final Function(SortDirectionType) onSelected;

  const SortDirectionPopupMenuFilter({
    Key? key,
    required this.selectedSortDirection,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    final values = SortDirectionType.values.map((direction) {
      return CheckedPopupMenuItem<SortDirectionType>(
        checked: selectedSortDirection == direction,
        value: direction,
        child: Text(i18n.getSortDirectionName(direction)),
      );
    }).toList();
    return PopupMenuButton<SortDirectionType>(
      padding: EdgeInsets.zero,
      initialValue: selectedSortDirection,
      icon: const Icon(Icons.sort),
      onSelected: onSelected,
      itemBuilder: (context) => values,
      tooltip: i18n.sortDirection,
    );
  }
}
