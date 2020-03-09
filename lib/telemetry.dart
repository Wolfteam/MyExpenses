import 'package:flutter_appcenter_bundle/flutter_appcenter_bundle.dart';

Future<void> initTelemetry() async {
  await AppCenter.startAsync(
    appSecretAndroid: 'xxxx',
    appSecretIOS: 'xxxx',
    enableAnalytics: true,
    enableCrashes: true,
  );
}
