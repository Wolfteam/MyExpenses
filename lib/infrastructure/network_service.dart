import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:my_expenses/domain/services/services.dart';

class NetworkServiceImpl implements NetworkService {
  @override
  Future<bool> isInternetAvailable() {
    final checker = InternetConnectionChecker();
    return checker.hasConnection;
  }
}
