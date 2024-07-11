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

final epsilon = 1e-7;
