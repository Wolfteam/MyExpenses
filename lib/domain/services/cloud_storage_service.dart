abstract class CloudStorageService {
  Future<bool> isAvailable();

  Future<bool> appFolderExist();

  Future<String> uploadFile(String filePath);

  Future<String> downloadFile(String fileName, String filePath);

  Future<String> updateFile(String fileId, String filePath);

  Future<Map<String, String>> getAllImages(String imgPrefix);
}
