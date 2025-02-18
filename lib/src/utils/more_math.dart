import 'dart:math' as m;

import 'package:collection/collection.dart';
import 'package:stayv2/src/graphics/color.dart';
import 'package:vector_math/vector_math.dart';

double clamp(double val, double min, double max) {
  return m.min(max, m.max(min, val));
}

void clampColor(Color c) {
  c.storage.forEachIndexed((i, v) {
    c.storage[i] = clamp(v, 0, 1);
  });
}

double lerp<T extends num>(T start, T end, double dt) {
  return start * (1 - dt) + end * dt;
}

Vector2 lerpV2(Vector2 start, Vector2 end, double dt) {
  return start * (1 - dt) + end * dt;
}

Vector4 lerpV4(Vector4 start, Vector4 end, double dt) {
  return start * (1 - dt) + end * dt;
}

Vector3 lerpV3(Vector3 start, Vector3 end, double dt) {
  return start * (1 - dt) + end * dt;
}

Vector4 linearCombV4(List<Vector4> vs, List<double> ts) {
  assert(ts.length == vs.length);
  final res = Vector4.zero();
  for (var i = 0; i < vs.length; ++i) {
    res.add(vs[i] * ts[i]);
  }
  return res;
}

Vector2 linearCombV2(List<Vector2> vs, List<double> ts) {
  assert(ts.length == vs.length);
  final res = Vector2.zero();
  for (var i = 0; i < vs.length; ++i) {
    res.add(vs[i] * ts[i]);
  }
  return res;
}

const epsilon = 1e-7;
