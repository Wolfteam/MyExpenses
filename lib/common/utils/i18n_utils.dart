import 'package:flutter/material.dart';

import '../../generated/i18n.dart';
import '../enums/app_language_type.dart';

Locale currentLocale(AppLanguageType language) =>
    I18n.delegate.supportedLocales[language.index];

String currentLocaleString(AppLanguageType language) =>
    I18n.delegate.supportedLocales[language.index].languageCode;

