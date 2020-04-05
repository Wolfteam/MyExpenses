import 'dart:io';

import 'package:path_provider/path_provider.dart';

class AppPathUtils {
  static Future<String> get imagesPath async {
    final dir = await getApplicationDocumentsDirectory();
    final dirPath = '${dir.path}/Images';
    await _generateDirectoryIfItDoesntExist(dirPath);
    return dirPath;
  }

  static Future<String> get reportsPath async {
    final dir = await getExternalStorageDirectory();
    final dirPath = '${dir.path}/Reports';
    await _generateDirectoryIfItDoesntExist(dirPath);
    return dirPath;
  }

  static Future<String> get logsPath async {
    final dir = await getExternalStorageDirectory();
    final dirPath = '${dir.path}/Logs';
    await _generateDirectoryIfItDoesntExist(dirPath);
    return dirPath;
  }

  static Future<void> _generateDirectoryIfItDoesntExist(String path) async {
    final dirExists = await Directory(path).exists();
    if (!dirExists) {
      await Directory(path).create(recursive: true);
    }
  }
}
