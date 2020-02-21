// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:my_expenses/services/settings_service.dart';
import 'package:get_it/get_it.dart';

void $initGetIt(GetIt g, {String environment}) {
  _registerEagerSingletons(g, environment);
}

// Eager singletons must be registered in the right order
void _registerEagerSingletons(GetIt g, String environment) {
  g.registerSingleton<SettingsService>(SettingsServiceImpl());
}
