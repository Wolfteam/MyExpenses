import 'dart:io';
import 'dart:isolate';

import 'package:image/image.dart';

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

  static void _resizeImage(_ResizeParams params) {
    final image = decodeImage(params.input.readAsBytesSync());

    final thumbnail = copyResize(
      image,
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
