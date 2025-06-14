import 'package:flutter/material.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/generated/l10n.dart';

Future<S> getI18n(AppLanguageType language) {
  final locale = currentLocale(language);
  return S.delegate.load(locale);
}

Locale currentLocale(AppLanguageType language) => S.delegate.supportedLocales[language.index];

String currentLocaleString(AppLanguageType language) => S.delegate.supportedLocales[language.index].languageCode;
