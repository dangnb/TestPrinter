import 'dart:typed_data';

import 'package:image/image.dart' as imglib;

class ImageUtils {
  static splitImage(Uint8List input) {
    // convert image to image from image package
    imglib.Image? image = imglib.decodeImage(input);
    if (image != null) {
      int width = image.width;
      int height = image.height;
      var split = 100;
      bool full = image.height % split == 0;
      int n = height % split == 0 ? height ~/ split : (height ~/ split) + 1;
      // split image to parts
      List<imglib.Image> parts = [];
      for (int i = 0; i < n; i++) {
        imglib.Image b;
        if (full) {
          // b = imglib.copyCrop(image, 0, i * split, width, split);
          b = imglib.copyCrop(image,
              x: 0, y: i * split, width: width, height: split);
        } else if (i == n - 1) {
          b = imglib.copyCrop(image,
              x: 0, y: i * split, width: width, height: height - i * split);
          //b = imglib.copyCrop(image, 0, i * split, width, height - i * split);
        } else {
          b = imglib.copyCrop(image,
              x: 0, y: i * split, width: width, height: split);
          // b = imglib.copyCrop(image, 0, i * split, width, split);
        }
        b = imglib.grayscale(b);
        b = imglib.grayscale(b);
        b = imglib.grayscale(b);
        parts.add(b);
      }

      // convert image from image package to Image Widget to display
      // List<imglib.Image>? output = [];
      // for (var img in parts) {
      //   output.add(imglib.memory(imglib.encodeJpg(img)));
      // }
      return parts;
    }
    return null;
  }
}
