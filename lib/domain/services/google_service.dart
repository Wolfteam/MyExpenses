import 'package:my_expenses/domain/models/models.dart';

abstract class GoogleService {
  Future<bool> signIn();

  Future<bool?> signInSilently();

  Future<bool> signOut();

  Future<UserItem> getUserInfo();

  Future<bool> appFolderExist();

  Future<String> uploadFile(String filePath);

  Future<String> downloadFile(String fileName, String filePath);

  Future<String> updateFile(String fileId, String filePath);

  Future<Map<String, String>> getAllImages(String imgPrefix);
}
