abstract class DeviceInfoService {
  Map<String, String> get deviceInfo;

  String get appName;

  String get version;

  bool get versionChanged;

  bool get canUseFingerPrint;

  String get previousVersion;

  int get previousBuildVersion;

  Future<void> init();
}
