import 'dart:math';

import 'package:stayv2/src/graphics/transformable.dart';
import 'package:vector_math/vector_math.dart';

enum CameraType {
  ortho,
  perspective,
}

class Camera extends Transformable {
  final _projMatrix = Matrix4.identity();
  final CameraType _type;
  double _width;
  double _height;
  final double _far;
  final double _near;
  double? _fovYRadians;

  Camera.ortho({
    required double width,
    required double height,
    double near = 0.01,
    double far = 10.0,
  })  : _near = near,
        _far = far,
        _height = height,
        _width = width,
        _type = CameraType.ortho {
    _updateProjMatrix();
  }

  Camera.perspective({
    required double width,
    required double height,
    double fovYRadians = pi / 2,
    double near = 0.01,
    double far = 10.0,
  })  : _near = near,
        _far = far,
        _height = height,
        _width = width,
        _fovYRadians = fovYRadians,
        _type = CameraType.perspective {
    _updateProjMatrix();
  }

  CameraType get type {
    return _type;
  }

  double get near {
    return _near;
  }

  double get far {
    return _far;
  }

  void resizeToFit({
    bool keepHeight = true,
    required double width,
    required double height,
  }) {
    if (width <= 0 || height <= 0) return;
    if (keepHeight) {
      _width = _height * width / height;
    } else {
      _height = _width * height / width;
    }
    _updateProjMatrix();
  }

  Matrix4 projectAndViewProduct() {
    return _projMatrix.multiplied(inverseTransform);
  }

  /// Viewport transform calculation in
  /// `https://www.khronos.org/opengl/wiki/Vertex_Post-Processing#Viewport_transform`
  Vector4 viewportTransform({
    double top = 0,
    double left = 0,
    required double width,
    required double height,
    required Vector4 ndc,
  }) {
    return Vector4(
      width * (-ndc.x / 2) + left + width / 2,
      height * (-ndc.y / 2) + top + height / 2,
      (_far - _near) * ndc.z / 2 + (_far + _near) / 2,
      ndc.w,
    );
  }

  void _updateProjMatrix() {
    switch (_type) {
      case CameraType.ortho:
        _projMatrix.setFrom(makeOrthographicMatrix(
          -_width / 2,
          _width / 2,
          -_height / 2,
          _height / 2,
          _near,
          _far,
        ));
        break;
      case CameraType.perspective:
        _projMatrix.setFrom(makePerspectiveMatrix(
          _fovYRadians!,
          _width / _height,
          _near,
          _far,
        ));
        break;
    }
  }
}
