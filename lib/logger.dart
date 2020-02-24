import 'package:flutter/material.dart';
import 'package:log_4_dart_2/log_4_dart_2.dart';
import 'package:path_provider/path_provider.dart';

Future setupLogging() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationSupportDirectory();
  final config = {
    'appenders': [
      {
        'type': 'CONSOLE',
        'dateFormat': 'yyyy-MM-dd HH:mm:ss',
        'format': '%d %i %t %l %m',
        'level': 'INFO'
      },
      {
        'type': 'FILE',
        'dateFormat': 'dd-MM-yyyy HH:mm:ss',
        'format': '%d [%l] - [%t]: %m',
        'level': 'ALL',
        'filePattern': 'my_expenses_log',
        'fileExtension': 'txt',
        'path': '${dir.path}/',
        'rotationCycle': 'DAY'
      },
    ]
  };
  Logger().init(config);
}

