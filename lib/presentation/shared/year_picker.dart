import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:my_expenses/generated/l10n.dart';

Future<DateTime?> showYearlyPicker({
  required BuildContext context,
  required DateTime selectedDate,
  required DateTime firstDate,
  DateTime? lastDate,
}) {
  return showDialog<DateTime>(
    context: context,
    builder: (ctx) => _YearPickerDialog(firstDate: firstDate, lastDate: lastDate ?? DateTime.now(), selectedDate: selectedDate),
  );
}

class _YearPickerDialog extends StatefulWidget {
  final DateTime selectedDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const _YearPickerDialog({Key? key, required this.selectedDate, required this.firstDate, required this.lastDate}) : super(key: key);

  @override
  _YearPickerDialogState createState() => _YearPickerDialogState();
}

class _YearPickerDialogState extends State<_YearPickerDialog> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width * 0.7;
    return AlertDialog(
      title: Text(s.pickYear),
      actions: [
        OutlinedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            s.cancel,
            style: TextStyle(color: theme.primaryColor),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, selectedDate),
          child: Text(s.ok),
        ),
      ],
      content: SizedBox(
        height: 200,
        width: width,
        child: _YearPicker(
          selectedDate: selectedDate,
          onChanged: (val) {
            setState(() {
              selectedDate = val;
            });
          },
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
        ),
      ),
    );
  }
}

// Taken from https://github.com/benznest/flutter_rounded_date_picker
class _YearPicker extends StatefulWidget {
  /// Creates a year picker.
  ///
  /// The [selectedDate] and [onChanged] arguments must not be null. The
  /// [lastDate] must be after the [firstDate].
  ///
  /// Rarely used directly. Instead, typically used as part of the dialog shown
  /// by [showDatePicker].
  _YearPicker({
    Key? key,
    required this.selectedDate,
    required this.onChanged,
    required this.firstDate,
    required this.lastDate,
    this.fontFamily,
    this.dragStartBehavior = DragStartBehavior.start,
    this.style,
  })  : assert(!firstDate.isAfter(lastDate)),
        super(key: key);

  /// The currently selected date.
  ///
  /// This date is highlighted in the picker.
  final DateTime selectedDate;

  /// Called when the user picks a year.
  final ValueChanged<DateTime> onChanged;

  /// The earliest date the user is permitted to pick.
  final DateTime firstDate;

  /// The latest date the user is permitted to pick.
  final DateTime lastDate;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;

  /// Font
  final String? fontFamily;

  /// style
  final TextStyle? style;

  @override
  _YearPickerState createState() => _YearPickerState();
}

class _YearPickerState extends State<_YearPicker> {
  late double _itemExtent;
  ScrollController? scrollController;

  @override
  void initState() {
    super.initState();
    _itemExtent = 50;
    scrollController = ScrollController(
      // Move the initial scroll position to the currently selected date's year.
      initialScrollOffset: (widget.selectedDate.year - widget.firstDate.year) * _itemExtent,
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    final ThemeData themeData = Theme.of(context);
    final TextStyle style = themeData.textTheme.bodyText2!.copyWith(fontFamily: widget.fontFamily);

    return ListView.builder(
      dragStartBehavior: widget.dragStartBehavior,
      controller: scrollController,
      itemExtent: _itemExtent,
      itemCount: widget.lastDate.year - widget.firstDate.year + 1,
      itemBuilder: (context, index) {
        final int year = widget.firstDate.year + index;
        final bool isSelected = year == widget.selectedDate.year;
        final TextStyle itemStyle = isSelected
            ? (widget.style ?? themeData.textTheme.headline5!.copyWith(color: themeData.colorScheme.secondary, fontFamily: widget.fontFamily))
            : (widget.style ?? style);
        return InkWell(
          key: ValueKey<int>(year),
          onTap: () {
            widget.onChanged(DateTime(year, widget.selectedDate.month, widget.selectedDate.day));
          },
          child: Center(
            child: Semantics(
              selected: isSelected,
              child: Text('$year', style: itemStyle),
            ),
          ),
        );
      },
    );
  }
}
