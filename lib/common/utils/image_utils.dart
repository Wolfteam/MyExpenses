import 'dart:io';
import 'dart:isolate';

import 'package:http/http.dart' as http;
import 'package:image/image.dart';

import 'app_path_utils.dart';

class ImageUtils {
  static Future<void> resizeImage(
    File input,
    File output,
    int width,
    int height,
  ) async {
    final receivePort = ReceivePort();

    await Isolate.spawn(
        _resizeImage,
        _ResizeParams(
          receivePort.sendPort,
          input,
          output,
          width,
          height,
        ));

    await receivePort.first;
  }

  static Future<String> saveNetworkImage(
    String url, {
    int width = 120,
    int height = 120,
  }) async {
    final receivePort = ReceivePort();
    final filePath = await AppPathUtils.getUserProfileImgPath();

    await Isolate.spawn(
      _saveNetworkImage,
      _SaveNetworkImageParams(
        receivePort.sendPort,
        filePath,
        url,
        width,
        height,
      ),
    );

    return await receivePort.first as String;
  }

  static Future<void> _saveNetworkImage(_SaveNetworkImageParams params) async {
    final response = await http.get(Uri.parse(params.url));
    final image = decodeImage(response.bodyBytes);
    final thumbnail = copyResize(
      image!,
      width: params.width,
      height: params.height,
    );
    final png = encodePng(thumbnail);

    File(params.filePath).writeAsBytesSync(png);
    params.sendPort.send(params.filePath);
  }

  static void _resizeImage(_ResizeParams params) {
    final image = decodeImage(params.input.readAsBytesSync());

    final thumbnail = copyResize(
      image!,
      width: params.width,
      height: params.height,
      interpolation: Interpolation.average,
    );

    final result = encodePng(thumbnail);

    params.output.createSync();

    params.output.writeAsBytesSync(result);

    params.sendPort.send(null);
  }
}

class _ResizeParams {
  final SendPort sendPort;
  final File input;
  final File output;
  final int width;
  final int height;

  const _ResizeParams(
    this.sendPort,
    this.input,
    this.output,
    this.width,
    this.height,
  );
}

class _SaveNetworkImageParams {
  final SendPort sendPort;
  final String filePath;
  final String url;
  final int width;
  final int height;

  const _SaveNetworkImageParams(
    this.sendPort,
    this.filePath,
    this.url,
    this.width,
    this.height,
  );
}
