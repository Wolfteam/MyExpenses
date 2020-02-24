import 'package:log_4_dart_2/log_4_dart_2.dart';

abstract class LoggingService {
  void info(Type type, String msg);

  void warning(Type type, String msg, [Exception ex, StackTrace trace]);

  void error(Type type, String msg, [Exception ex, StackTrace trace]);
}

class LoggingServiceImpl implements LoggingService {
  final Logger _logger;

  LoggingServiceImpl(this._logger);

  @override
  void info(Type type, String msg) {
    _logger.info(type.toString(), msg);
  }

  @override
  void warning(Type type, String msg, [Exception ex, StackTrace trace]) {
    if (ex != null) {
      _logger.warning(type.toString(), _formatEx(msg, ex), ex, trace);
    } else {
      _logger.warning(type.toString(), msg, ex, trace);
    }
  }

  @override
  void error(Type type, String msg, [Exception ex, StackTrace trace]) {
    if (ex != null) {
      _logger.error(type.toString(), _formatEx(msg, ex), ex, trace);
    } else {
      _logger.error(type.toString(), _formatEx(msg, ex), ex, trace);
    }
  }

  String _formatEx(String msg, Exception ex) {
    return '$msg \n $ex';
  }
}
