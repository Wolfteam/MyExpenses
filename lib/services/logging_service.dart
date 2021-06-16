import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:sprintf/sprintf.dart';

import '../telemetry.dart';

abstract class LoggingService {
  void info(Type type, String msg, [List<Object> args]);

  void warning(Type type, String msg, [dynamic ex, StackTrace trace]);

  void error(Type type, String msg, [dynamic ex, StackTrace trace]);
}

class LoggingServiceImpl implements LoggingService {
  final _logger = Logger();

  LoggingServiceImpl();

  @override
  void info(Type type, String msg, [List<Object>? args]) {
    if (args != null && args.isNotEmpty) {
      _logger.i('$type - ${sprintf(msg, args)}');
    } else {
      _logger.i('$type - $msg');
    }
  }

  @override
  void warning(Type type, String msg, [dynamic ex, StackTrace? trace]) {
    final tag = type.toString();
    _logger.w('$tag - ${_formatEx(msg, ex)}', ex, trace);

    if (kReleaseMode) {
      _trackWarning(tag, msg, ex, trace);
    }
  }

  @override
  void error(Type type, String msg, [dynamic ex, StackTrace? trace]) {
    final tag = type.toString();
    _logger.e('$tag - ${_formatEx(msg, ex)}', ex, trace);

    if (kReleaseMode) {
      _trackError(tag, msg, ex, trace);
    }
  }

  String _formatEx(String msg, dynamic ex) {
    if (ex != null) {
      return '$msg \n $ex';
    }
    return '$msg \n No exception available';
  }

  void _trackError(String tag, String msg, [dynamic ex, StackTrace? trace]) {
    final map = _buildError(tag, msg, ex, trace);
    trackEventAsync('Error - ${DateTime.now()}', map);
  }

  void _trackWarning(String tag, String msg, [dynamic ex, StackTrace? trace]) {
    final map = _buildError(tag, msg, ex, trace);
    trackEventAsync('Warning - ${DateTime.now()}', map);
  }

  Map<String, String> _buildError(String tag, String? msg, [dynamic ex, StackTrace? trace]) {
    return {
      'tag': tag,
      'msg': msg ?? 'No message available',
      'ex': ex?.toString() ?? 'No exception available',
      'trace': trace?.toString() ?? 'No trace available',
    };
  }
}
