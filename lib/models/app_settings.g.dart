// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) {
  return AppSettings(
    appTheme: _$enumDecodeNullable(_$AppThemeTypeEnumMap, json['appTheme']),
    useDarkAmoled: json['useDarkAmoled'] as bool,
    accentColor:
        _$enumDecodeNullable(_$AppAccentColorTypeEnumMap, json['accentColor']),
    appLanguage:
        _$enumDecodeNullable(_$AppLanguageTypeEnumMap, json['appLanguage']),
    syncInterval:
        _$enumDecodeNullable(_$SyncIntervalTypeEnumMap, json['syncInterval']),
    askForPassword: json['askForPassword'] as bool,
    askForFingerPrint: json['askForFingerPrint'] as bool,
  );
}

Map<String, dynamic> _$AppSettingsToJson(AppSettings instance) =>
    <String, dynamic>{
      'appTheme': _$AppThemeTypeEnumMap[instance.appTheme],
      'useDarkAmoled': instance.useDarkAmoled,
      'accentColor': _$AppAccentColorTypeEnumMap[instance.accentColor],
      'appLanguage': _$AppLanguageTypeEnumMap[instance.appLanguage],
      'syncInterval': _$SyncIntervalTypeEnumMap[instance.syncInterval],
      'askForPassword': instance.askForPassword,
      'askForFingerPrint': instance.askForFingerPrint,
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$AppThemeTypeEnumMap = {
  AppThemeType.dark: 'dark',
  AppThemeType.light: 'light',
};

const _$AppAccentColorTypeEnumMap = {
  AppAccentColorType.blue: 'blue',
  AppAccentColorType.green: 'green',
  AppAccentColorType.pink: 'pink',
  AppAccentColorType.brown: 'brown',
  AppAccentColorType.red: 'red',
  AppAccentColorType.cyan: 'cyan',
  AppAccentColorType.indigo: 'indigo',
  AppAccentColorType.purple: 'purple',
  AppAccentColorType.deepPurple: 'deepPurple',
  AppAccentColorType.grey: 'grey',
  AppAccentColorType.orange: 'orange',
  AppAccentColorType.yellow: 'yellow',
  AppAccentColorType.blueGrey: 'blueGrey',
  AppAccentColorType.teal: 'teal',
  AppAccentColorType.amber: 'amber',
};

const _$AppLanguageTypeEnumMap = {
  AppLanguageType.english: 'english',
  AppLanguageType.spanish: 'spanish',
};

const _$SyncIntervalTypeEnumMap = {
  SyncIntervalType.none: 'none',
  SyncIntervalType.eachHour: 'eachHour',
  SyncIntervalType.each3Hours: 'each3Hours',
  SyncIntervalType.each6Hours: 'each6Hours',
  SyncIntervalType.each12Hours: 'each12Hours',
  SyncIntervalType.eachDay: 'eachDay',
};
