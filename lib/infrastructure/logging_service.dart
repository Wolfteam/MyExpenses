import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:my_expenses/domain/extensions/string_extensions.dart';
import 'package:my_expenses/domain/services/services.dart';
import 'package:sprintf/sprintf.dart';

class LoggingServiceImpl implements LoggingService {
  final DeviceInfoService _deviceInfoService;
  final _logger = Logger();

  LoggingServiceImpl(this._deviceInfoService);

  @override
  void info(Type type, String msg, [List<Object>? args]) {
    assert(!msg.isNullEmptyOrWhitespace);

    if (args != null && args.isNotEmpty) {
      _logger.i('$type - ${sprintf(msg, args)}');
    } else {
      _logger.i('$type - $msg');
    }
  }

  @override
  void warning(Type type, String msg, [dynamic ex, StackTrace? trace]) {
    assert(!msg.isNullEmptyOrWhitespace);
    final tag = type.toString();
    _logger.w('$tag - ${_formatEx(msg, ex)}', error: ex, stackTrace: trace);

    if (kReleaseMode) {
      _trackWarning(tag, msg, ex, trace);
    }
  }

  @override
  void error(Type type, String msg, [dynamic ex, StackTrace? trace]) {
    assert(!msg.isNullEmptyOrWhitespace);
    final tag = type.toString();
    _logger.e('$tag - ${_formatEx(msg, ex)}', error: ex, stackTrace: trace);

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
  }

  void _trackWarning(String tag, String msg, [dynamic ex, StackTrace? trace]) {
    final map = _buildError(tag, msg, ex, trace);
  }

  Map<String, String> _buildError(String tag, String msg, [dynamic ex, StackTrace? trace]) {
    final map = {
      'Tag': tag,
      'Msg': msg,
      'Ex': ex?.toString() ?? 'No exception available',
      'Trace': trace?.toString() ?? 'No trace available',
    };

    map.addAll(_deviceInfoService.deviceInfo);

    return map;
  }
}
