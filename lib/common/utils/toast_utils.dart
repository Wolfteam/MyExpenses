import 'package:flutter/material.dart';
import 'package:flutter_flexible_toast/flutter_flexible_toast.dart';

void showSucceedToast(
  String msg, {
  Color textColor = Colors.white,
  Color bgColor = Colors.green,
}) {
  _showToast(msg, ICON.SUCCESS, textColor, bgColor);
}

void showInfoToast(
  String msg, {
  Color textColor = Colors.white,
  Color bgColor = Colors.blue,
}) {
  _showToast(msg, ICON.INFO, textColor, bgColor);
}

void showWarningToast(
  String msg, {
  Color textColor = Colors.white,
  Color bgColor = Colors.orange,
}) {
  _showToast(msg, ICON.WARNING, textColor, bgColor);
}

void showErrorToast(
  String msg, {
  Color textColor = Colors.white,
  Color bgColor = Colors.red,
}) {
  _showToast(msg, ICON.ERROR, textColor, bgColor);
}

void _showToast(
  String msg,
  ICON icon,
  Color textColor,
  Color bgColor, {
  Toast lenght = Toast.LENGTH_SHORT,
}) {
  FlutterFlexibleToast.showToast(
    message: msg,
    toastLength: lenght,
    toastGravity: ToastGravity.BOTTOM,
    icon: icon,
    radius: 50,
    textColor: textColor,
    backgroundColor: bgColor,
    timeInSeconds: 2,
  );
}
