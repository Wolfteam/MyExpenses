import 'dart:io';

import 'package:my_expenses/domain/extensions/string_extensions.dart';
import 'package:my_expenses/domain/services/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class PathServiceImpl implements PathService {
  //internal memory/android/data/com.miraisoft.my_expenses/files/reports
  @override
  Future<String> get reportsPath async {
    final dir = Platform.isIOS ? await getApplicationDocumentsDirectory() : await getExternalStorageDirectory();
    final dirPath = '${dir!.path}/Reports';
    await _generateDirectoryIfItDoesntExist(dirPath);
    return dirPath;
  }

  @override
  String get transactionImgPrefix => 'user_picked_img_';

  @override
  String get userProfileImgPrefix => 'user_profile_img_';

  @override
  Future<String> generateTransactionImgPath(int? userId) async {
    final imgPath = await getUserImgPath(userId);
    final now = DateTime.now();
    final filename = '$transactionImgPrefix$now.png';
    return join(imgPath, filename);
  }

  @override
  Future<String> generateReportFilePath({bool isPdf = true}) async {
    final now = DateTime.now();
    final path = await reportsPath;
    final filename = isPdf ? '$now.pdf' : '$now.csv';
    return join(path, filename);
  }

  //root/data/data/com.miraisoft.my_expenses/app_flutter/images
  @override
  Future<String> getUserImgPath(int? userId) async {
    final dir = await getApplicationSupportDirectory();
    final dirPath = userId == null ? '${dir.path}/Images' : '${dir.path}/Images_$userId';
    await _generateDirectoryIfItDoesntExist(dirPath);
    return dirPath;
  }

  @override
  Future<String> getUserProfileImgPath() async {
    final imgPath = await getUserImgPath(null);
    final now = DateTime.now();
    final filename = '$userProfileImgPrefix$now.png';
    return join(imgPath, filename);
  }

  @override
  Future<String> buildUserImgPath(String filename, int? userId) async {
    final baseImgPath = await getUserImgPath(userId);
    return join(baseImgPath, filename);
  }

  @override
  Future<String> buildUserProfileImgPath(String filename) async {
    final baseImgPath = await getUserImgPath(null);
    return join(baseImgPath, filename);
  }

  @override
  Future<void> moveFile(String currentPath, String finalPath) async {
    await File(finalPath).writeAsBytes(await File(currentPath).readAsBytes());
  }

  @override
  Future<String?> getDynamicUserImg(String? currentFullPath) async {
    String? imgPath;
    if (currentFullPath.isNullEmptyOrWhitespace) {
      return null;
    }
    final filename = basename(currentFullPath!);
    imgPath = await buildUserProfileImgPath(filename);
    final file = File(imgPath);
    if (!await file.exists()) {
      imgPath = null;
    }
    return imgPath;
  }

  Future<void> _generateDirectoryIfItDoesntExist(String path) async {
    final dirExists = await Directory(path).exists();
    if (!dirExists) {
      await Directory(path).create(recursive: true);
    }
  }
}
