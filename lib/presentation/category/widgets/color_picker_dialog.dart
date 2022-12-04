import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:my_expenses/generated/l10n.dart';

typedef OnColorSelected = void Function(BuildContext, Color);

class ColorPickerDialog extends StatefulWidget {
  final Color iconColor;
  final OnColorSelected? onColorSelected;

  const ColorPickerDialog({
    super.key,
    required this.iconColor,
    this.onColorSelected,
  });

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late Color _currentColor;

  @override
  void initState() {
    _currentColor = widget.iconColor;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final i18n = S.of(context);
    return AlertDialog(
      title: Text(i18n.pickColor),
      content: SingleChildScrollView(
        child: ColorPicker(
          pickerColor: _currentColor,
          onColorChanged: (v) => setState(() {
            _currentColor = v;
          }),
          enableAlpha: false,
          displayThumbColor: true,
          pickerAreaBorderRadius: const BorderRadius.only(
            topLeft: Radius.circular(2.0),
            topRight: Radius.circular(2.0),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            if (widget.onColorSelected != null) {
              widget.onColorSelected?.call(context, _currentColor);
            }

            Navigator.of(context).pop(_currentColor);
          },
          child: Text(i18n.ok),
        ),
      ],
    );
  }
}
