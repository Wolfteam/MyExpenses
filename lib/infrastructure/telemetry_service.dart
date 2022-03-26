import 'dart:io';

import 'package:flutter/services.dart';
import 'package:my_expenses/domain/services/services.dart';
import 'package:my_expenses/infrastructure/secrets.dart';

class TelemetryServiceImpl implements TelemetryService {
  bool _initialized = false;
  @override
  Future<void> init() async {
    await _AppCenter.startAsync(appSecretAndroid: Secrets.appCenterKey, appSecretIOS: '');
    _initialized = true;
  }

  @override
  Future<void> trackEventAsync(String name, [Map<String, String> properties = const {}]) async {
    if (_initialized) {
      await _AppCenter.trackEventAsync(name, properties);
    }
  }
}

const _methodChannelName = 'com.github.wolfteam.my_expenses';
const _methodChannel = MethodChannel(_methodChannelName);

class _AppCenter {
  static Future<void> startAsync({
    required String appSecretAndroid,
    required String appSecretIOS,
    bool enableAnalytics = true,
    bool enableCrashes = true,
    bool usePrivateDistributeTrack = false,
  }) async {
    if (Platform.isWindows) {
      return;
    }

    String appSecret;
    if (Platform.isAndroid) {
      appSecret = appSecretAndroid;
    } else if (Platform.isIOS) {
      appSecret = appSecretIOS;
    } else {
      throw UnsupportedError('Current platform is not supported.');
    }

    if (appSecret.isEmpty) {
      return;
    }

    await configureAnalyticsAsync(enabled: enableAnalytics);
    await configureCrashesAsync(enabled: enableCrashes);

    await _methodChannel.invokeMethod('start', <String, dynamic>{
      'secret': appSecret.trim(),
      'usePrivateTrack': usePrivateDistributeTrack,
    });
  }

  /// Track events
  static Future<void> trackEventAsync(String name, [Map<String, String> properties = const {}]) async {
    await _methodChannel.invokeMethod('trackEvent', <String, dynamic>{
      'name': name,
      'properties': properties,
    });
  }

  /// Check whether analytics is enabled
  static Future<bool> isAnalyticsEnabledAsync() async {
    return await _methodChannel.invokeMethod<bool>('isAnalyticsEnabled') ?? false;
  }

  /// Get appcenter installation id
  static Future<String> getInstallIdAsync() async {
    return _methodChannel.invokeMethod('getInstallId').then((r) => r as String);
  }

  /// Enable or disable analytics
  static Future configureAnalyticsAsync({required bool enabled}) async {
    await _methodChannel.invokeMethod('configureAnalytics', enabled);
  }

  /// Check whether crashes is enabled
  static Future<bool> isCrashesEnabledAsync() async {
    return await _methodChannel.invokeMethod<bool>('isCrashesEnabled') ?? false;
  }

  /// Enable or disable appcenter crash reports
  static Future configureCrashesAsync({required bool enabled}) async {
    await _methodChannel.invokeMethod('configureCrashes', enabled);
  }
}
