import 'dart:io';
import 'package:path/path.dart';

import 'package:path_provider/path_provider.dart';

class AppPathUtils {
  //internal memory/android/data/com.miraisoft.my_expenses/files/reports
  static Future<String> get reportsPath async {
    final dir = await getExternalStorageDirectory();
    final dirPath = '${dir.path}/Reports';
    await _generateDirectoryIfItDoesntExist(dirPath);
    return dirPath;
  }

  //internal memory/android/data/com.miraisoft.my_expenses/files/logs
  static Future<String> get logsPath async {
    final dir = await getExternalStorageDirectory();
    final dirPath = '${dir.path}/Logs';
    await _generateDirectoryIfItDoesntExist(dirPath);
    return dirPath;
  }

  static String get transactionImgPrefix => 'user_picked_img_';

  static String get userProfileImgPrefix => 'user_profile_img_';

  static Future<String> generateTransactionImgPath(int userId) async {
    final imgPath = await getUserImgPath(userId);
    final now = DateTime.now();
    final filename = '$transactionImgPrefix$now.png';
    return join(imgPath, filename);
  }

  static Future<String> generateReportFilePath({bool isPdf = true}) async {
    final now = DateTime.now();
    final path = await reportsPath;
    final filename = '${isPdf ? '$now.pdf' : '$now.csv'}';
    return join(path, filename);
  }

  //root/data/data/com.miraisoft.my_expenses/app_flutter/images
  static Future<String> getUserImgPath(int userId) async {
    final dir = await getApplicationDocumentsDirectory();
    final dirPath = userId == null ? '${dir.path}/Images' : '${dir.path}/Images_$userId';
    await _generateDirectoryIfItDoesntExist(dirPath);
    return dirPath;
  }

  static Future<String> getUserProfileImgPath() async {
    final imgPath = await getUserImgPath(null);
    final now = DateTime.now();
    final filename = '$userProfileImgPrefix$now.png';
    return join(imgPath, filename);
  }

  static Future<String> buildUserImgPath(String filename, int userId) async {
    final baseImgPath = await getUserImgPath(userId);
    return join(baseImgPath, filename);
  }

  static Future<void> deleteOlLogs() async {
    final maxDate = DateTime.now().subtract(const Duration(days: 3));
    final path = await logsPath;
    final dir = Directory(path);
    final files = dir.listSync();
    final filesToDelete = <FileSystemEntity>[];
    for (final file in files) {
      final stat = await file.stat();
      if (stat.modified.isBefore(maxDate)) {
        filesToDelete.add(file);
      }
    }
    if (filesToDelete.isNotEmpty) {
      await Future.wait(filesToDelete.map((f) => f.delete()).toList());
    }
  }

  static Future<void> _generateDirectoryIfItDoesntExist(String path) async {
    final dirExists = await Directory(path).exists();
    if (!dirExists) {
      await Directory(path).create(recursive: true);
    }
  }
}
