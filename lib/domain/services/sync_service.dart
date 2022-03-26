abstract class SyncService {
  Future<void> initializeAppFolderAndFiles();

  Future<void> downloadAndUpdateFile();
}
