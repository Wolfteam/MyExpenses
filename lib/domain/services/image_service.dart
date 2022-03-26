import 'dart:io';

abstract class ImageService {
  Future<void> resizeImage(File input, File output, int width, int height);

  Future<String> saveNetworkImage(String url, {int width = 120, int height = 120});
}
