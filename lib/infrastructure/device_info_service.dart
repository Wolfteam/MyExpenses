import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:device_info_plus_windows/device_info_plus_windows.dart' as device_info_plus_windows;
import 'package:local_auth/local_auth.dart';
import 'package:my_expenses/domain/services/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:version_tracker/version_tracker.dart';

const _na = 'N/A';

class DeviceInfoServiceImpl implements DeviceInfoService {
  late Map<String, String> _deviceInfo;
  late String _version;
  late String _appName;
  late bool _versionChanged = false;
  late bool _canUseFingerPrint = false;
  late String _previousVersion;
  late int _previousBuildVersion;

  @override
  Map<String, String> get deviceInfo => _deviceInfo;

  @override
  String get appName => _appName;

  @override
  String get version => _version;

  @override
  bool get versionChanged => _versionChanged;

  @override
  bool get canUseFingerPrint => _canUseFingerPrint;

  @override
  String get previousVersion => _previousVersion;

  @override
  int get previousBuildVersion => _previousBuildVersion;

  @override
  Future<void> init() async {
    try {
      //TODO: BUILDNUMBER NOT SHOWING UP ON WINDOWS
      //TODO: VERSION DOES NOT MATCH THE ONE ON THE PUBSPEC
      final packageInfo = await PackageInfo.fromPlatform();
      _appName = packageInfo.appName;
      _version = Platform.isWindows ? packageInfo.version : '${packageInfo.version}+${packageInfo.buildNumber}';

      await _initVersionTracker();

      if (Platform.isAndroid) {
        await _initForAndroid();
      }

      if (Platform.isWindows) {
        await _initForWindows();
      }
    } catch (ex) {
      _deviceInfo = {
        'Model': _na,
        'OsVersion': _na,
        'AppVersion': _na,
      };
      _version = _appName = _na;
    }
  }

  Future<void> _initForWindows() async {
    final deviceInfo = device_info_plus_windows.DeviceInfoWindows();
    //TODO: DeviceInfoPlugin CRASHES ON WINDOWS
    final info = await deviceInfo.windowsInfo();
    final model = info.computerName;
    _deviceInfo = {
      'Model': model,
      'OsVersion': _na,
      'AppVersion': _version,
    };
  }

  Future<void> _initForAndroid() async {
    final deviceInfo = DeviceInfoPlugin();
    final info = await deviceInfo.androidInfo;
    final localAuth = LocalAuthentication();
    final availableBiometrics = await localAuth.getAvailableBiometrics();
    final canCheckBiometrics = await localAuth.canCheckBiometrics && await localAuth.isDeviceSupported();
    _canUseFingerPrint = canCheckBiometrics && availableBiometrics.contains(BiometricType.fingerprint);
    _deviceInfo = {
      'Model': info.model ?? _na,
      'OsVersion': '${info.version.sdkInt}',
      'AppVersion': _version,
    };
  }

  Future<void> _initVersionTracker() async {
    final vt = VersionTracker();
    await vt.track();
    _previousVersion = vt.previousVersion ?? _na;
    _previousBuildVersion = int.tryParse(vt.previousBuild ?? '-1') ?? -1;
    _versionChanged = vt.isFirstLaunchForCurrentBuild == true || vt.isFirstLaunchForCurrentVersion == true || vt.isFirstLaunchEver == true;
  }
}
