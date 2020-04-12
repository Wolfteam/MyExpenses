import 'package:flutter/material.dart';

import '../../generated/i18n.dart';
import '../enums/app_language_type.dart';

Future<I18n> getI18n(AppLanguageType language) async {
  final locale = currentLocale(language);
  return await I18n.delegate.load(locale) as I18n;
}

Locale currentLocale(AppLanguageType language) =>
    I18n.delegate.supportedLocales[language.index];

String currentLocaleString(AppLanguageType language) =>
    I18n.delegate.supportedLocales[language.index].languageCode;
