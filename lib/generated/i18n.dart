import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: camel_case_types
// ignore_for_file: prefer_single_quotes
// ignore_for_file: unnecessary_brace_in_string_interps

//WARNING: This file is automatically generated. DO NOT EDIT, all your changes would be lost.

typedef LocaleChangeCallback = void Function(Locale locale);

class I18n implements WidgetsLocalizations {
  const I18n();
  static Locale _locale;
  static bool _shouldReload = false;

  static set locale(Locale newLocale) {
    _shouldReload = true;
    I18n._locale = newLocale;
  }

  static const GeneratedLocalizationsDelegate delegate = GeneratedLocalizationsDelegate();

  /// function to be invoked when changing the language
  static LocaleChangeCallback onLocaleChanged;

  static I18n of(BuildContext context) =>
    Localizations.of<I18n>(context, WidgetsLocalizations);

  @override
  TextDirection get textDirection => TextDirection.ltr;

  /// "My Expenses"
  String get appName => "My Expenses";
  /// "Dark"
  String get dark => "Dark";
  /// "Light"
  String get light => "Light";
  /// "English"
  String get english => "English";
  /// "Spanish"
  String get spanish => "Spanish";
  /// "Incomes"
  String get incomes => "Incomes";
  /// "Expenses"
  String get expenses => "Expenses";
  /// "None"
  String get none => "None";
  /// "Each day"
  String get eachDay => "Each day";
  /// "Transactions"
  String get transactions => "Transactions";
  /// "Reports"
  String get reports => "Reports";
  /// "Charts"
  String get charts => "Charts";
  /// "Categories"
  String get categories => "Categories";
  /// "Settings"
  String get config => "Settings";
  /// "Logout"
  String get logout => "Logout";
  /// "Last 7 days"
  String get last7Days => "Last 7 days";
  /// "Total"
  String get total => "Total";
  /// "Add transaction"
  String get addTransaction => "Add transaction";
  /// "Edit transaction"
  String get editTransaction => "Edit transaction";
  /// "Saved"
  String get saved => "Saved";
  /// "Deleted"
  String get deleted => "Deleted";
  /// "Amount"
  String get amount => "Amount";
  /// "Category"
  String get category => "Category";
  /// "Date"
  String get date => "Date";
  /// "Income"
  String get income => "Income";
  /// "Expense"
  String get expense => "Expense";
  /// "Repetitions"
  String get repetitions => "Repetitions";
  /// "Add a picture"
  String get addPicture => "Add a picture";
  /// "From Galery"
  String get fromGallery => "From Galery";
  /// "From Camera"
  String get fromCamera => "From Camera";
  /// "Invalid"
  String get invalid => "Invalid";
  /// "Invalid Amount"
  String get invalidAmount => "Invalid Amount";
  /// "Invalid Description"
  String get invalidDescription => "Invalid Description";
  /// "Invalid Repetitions"
  String get invalidRepetitions => "Invalid Repetitions";
  /// "Description"
  String get description => "Description";
  /// "A description of this transaction"
  String get descriptionOfThisTransaction => "A description of this transaction";
  /// "Transaction was successfully saved"
  String get transactionsWasSuccessfullySaved => "Transaction was successfully saved";
  /// "Transaction was successfully deleted"
  String get transactionsWasSuccessfullyDeleted => "Transaction was successfully deleted";
  /// "Delete"
  String get delete => "Delete";
  /// "Delete ${name} ?"
  String deleteX(String name) => "Delete ${name} ?";
  /// "Are you sure you wanna delete this transaction ?"
  String get confirmDeleteTransaction => "Are you sure you wanna delete this transaction ?";
  /// "Ok"
  String get ok => "Ok";
  /// "Yes"
  String get yes => "Yes";
  /// "Close"
  String get close => "Close";
  /// "Cancel"
  String get cancel => "Cancel";
  /// "Generate"
  String get generate => "Generate";
  /// "Name"
  String get name => "Name";
  /// "Category name"
  String get categoryName => "Category name";
  /// "N/A"
  String get na => "N/A";
  /// "Parent"
  String get parent => "Parent";
  /// "Pick a color"
  String get pickColor => "Pick a color";
  /// "Add a category"
  String get addCategory => "Add a category";
  /// "Edit category"
  String get editCategory => "Edit category";
  /// "Select a category"
  String get selectCategory => "Select a category";
  /// "You must select a category"
  String get mustSelectCategory => "You must select a category";
  /// "Pick an icon"
  String get pickIcon => "Pick an icon";
  /// "Details"
  String get details => "Details";
  /// "Version: ${version}"
  String appVersion(String version) => "Version: ${version}";
  /// "Export from"
  String get exportFrom => "Export from";
  /// "Start date"
  String get startDate => "Start date";
  /// "End date"
  String get endDate => "End date";
  /// "Report format"
  String get reportFormat => "Report format";
  /// "Please select a format"
  String get selectFormat => "Please select a format";
  /// "Invalid name"
  String get invalidName => "Invalid name";
  /// "An unknown error occurred"
  String get unknownErrorOcurred => "An unknown error occurred";
  /// "Category was successfully saved"
  String get categoryWasSuccessfullySaved => "Category was successfully saved";
  /// "Category was successfully deleted"
  String get categoryWasSuccessfullyDeleted => "Category was successfully deleted";
  /// "Are you sure you wanna delete this category ?"
  String get confirmDeleteCategory => "Are you sure you wanna delete this category ?";
  /// "No transactions were found for ths period"
  String get noTransactionsForThisPeriod => "No transactions were found for ths period";
  /// "Ascending"
  String get ascending => "Ascending";
  /// "Descending"
  String get descending => "Descending";
  /// "Percentage"
  String get percentage => "Percentage";
  /// "Pdf"
  String get pdf => "Pdf";
  /// "Csv"
  String get csv => "Csv";
  /// "Report: ${filename} was successfully generated"
  String reportWasSuccessfullyGenerated(String filename) => "Report: ${filename} was successfully generated";
  /// "Id"
  String get id => "Id";
  /// "Type"
  String get type => "Type";
  /// "Transactions Report"
  String get transactionsReport => "Transactions Report";
  /// "Period"
  String get period => "Period";
  /// "Generated on: ${date}"
  String generatedOn(String date) => "Generated on: ${date}";
  /// "Page ${x} of ${y}"
  String pageXOfY(String x, String y) => "Page ${x} of ${y}";
  /// "Tap to open"
  String get tapToOpen => "Tap to open";
  /// "Category can not be deleted. It is being used by an existing transaction"
  String get categoryCantBeDeleted => "Category can not be deleted. It is being used by an existing transaction";
  /// "Recurring transactions"
  String get recurringTransactions => "Recurring transactions";
  /// "A child transaction can not be deleted nor edited"
  String get childTransactionCantBeDeleted => "A child transaction can not be deleted nor edited";
  /// "Recurring transaction starts on ${date} ${cycle}"
  String recurringTransactionStartsOn(String date, String cycle) => "Recurring transaction starts on ${date} ${cycle}";
  /// "No recurring transactions were founud"
  String get noRecurringTransactionsWereFound => "No recurring transactions were founud";
  /// "no"
  String get no => "no";
  /// "Remove image"
  String get removeImg => "Remove image";
  /// "Are you sure ?"
  String get areYouSure => "Are you sure ?";
  /// "Recurring"
  String get recurring => "Recurring";
  /// "Others"
  String get others => "Others";
  /// "Ask for fingerprint when the app starts"
  String get askForFingerPrint => "Ask for fingerprint when the app starts";
  /// "Authenticate"
  String get authenticate => "Authenticate";
  /// "Each week"
  String get repetitionCycleEachWeek => "Each week";
  /// "Each month"
  String get repetitionCycleEachMonth => "Each month";
  /// "Biweekly"
  String get repetitionCycleBiweekly => "Biweekly";
  /// "Each Year"
  String get repetitionCycleEachYear => "Each Year";
  /// "Each hour"
  String get syncIntervalEachHour => "Each hour";
  /// "Each 3 hours"
  String get syncIntervalEach3Hours => "Each 3 hours";
  /// "Each 6 hours"
  String get syncIntervalEach6Hours => "Each 6 hours";
  /// "Each 12 hours"
  String get syncIntervalEach12Hours => "Each 12 hours";
  /// "Education"
  String get categoryIconTypeEducation => "Education";
  /// "Electronics"
  String get categoryIconTypeElectronics => "Electronics";
  /// "Family"
  String get categoryIconTypeFamily => "Family";
  /// "Food"
  String get categoryIconTypeFood => "Food";
  /// "Furniture"
  String get categoryIconTypeFurniture => "Furniture";
  /// "Life"
  String get categoryIconTypeLife => "Life";
  /// "Personal"
  String get categoryIconTypePersonal => "Personal";
  /// "Shopping"
  String get categoryIconTypeShopping => "Shopping";
  /// "Transportation"
  String get categoryIconTypeTransportation => "Transportation";
  /// "Theme"
  String get settingsTheme => "Theme";
  /// "Select an app theme"
  String get settingsSelectAppTheme => "Select an app theme";
  /// "Choose a base app color"
  String get settingsChooseAppTheme => "Choose a base app color";
  /// "Use dark amoled theme"
  String get settingsUseDarkAmoled => "Use dark amoled theme";
  /// "Accent Color"
  String get settingsAccentColor => "Accent Color";
  /// "Choose an accent color"
  String get settingsChooseAccentColor => "Choose an accent color";
  /// "Language"
  String get settingsLanguage => "Language";
  /// "Choose a language"
  String get settingsChooseLanguage => "Choose a language";
  /// "Select a language"
  String get settingsSelectLanguage => "Select a language";
  /// "Sync"
  String get settingsSync => "Sync";
  /// "Select an interval"
  String get settingsSelectSyncInterval => "Select an interval";
  /// "Choose a sync interval"
  String get settingsChooseSyncInterval => "Choose a sync interval";
  /// "About"
  String get settingsAbout => "About";
  /// "An app that helps you to keep track of your expenses."
  String get settingsAboutSummary => "An app that helps you to keep track of your expenses.";
  /// "Donations"
  String get settingsDonations => "Donations";
  /// "Support"
  String get settingsSupport => "Support";
  /// "I hope you are enjoying using this app, if you would like to buy me a coffee/beer, just send me an email."
  String get settingsDonationsMsg => "I hope you are enjoying using this app, if you would like to buy me a coffee/beer, just send me an email.";
  /// "I made this app in my free time and it is also open source. If you would like to help me, report an issue, have an idea, want a feature to be implemented, etc please open an issue here:"
  String get settingsDonationSupport => "I made this app in my free time and it is also open source. If you would like to help me, report an issue, have an idea, want a feature to be implemented, etc please open an issue here:";
  /// "Touch sensor"
  String get authenticationFingerprintHint => "Touch sensor";
  /// "Fingerprint not recognized. Try again."
  String get authenticationFingerprintNotRecognized => "Fingerprint not recognized. Try again.";
  /// "Fingerprint recognized."
  String get authenticationFingerprintSuccess => "Fingerprint recognized.";
  /// "Fingerprint Authentication"
  String get authenticationSignInTitle => "Fingerprint Authentication";
  /// "Fingerprint required"
  String get authenticationFingerprintRequired => "Fingerprint required";
  /// "Go to settings"
  String get authenticationGoToSettings => "Go to settings";
  /// "Fingerprint is not set up on your device. Go to Settings > Security to add your fingerprint."
  String get authenticationGoToSettingDescription => "Fingerprint is not set up on your device. Go to Settings > Security to add your fingerprint.";
}

class _I18n_en_US extends I18n {
  const _I18n_en_US();

  @override
  TextDirection get textDirection => TextDirection.ltr;
}

class _I18n_es_VE extends I18n {
  const _I18n_es_VE();

  /// "Mis Gastos"
  @override
  String get appName => "Mis Gastos";
  /// "Oscuro"
  @override
  String get dark => "Oscuro";
  /// "Ligero"
  @override
  String get light => "Ligero";
  /// "Inglés"
  @override
  String get english => "Inglés";
  /// "Español"
  @override
  String get spanish => "Español";
  /// "Ingresos"
  @override
  String get incomes => "Ingresos";
  /// "Gastos"
  @override
  String get expenses => "Gastos";
  /// "Ninguno"
  @override
  String get none => "Ninguno";
  /// "Cada día"
  @override
  String get eachDay => "Cada día";
  /// "Transacciones"
  @override
  String get transactions => "Transacciones";
  /// "Reportes"
  @override
  String get reports => "Reportes";
  /// "Gráficos"
  @override
  String get charts => "Gráficos";
  /// "Categorías"
  @override
  String get categories => "Categorías";
  /// "Ajustes"
  @override
  String get config => "Ajustes";
  /// "Logout"
  @override
  String get logout => "Logout";
  /// "Últimos 7 días"
  @override
  String get last7Days => "Últimos 7 días";
  /// "Total"
  @override
  String get total => "Total";
  /// "Agregar transacción"
  @override
  String get addTransaction => "Agregar transacción";
  /// "Editar transacción"
  @override
  String get editTransaction => "Editar transacción";
  /// "Guardado"
  @override
  String get saved => "Guardado";
  /// "Borrado"
  @override
  String get deleted => "Borrado";
  /// "Monto"
  @override
  String get amount => "Monto";
  /// "Categoría"
  @override
  String get category => "Categoría";
  /// "Fecha"
  @override
  String get date => "Fecha";
  /// "Ingreso"
  @override
  String get income => "Ingreso";
  /// "Gasto"
  @override
  String get expense => "Gasto";
  /// "Repeticiones"
  @override
  String get repetitions => "Repeticiones";
  /// "Agregar una imagen"
  @override
  String get addPicture => "Agregar una imagen";
  /// "Desde la galería"
  @override
  String get fromGallery => "Desde la galería";
  /// "Desde la cámara"
  @override
  String get fromCamera => "Desde la cámara";
  /// "Inválido"
  @override
  String get invalid => "Inválido";
  /// "Monto inválido"
  @override
  String get invalidAmount => "Monto inválido";
  /// "Descripción inválida"
  @override
  String get invalidDescription => "Descripción inválida";
  /// "Repeticiones inválidas"
  @override
  String get invalidRepetitions => "Repeticiones inválidas";
  /// "Descripción"
  @override
  String get description => "Descripción";
  /// "Una descripción de esta transacción"
  @override
  String get descriptionOfThisTransaction => "Una descripción de esta transacción";
  /// "La transacción fue guardada exitósamente"
  @override
  String get transactionsWasSuccessfullySaved => "La transacción fue guardada exitósamente";
  /// "La transacción fue borrada exitósamente"
  @override
  String get transactionsWasSuccessfullyDeleted => "La transacción fue borrada exitósamente";
  /// "Borrar"
  @override
  String get delete => "Borrar";
  /// "¿ Borrar ${name} ?"
  @override
  String deleteX(String name) => "¿ Borrar ${name} ?";
  /// " ¿Estás seguro que deseas borrar esta transacción?"
  @override
  String get confirmDeleteTransaction => " ¿Estás seguro que deseas borrar esta transacción?";
  /// "Ok"
  @override
  String get ok => "Ok";
  /// "Si"
  @override
  String get yes => "Si";
  /// "Cerrar"
  @override
  String get close => "Cerrar";
  /// "Cancelar"
  @override
  String get cancel => "Cancelar";
  /// "Generar"
  @override
  String get generate => "Generar";
  /// "Nombre"
  @override
  String get name => "Nombre";
  /// "Nombre de la categoría"
  @override
  String get categoryName => "Nombre de la categoría";
  /// "N/A"
  @override
  String get na => "N/A";
  /// "Padre"
  @override
  String get parent => "Padre";
  /// "Selecciona un color"
  @override
  String get pickColor => "Selecciona un color";
  /// "Agregar una categoría"
  @override
  String get addCategory => "Agregar una categoría";
  /// "Editar categoría"
  @override
  String get editCategory => "Editar categoría";
  /// "Seleccione una categoría"
  @override
  String get selectCategory => "Seleccione una categoría";
  /// "Debes seleccionar una categoría"
  @override
  String get mustSelectCategory => "Debes seleccionar una categoría";
  /// "Selecciona un ícono"
  @override
  String get pickIcon => "Selecciona un ícono";
  /// "Detalles"
  @override
  String get details => "Detalles";
  /// "Version: ${version}"
  @override
  String appVersion(String version) => "Version: ${version}";
  /// "Exportar desde"
  @override
  String get exportFrom => "Exportar desde";
  /// "Fecha inicio"
  @override
  String get startDate => "Fecha inicio";
  /// "Fecha fin"
  @override
  String get endDate => "Fecha fin";
  /// "Formato del reporte"
  @override
  String get reportFormat => "Formato del reporte";
  /// "Por favor seleccione un formato"
  @override
  String get selectFormat => "Por favor seleccione un formato";
  /// "Nombre inválido"
  @override
  String get invalidName => "Nombre inválido";
  /// "Un error inesperado ha ocurrido"
  @override
  String get unknownErrorOcurred => "Un error inesperado ha ocurrido";
  /// "La categoría fue guardada exitósamente"
  @override
  String get categoryWasSuccessfullySaved => "La categoría fue guardada exitósamente";
  /// "La categoría fue borrada exitósamente"
  @override
  String get categoryWasSuccessfullyDeleted => "La categoría fue borrada exitósamente";
  /// "¿Estás seguro que deseas borrar esta categoría?"
  @override
  String get confirmDeleteCategory => "¿Estás seguro que deseas borrar esta categoría?";
  /// "No se encontraron transacciones para este período"
  @override
  String get noTransactionsForThisPeriod => "No se encontraron transacciones para este período";
  /// "Ascending"
  @override
  String get ascending => "Ascending";
  /// "Descending"
  @override
  String get descending => "Descending";
  /// "Percentage"
  @override
  String get percentage => "Percentage";
  /// "Pdf"
  @override
  String get pdf => "Pdf";
  /// "Csv"
  @override
  String get csv => "Csv";
  /// "El reporte: ${filename} fue generado exitósamente"
  @override
  String reportWasSuccessfullyGenerated(String filename) => "El reporte: ${filename} fue generado exitósamente";
  /// "Id"
  @override
  String get id => "Id";
  /// "Tipo"
  @override
  String get type => "Tipo";
  /// "Reporte de Transacciones"
  @override
  String get transactionsReport => "Reporte de Transacciones";
  /// "Período"
  @override
  String get period => "Período";
  /// "Generado el: ${date}"
  @override
  String generatedOn(String date) => "Generado el: ${date}";
  /// "Página ${x} de ${y}"
  @override
  String pageXOfY(String x, String y) => "Página ${x} de ${y}";
  /// "Toca para abrir"
  @override
  String get tapToOpen => "Toca para abrir";
  /// "La categoría no puede ser borrada. Está siendo usada por una transaccion existente"
  @override
  String get categoryCantBeDeleted => "La categoría no puede ser borrada. Está siendo usada por una transaccion existente";
  /// "Transacciones recurrentes"
  @override
  String get recurringTransactions => "Transacciones recurrentes";
  /// "Una transacción hija no puede ser modificada ni borrada"
  @override
  String get childTransactionCantBeDeleted => "Una transacción hija no puede ser modificada ni borrada";
  /// "La transacción recurrente empezará el ${date} ${cycle}"
  @override
  String recurringTransactionStartsOn(String date, String cycle) => "La transacción recurrente empezará el ${date} ${cycle}";
  /// "No se encontraron transacciones recurrentes"
  @override
  String get noRecurringTransactionsWereFound => "No se encontraron transacciones recurrentes";
  /// "no"
  @override
  String get no => "no";
  /// "Remover imagen"
  @override
  String get removeImg => "Remover imagen";
  /// "¿ Estás seguro ?"
  @override
  String get areYouSure => "¿ Estás seguro ?";
  /// "Recurrente"
  @override
  String get recurring => "Recurrente";
  /// "Otros"
  @override
  String get others => "Otros";
  /// "Solicitar huella al iniciar la aplicación"
  @override
  String get askForFingerPrint => "Solicitar huella al iniciar la aplicación";
  /// "Autenticate"
  @override
  String get authenticate => "Autenticate";
  /// "Cada semana"
  @override
  String get repetitionCycleEachWeek => "Cada semana";
  /// "Cada mes"
  @override
  String get repetitionCycleEachMonth => "Cada mes";
  /// "Quincenal"
  @override
  String get repetitionCycleBiweekly => "Quincenal";
  /// "Cada año"
  @override
  String get repetitionCycleEachYear => "Cada año";
  /// "Cada hora"
  @override
  String get syncIntervalEachHour => "Cada hora";
  /// "Cada 3 horas"
  @override
  String get syncIntervalEach3Hours => "Cada 3 horas";
  /// "Cada 6 horas"
  @override
  String get syncIntervalEach6Hours => "Cada 6 horas";
  /// "Cada 12 horas"
  @override
  String get syncIntervalEach12Hours => "Cada 12 horas";
  /// "Educación"
  @override
  String get categoryIconTypeEducation => "Educación";
  /// "Electrónicos"
  @override
  String get categoryIconTypeElectronics => "Electrónicos";
  /// "Familia"
  @override
  String get categoryIconTypeFamily => "Familia";
  /// "Comida"
  @override
  String get categoryIconTypeFood => "Comida";
  /// "Mobiliario"
  @override
  String get categoryIconTypeFurniture => "Mobiliario";
  /// "Vida"
  @override
  String get categoryIconTypeLife => "Vida";
  /// "Personal"
  @override
  String get categoryIconTypePersonal => "Personal";
  /// "Compras"
  @override
  String get categoryIconTypeShopping => "Compras";
  /// "Trasnporte"
  @override
  String get categoryIconTypeTransportation => "Trasnporte";
  /// "Tema"
  @override
  String get settingsTheme => "Tema";
  /// "Selecciona un tema"
  @override
  String get settingsSelectAppTheme => "Selecciona un tema";
  /// "Escoge un color base para la app"
  @override
  String get settingsChooseAppTheme => "Escoge un color base para la app";
  /// "Usar el tema oscuro para pantallas Amoled"
  @override
  String get settingsUseDarkAmoled => "Usar el tema oscuro para pantallas Amoled";
  /// "Color de acento"
  @override
  String get settingsAccentColor => "Color de acento";
  /// "Escoge un color de acento"
  @override
  String get settingsChooseAccentColor => "Escoge un color de acento";
  /// "Lenguaje"
  @override
  String get settingsLanguage => "Lenguaje";
  /// "Escoge un lenguaje"
  @override
  String get settingsChooseLanguage => "Escoge un lenguaje";
  /// "Selecciona un lenguaje"
  @override
  String get settingsSelectLanguage => "Selecciona un lenguaje";
  /// "Sincronización"
  @override
  String get settingsSync => "Sincronización";
  /// "Selecciona un intervalo"
  @override
  String get settingsSelectSyncInterval => "Selecciona un intervalo";
  /// "Escoge un intervalo de sincronización"
  @override
  String get settingsChooseSyncInterval => "Escoge un intervalo de sincronización";
  /// "Acerca de"
  @override
  String get settingsAbout => "Acerca de";
  /// "Una aplicación que te ayuda a mantener un registro de tus gastos."
  @override
  String get settingsAboutSummary => "Una aplicación que te ayuda a mantener un registro de tus gastos.";
  /// "Donaciones"
  @override
  String get settingsDonations => "Donaciones";
  /// "Soporte"
  @override
  String get settingsSupport => "Soporte";
  /// "Espero que disfrutes al usar esta aplicación, si te gustaría comprarme un cafe o una cerveza, envíame un email."
  @override
  String get settingsDonationsMsg => "Espero que disfrutes al usar esta aplicación, si te gustaría comprarme un cafe o una cerveza, envíame un email.";
  /// "Hice esta aplicación en mi tiempo libre y también es de código abierto. Si desea ayudarme, informar un problema, tienes una idea, deseas que se implemente una función, etc., crea un issue aquí:"
  @override
  String get settingsDonationSupport => "Hice esta aplicación en mi tiempo libre y también es de código abierto. Si desea ayudarme, informar un problema, tienes una idea, deseas que se implemente una función, etc., crea un issue aquí:";
  /// "Toca el sensor"
  @override
  String get authenticationFingerprintHint => "Toca el sensor";
  /// "Huela no reconocida. Intenta de nuevo."
  @override
  String get authenticationFingerprintNotRecognized => "Huela no reconocida. Intenta de nuevo.";
  /// "Huella reconozida."
  @override
  String get authenticationFingerprintSuccess => "Huella reconozida.";
  /// "Autenticación con huella"
  @override
  String get authenticationSignInTitle => "Autenticación con huella";
  /// "Huella requireda"
  @override
  String get authenticationFingerprintRequired => "Huella requireda";
  /// "Ir a la configuración"
  @override
  String get authenticationGoToSettings => "Ir a la configuración";
  /// "La huella no esta configurada en tu equipo. Ve a la Configuración > Seguridad para añadir tu huella."
  @override
  String get authenticationGoToSettingDescription => "La huella no esta configurada en tu equipo. Ve a la Configuración > Seguridad para añadir tu huella.";

  @override
  TextDirection get textDirection => TextDirection.ltr;
}

class GeneratedLocalizationsDelegate extends LocalizationsDelegate<WidgetsLocalizations> {
  const GeneratedLocalizationsDelegate();
  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale("en", "US"),
      Locale("es", "VE")
    ];
  }

  LocaleResolutionCallback resolution({Locale fallback}) {
    return (Locale locale, Iterable<Locale> supported) {
      if (isSupported(locale)) {
        return locale;
      }
      final Locale fallbackLocale = fallback ?? supported.first;
      return fallbackLocale;
    };
  }

  @override
  Future<WidgetsLocalizations> load(Locale locale) {
    I18n._locale ??= locale;
    I18n._shouldReload = false;
    final String lang = I18n._locale != null ? I18n._locale.toString() : "";
    final String languageCode = I18n._locale != null ? I18n._locale.languageCode : "";
    if ("en_US" == lang) {
      return SynchronousFuture<WidgetsLocalizations>(const _I18n_en_US());
    }
    else if ("es_VE" == lang) {
      return SynchronousFuture<WidgetsLocalizations>(const _I18n_es_VE());
    }
    else if ("en" == languageCode) {
      return SynchronousFuture<WidgetsLocalizations>(const _I18n_en_US());
    }
    else if ("es" == languageCode) {
      return SynchronousFuture<WidgetsLocalizations>(const _I18n_es_VE());
    }

    return SynchronousFuture<WidgetsLocalizations>(const I18n());
  }

  @override
  bool isSupported(Locale locale) {
    for (var i = 0; i < supportedLocales.length && locale != null; i++) {
      final l = supportedLocales[i];
      if (l.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }

  @override
  bool shouldReload(GeneratedLocalizationsDelegate old) => I18n._shouldReload;
}