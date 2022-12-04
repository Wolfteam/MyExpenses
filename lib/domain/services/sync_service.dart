abstract class SyncService {
  Future<void> initializeAppFolderAndFiles();

  Future<void> downloadAndUpdateFile();

  Future<bool> downloadRemoteImg(int userId, String img);
}
