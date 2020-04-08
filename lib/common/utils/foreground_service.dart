import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class ForegroundService {
  // static const MethodChannel _mainChannel =
  //     MethodChannel('com.miraisoft.my_expenses.foreground/main');

  // static const MethodChannel _callbackChannel =
  //     MethodChannel('com.miraisoft.my_expenses.foreground/callback');

  // static Function onStartedMethod;
  // static Function onStoppedMethod;

  // static Future<void> startForegroundService({
  //   @required String iconName,
  //   @required String title,
  //   bool holdWakeLock = false,
  //   Function onStarted,
  //   Function onStopped,
  //   String content = "",
  //   String subtext = "",
  //   bool chronometer = false,
  // }) async {
  //   if (onStarted != null) {
  //     onStartedMethod = onStarted;
  //   }

  //   if (onStopped != null) {
  //     onStoppedMethod = onStopped;
  //   }

  //   await _mainChannel.invokeMethod("startForegroundService", <String, dynamic>{
  //     'holdWakeLock': holdWakeLock,
  //     'icon': iconName,
  //     'title': title,
  //     'content': content,
  //     'subtext': subtext,
  //     'chronometer': chronometer,
  //   });
  // }

  // static Future<void> setServiceMethod(Function serviceMethod) async {
  //   final serviceMethodHandle =
  //       PluginUtilities.getCallbackHandle(serviceMethod).toRawHandle();

  //   _callbackChannel.setMethodCallHandler(_onForegroundServiceCallback);

  //   await _mainChannel.invokeMethod("setServiceMethodHandle",
  //       <String, dynamic>{'serviceMethodHandle': serviceMethodHandle});
  // }

  // static Future<void> setServiceMethodInterval({int seconds = 5}) async {
  //   await _mainChannel
  //       .invokeMethod("setServiceMethodInterval", <String, dynamic>{
  //     'seconds': seconds,
  //   });
  // }

  // static Future<void> stopForegroundService() async {
  //   await _mainChannel.invokeMethod("stopForegroundService");
  // }

  //   static Future<void> _onForegroundServiceCallback(MethodCall call) async {
  //   switch (call.method) {
  //     case "onStarted":
  //       if (onStartedMethod != null) {
  //         onStartedMethod();
  //       }
  //       break;
  //     case "onStopped":
  //       if (onStoppedMethod != null) {
  //         onStoppedMethod();
  //       }
  //       break;
  //     case "onServiceMethodCallback":
  //       final CallbackHandle handle =
  //           CallbackHandle.fromRawHandle(call.arguments as int);
  //       if (handle != null) {
  //         PluginUtilities.getCallbackFromHandle(handle)();
  //       }
  //       break;
  //     default:
  //       break;
  //   }
  // }
}
