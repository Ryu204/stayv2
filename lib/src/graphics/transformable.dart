import 'package:vector_math/vector_math.dart';

class Transformable {
  final _position = Vector3.zero();
  final _scale = Vector3.all(1);
  final _rotation = Quaternion.identity();
  final _transform = Matrix4.identity();
  final _invTransform = Matrix4.identity();
  var _tfCalculated = false;
  var _invTfCalculated = false;

  Transformable move(Vector3 dir) {
    _position.add(dir);
    _setDirtyFlags();
    return this;
  }

  Transformable setPosition(Vector3 pos) {
    _position.setFrom(pos);
    _setDirtyFlags();
    return this;
  }

  Transformable rotate(double rad, {Vector3? axis}) {
    _rotation.add(Quaternion.axisAngle(axis ?? Vector3(0, 0, 1), rad));
    _setDirtyFlags();
    return this;
  }

  Transformable setRotation(double rad, {Vector3? axis}) {
    _rotation.setFrom(Quaternion.axisAngle(axis ?? Vector3(0, 0, 1), rad));
    _setDirtyFlags();
    return this;
  }

  Transformable scale(Vector3 s) {
    _scale.multiply(s);
    _setDirtyFlags();
    return this;
  }

  Transformable scaleAll(double s) {
    _scale.scale(s);
    _setDirtyFlags();
    return this;
  }

  Matrix4 get transform {
    if (!_tfCalculated) {
      _tfCalculated = true;
      _transform.setFromTranslationRotationScale(_position, _rotation, _scale);
    }
    return _transform;
  }

  Matrix4 get inverseTransform {
    if (!_invTfCalculated) {
      _invTfCalculated = true;
      _invTransform.copyInverse(transform);
    }
    return _invTransform;
  }

  void _setDirtyFlags() {
    _invTfCalculated = false;
    _tfCalculated = false;
  }
}
