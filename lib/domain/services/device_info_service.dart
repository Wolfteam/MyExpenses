abstract class DeviceInfoService {
  Map<String, String> get deviceInfo;

  String get appName;

  String get version;

  bool get versionChanged;

  String? get userAgent;

  bool get canUseFingerPrint;

  Future<void> init();
}
