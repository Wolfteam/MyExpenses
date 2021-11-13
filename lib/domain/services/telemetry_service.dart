abstract class TelemetryService {
  Future<void> init();

  Future<void> trackEventAsync(String name, [Map<String, String> properties = const {}]);
}
