import 'dart:math' as m;

import 'package:vector_math/vector_math.dart';

double clamp(double val, double min, double max) {
  return m.min(max, m.max(min, val));
}

double lerp<T extends num>(T start, T end, double dt) {
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

const epsilon = 1e-7;
