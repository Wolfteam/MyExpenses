import '../../generated/i18n.dart';
import '../enums/app_language_type.dart';

String currentLocale(AppLanguageType language) =>
    I18n.delegate.supportedLocales[language.index].languageCode;
