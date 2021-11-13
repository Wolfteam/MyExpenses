import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:device_info_plus_windows/device_info_plus_windows.dart' as device_info_plus_windows;
import 'package:flutter_user_agentx/flutter_user_agent.dart';
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

  @override
  Map<String, String> get deviceInfo => _deviceInfo;

  @override
  String get appName => _appName;

  @override
  String get version => _version;

  @override
  bool get versionChanged => _versionChanged;

  //TODO: COMPLETE THIS
  @override
  String? get userAgent => Platform.isWindows ? null : FlutterUserAgent.webViewUserAgent!.replaceAll(RegExp(r'wv'), '');

  @override
  bool get canUseFingerPrint => _canUseFingerPrint;

  @override
  Future<void> init() async {
    try {
      //TODO: BUILDNUMBER NOT SHOWING UP ON WINDOWS
      //TODO: VERSION DOES NOT MATCH THE ONE ON THE PUBSPEC
      await FlutterUserAgent.init();
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

      if (!Platform.isWindows) {
        await FlutterUserAgent.init();
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
    final model = info != null ? info.computerName : _na;
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
    _versionChanged = vt.isFirstLaunchForCurrentBuild ?? vt.isFirstLaunchForCurrentVersion ?? vt.isFirstLaunchEver ?? false;
  }
}
