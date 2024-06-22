import 'dart:math';

import 'package:stayv2/src/graphics/transformable.dart';
import 'package:vector_math/vector_math.dart';

class Camera extends Transformable {
  final _projMatrix = Matrix4.identity();
  final double width;
  final double height;
  final double far;
  final double near;

  Camera.ortho({
    required this.width,
    required this.height,
    this.near = 0.01,
    this.far = 10.0,
  }) {
    _projMatrix.setFrom(makeOrthographicMatrix(
        -width / 2, width / 2, -height / 2, height / 2, near, far));
  }

  Camera.perspective({
    required this.width,
    required this.height,
    double fovYRadians = pi / 2,
    this.near = 0.01,
    this.far = 10.0,
  }) {
    _projMatrix
        .setFrom(makePerspectiveMatrix(fovYRadians, width / height, near, far));
  }

  Matrix4 projectAndViewProduct() {
    return _projMatrix.multiplied(inverseTransform);
  }

  /// Viewport transform calculation in
  /// `https://www.khronos.org/opengl/wiki/Vertex_Post-Processing#Viewport_transform`
  Vector3 viewportTransform({
    double top = 0,
    double left = 0,
    required double width,
    required double height,
    required Vector3 ndc,
  }) {
    return Vector3(
      width * ndc.x / 2 + left + width / 2,
      height * ndc.y / 2 + top + height / 2,
      (far - near) * ndc.z / 2 + (far + near) / 2,
    );
  }
}
