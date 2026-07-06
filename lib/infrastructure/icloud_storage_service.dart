import 'package:flutter/services.dart';
import 'package:icloud_storage/icloud_storage.dart';
import 'package:my_expenses/domain/services/services.dart';
import 'package:path/path.dart';

class ICloudStorageServiceImpl implements CloudStorageService {
  final LoggingService _logger;
  static const _containerId = 'iCloud.com.miraisoft.myExpenses';
  static const _methodChannel = MethodChannel('icloud_storage');

  ICloudStorageServiceImpl(this._logger);

  /// Gathers file metadata from iCloud using the method channel directly,
  /// bypassing the plugin's ICloudFile.fromMap which crashes when
  /// isUploaded/isUploading are null.
  Future<List<Map<dynamic, dynamic>>> _gatherRaw() async {
    final mapList = await _methodChannel.invokeListMethod<Map<dynamic, dynamic>>(
      'gather',
      {
        'containerId': _containerId,
        'eventChannelName': '',
      },
    );
    return mapList ?? [];
  }

  @override
  Future<bool> isAvailable() async {
    try {
      _logger.info(runtimeType, 'isAvailable: Checking if iCloud is accessible...');
      await _gatherRaw();
      _logger.info(runtimeType, 'isAvailable: iCloud is accessible');
      return true;
    } catch (e, s) {
      _logger.warning(runtimeType, 'isAvailable: iCloud is not accessible', e, s);
      return false;
    }
  }

  @override
  Future<bool> appFolderExist() async {
    try {
      _logger.info(runtimeType, 'appFolderExist: Checking if app_file.json exists...');
      final files = await _gatherRaw();
      final exists = files.any((f) => f['relativePath'] == 'app_file.json');
      _logger.info(runtimeType, 'appFolderExist: app_file.json exists = $exists');
      return exists;
    } catch (e, s) {
      _logger.error(runtimeType, 'appFolderExist: Unknown error occurred...', e, s);
      rethrow;
    }
  }

  @override
  Future<String> uploadFile(String filePath) async {
    try {
      final fileName = basename(filePath);
      _logger.info(runtimeType, 'uploadFile: Trying to upload file = $fileName...');
      await ICloudStorage.upload(
        containerId: _containerId,
        filePath: filePath,
        destinationRelativePath: fileName,
      );
      _logger.info(runtimeType, 'uploadFile: File was successfully uploaded');
      return fileName;
    } catch (e, s) {
      _logger.error(runtimeType, 'uploadFile: Unknown error occurred...', e, s);
      rethrow;
    }
  }

  @override
  Future<String> downloadFile(String fileName, String filePath) async {
    try {
      _logger.info(runtimeType, 'downloadFile: Downloading file = $fileName from iCloud...');
      await ICloudStorage.download(
        containerId: _containerId,
        relativePath: fileName,
        destinationFilePath: filePath,
      );
      _logger.info(runtimeType, 'downloadFile: File was successfully downloaded');
      return fileName;
    } catch (e, s) {
      _logger.error(runtimeType, 'downloadFile: Unknown error occurred...', e, s);
      rethrow;
    }
  }

  @override
  Future<String> updateFile(String fileId, String filePath) {
    _logger.info(runtimeType, 'updateFile: Delegating to uploadFile (iCloud overwrites by filename)');
    return uploadFile(filePath);
  }

  @override
  Future<Map<String, String>> getAllImages(String imgPrefix) async {
    try {
      _logger.info(runtimeType, 'getAllImages: Listing files with prefix = $imgPrefix...');
      final files = await _gatherRaw();
      final matching = files.where((f) {
        final path = f['relativePath'] as String?;
        return path != null && basename(path).startsWith(imgPrefix);
      });
      final result = {
        for (final f in matching) f['relativePath'] as String: f['relativePath'] as String,
      };
      _logger.info(runtimeType, 'getAllImages: Found ${result.length} matching files');
      return result;
    } catch (e, s) {
      _logger.error(runtimeType, 'getAllImages: Unknown error occurred...', e, s);
      rethrow;
    }
  }
}
