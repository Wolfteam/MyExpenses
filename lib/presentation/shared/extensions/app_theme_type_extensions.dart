import 'package:flutter/material.dart';
import 'package:my_expenses/domain/enums/enums.dart';

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
      case AppAccentColorType.indigo:
        return Colors.indigo;
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
      case AppAccentColorType.teal:
        return Colors.teal;
      case AppAccentColorType.amber:
        return Colors.amber;
      default:
        throw Exception('The provided accent color = $this is not valid ');
    }
  }

  ThemeData getThemeData(AppThemeType theme) {
    final color = getAccentColor();
    final brightness = switch (theme) {
      AppThemeType.dark => Brightness.dark,
      AppThemeType.light => Brightness.light,
    };

    final ColorScheme colorScheme = ColorScheme.fromSeed(seedColor: color, brightness: brightness);
    return switch (brightness) {
      Brightness.dark => ThemeData.dark(useMaterial3: true).copyWith(colorScheme: colorScheme),
      Brightness.light => ThemeData.light(useMaterial3: true).copyWith(colorScheme: colorScheme),
    };
  }
}
