import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:stayv2/src/graphics/color.dart';
import 'package:stayv2/src/utils/more_math.dart';
import 'package:stayv2/src/utils/resource_holder.dart';
import 'package:vector_math/vector_math.dart';

enum ImageType {
  png,
  jpg,
  unspecified,
  byExtension,
}

class Texture2d {
  img.Image? _img;

  static Texture2d createFromFile(
    String filename, {
    ImageType type = ImageType.byExtension,
    bool checkLoaded = false,
  }) {
    final res = Texture2d();
    if (!res.load(filename, type: type)) {
      throw ArgumentError('Cannot create texture from file');
    }
    return res;
  }

  bool load(
    String filename, {
    ImageType type = ImageType.byExtension,
  }) {
    _destroy();
    try {
      final file = File(filename);
      Uint8List bytes;
      if (!file.existsSync()) {
        throw ArgumentError('Image file does not exist');
      } else {
        bytes = file.readAsBytesSync();
      }
      if (type == ImageType.byExtension) {
        _img = img.findDecoderForNamedImage(filename)?.decode(bytes);
      } else {
        _img = switch (type) {
          ImageType.png => img.decodePng(bytes),
          ImageType.jpg => img.decodeJpg(bytes),
          ImageType.unspecified => img.decodeImage(bytes),
          _ => throw UnimplementedError(),
        };
      }
    } catch (e) {
      _img = null;
    }
    return _img != null;
  }

  Color get(Vector2 v) {
    // TODO: add more sampling method?
    v.x = clamp(v.x, 0, 1);
    v.y = clamp(v.y, 0, 1);
    final x = (v.x * (_img!.width - 1)).floor();
    final y = (v.y * (_img!.height - 1)).floor();
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
