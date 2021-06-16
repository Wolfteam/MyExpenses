import 'flutter_appcenter_bundle.dart';
import 'secrets.dart';

//Only call this function from the main.dart
Future<void> initTelemetry() async {
  await AppCenter.startAsync(appSecretAndroid: Secrets.appCenterKey, appSecretIOS: '');
}

Future<void> trackEventAsync(String name, [Map<String, String> properties = const {}]) async {
  await AppCenter.trackEventAsync(name, properties);
}
