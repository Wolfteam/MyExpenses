import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum _ToastType {
  info,
  succeed,
  warning,
  error,
}

class ToastUtils {
  static Duration toastDuration = const Duration(seconds: 2);

  static FToast of(BuildContext context) {
    final fToast = FToast();
    fToast.init(context);
    return fToast;
  }

  static void showSucceedToast(BuildContext context, String msg) => _showToast(ToastUtils.of(context), msg, Colors.white, _ToastType.succeed);

  static void showInfoToast(BuildContext context, String msg) => _showToast(ToastUtils.of(context), msg, Colors.white, _ToastType.info);

  static void showWarningToast(BuildContext context, String msg) => _showToast(ToastUtils.of(context), msg, Colors.white, _ToastType.warning);

  static void showErrorToast(BuildContext context, String msg) => _showToast(ToastUtils.of(context), msg, Colors.white, _ToastType.error);

  static void _showToast(FToast toast, String msg, Color textColor, _ToastType type) {
    Color bgColor;
    Icon icon;
    switch (type) {
      case _ToastType.info:
        bgColor = Colors.blue;
        icon = const Icon(Icons.info, color: Colors.white);
      case _ToastType.succeed:
        bgColor = Colors.green;
        icon = const Icon(Icons.check, color: Colors.white);
      case _ToastType.warning:
        bgColor = Colors.orange;
        icon = const Icon(Icons.warning, color: Colors.white);
      case _ToastType.error:
        bgColor = Colors.red;
        icon = const Icon(Icons.dangerous, color: Colors.white);
      default:
        throw Exception('Invalid toast type = $type');
    }

    final widget = _buildToast(msg, textColor, bgColor, icon, toast.context!);
    toast.showToast(
      child: widget,
      gravity: ToastGravity.BOTTOM,
      toastDuration: toastDuration,
    );
  }

  static Widget _buildToast(String msg, Color textColor, Color bgColor, Icon icon, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: bgColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 10.0),
          Flexible(
            child: Text(
              msg,
              style: TextStyle(color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}
