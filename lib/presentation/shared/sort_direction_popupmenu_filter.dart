import 'package:flutter/material.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/presentation/shared/extensions/i18n_extensions.dart';
import 'package:my_expenses/presentation/shared/styles.dart';

class SortDirectionPopupMenuFilter extends StatelessWidget {
  final SortDirectionType selectedSortDirection;
  final Function(SortDirectionType) onSelected;

  const SortDirectionPopupMenuFilter({
    super.key,
    required this.selectedSortDirection,
    required this.onSelected,
  });

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
    return ClipRRect(
      borderRadius: Styles.popupMenuButtonRadius,
      child: Material(
        color: Colors.transparent,
        child: PopupMenuButton<SortDirectionType>(
          padding: EdgeInsets.zero,
          initialValue: selectedSortDirection,
          icon: const Icon(Icons.sort),
          onSelected: onSelected,
          // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          itemBuilder: (context) => values,
          tooltip: i18n.sortDirection,
        ),
      ),
    );
  }
}
