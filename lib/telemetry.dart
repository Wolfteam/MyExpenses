import 'package:flutter_appcenter_bundle/flutter_appcenter_bundle.dart';

import 'secrets.dart';

Future<void> initTelemetry() async {
  await AppCenter.startAsync(
    appSecretAndroid: Secrets.appCenterKey,
    appSecretIOS: '',
    enableAnalytics: true,
    enableCrashes: true,
  );
}
