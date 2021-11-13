abstract class PathService {
  Future<String> get reportsPath;

  String get transactionImgPrefix;

  String get userProfileImgPrefix;

  Future<String> generateTransactionImgPath(int? userId);

  Future<String> generateReportFilePath({bool isPdf = true});

  Future<String> getUserImgPath(int? userId);

  Future<String> getUserProfileImgPath();

  Future<String> buildUserImgPath(String filename, int? userId);

  Future<void> moveFile(String currentPath, String finalPath);
}
