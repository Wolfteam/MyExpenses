import 'package:internet_connection_checker/internet_connection_checker.dart';

abstract class NetworkService {
  Future<bool> isInternetAvailable();
}

class NetworkServiceImpl implements NetworkService {
  @override
  Future<bool> isInternetAvailable() {
    final checker = InternetConnectionChecker();
    return checker.hasConnection;
  }
}
