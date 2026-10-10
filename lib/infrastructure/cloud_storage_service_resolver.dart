import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/services/services.dart';

class CloudStorageServiceResolver implements CloudStorageService {
  final GoogleService _googleService;
  final CloudStorageService _iCloudService;
  final SettingsService _settingsService;

  CloudStorageServiceResolver(
    this._googleService,
    this._iCloudService,
    this._settingsService,
  );

  CloudStorageService get _activeService {
    return switch (_settingsService.syncProvider) {
      SyncProviderType.googleDrive => _googleService,
      SyncProviderType.iCloud => _iCloudService,
      SyncProviderType.none => _googleService,
    };
  }

  @override
  Future<bool> isAvailable() => _activeService.isAvailable();

  @override
  Future<bool> appFolderExist() => _activeService.appFolderExist();

  @override
  Future<String> uploadFile(String filePath) =>
      _activeService.uploadFile(filePath);

  @override
  Future<String> downloadFile(String fileName, String filePath) =>
      _activeService.downloadFile(fileName, filePath);

  @override
  Future<String> updateFile(String fileId, String filePath) =>
      _activeService.updateFile(fileId, filePath);

  @override
  Future<Map<String, String>> getAllImages(String imgPrefix) =>
      _activeService.getAllImages(imgPrefix);
}
