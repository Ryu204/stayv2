import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:stayv2/src/graphics/color.dart';
import 'package:stayv2/src/utils/resource_holder.dart';

enum ImageType {
  png,
  jpg,
  unspecified,
  byExtension,
}

class Texture2d {
  img.Image? _img;

  Future<bool> load(String filename,
      {ImageType type = ImageType.byExtension}) async {
    _destroy();
    try {
      if (type == ImageType.byExtension) {
        final file = File(filename);
        if (!await file.exists()) {
          throw ArgumentError('Image file does not exist');
        }
        _img = img
            .findDecoderForNamedImage(filename)
            ?.decode(file.readAsBytesSync());
      } else {
        _img = switch (type) {
          ImageType.png => await img.decodePngFile(filename),
          ImageType.jpg => await img.decodeJpgFile(filename),
          ImageType.unspecified => await img.decodeImageFile(filename),
          _ => throw UnimplementedError(),
        };
      }
    } catch (e) {
      _img = null;
    }
    return _img != null;
  }

  bool loaded() {
    return _img != null;
  }

  Color get(int x, int y) {
    final pixel = _img!.getPixel(x, y);
    return Color(
      pixel.rNormalized.toDouble(),
      pixel.gNormalized.toDouble(),
      pixel.bNormalized.toDouble(),
      pixel.aNormalized.toDouble(),
    );
  }

  void _destroy() {
    _img = null;
  }
}

typedef TextureList = ResourceHolder<Texture2d>;
