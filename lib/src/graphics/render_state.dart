import 'package:stayv2/src/graphics/texture.dart';
import 'package:vector_math/vector_math.dart';

class RenderState {
  Matrix4 transform = Matrix4.identity();
  Texture2d? texture;
  bool defaultTextureFallback = true;

  RenderState(
    this.transform, {
    this.texture,
    this.defaultTextureFallback = true,
  });

  RenderState.identity();
}
