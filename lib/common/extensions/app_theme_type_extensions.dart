import 'package:flutter/material.dart';

import '../enums/app_accent_color_type.dart';

extension AppThemeTypeExtensions on AppAccentColorType {
  Color getAccentColor() {
    switch (this) {
      case AppAccentColorType.blue:
        return Colors.blue;
      case AppAccentColorType.green:
        return Colors.green;
      case AppAccentColorType.pink:
        return Colors.pink;
      case AppAccentColorType.brown:
        return Colors.brown;
      case AppAccentColorType.red:
        return Colors.red;
      case AppAccentColorType.cyan:
        return Colors.cyan;
      case AppAccentColorType.greenAccent:
        return Colors.greenAccent;
      case AppAccentColorType.purple:
        return Colors.purple;
      case AppAccentColorType.deepPurple:
        return Colors.deepPurple;
      case AppAccentColorType.grey:
        return Colors.grey;
      case AppAccentColorType.orange:
        return Colors.orange;
      case AppAccentColorType.yellow:
        return Colors.yellow;
      case AppAccentColorType.blueGrey:
        return Colors.blueGrey;
      case AppAccentColorType.deepPurpleAccent:
        return Colors.deepPurpleAccent;
      case AppAccentColorType.amberAccent:
        return Colors.amberAccent;
      default:
        throw Exception('The provided accent color = $this is not valid ');
    }
  }
}
