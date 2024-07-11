import 'package:stayv2/src/utils/more_math.dart';
import 'package:vector_math/vector_math.dart';

bool pointClip(Vector4 a) {
  return a.w <= 0 ? false : [a.x, a.y, a.z].every((i) => -a.w <= i && i <= a.w);
}

/// For personal preferences and convinience, clipping will be performed in
/// homogeneous coordinates

/// An algorithm inspired by Cohen-Sutherland line clipping algorithm
///
/// Ref 1: [https://en.wikipedia.org/wiki/Cohen%E2%80%93Sutherland_algorithm]
///
/// Ref 2: [https://chaosinmotion.com/2016/05/22/3d-clipping-in-homogeneous-coordinates]
(bool, double t1, double t2) lineClip(Vector4 a, Vector4 b) {
  const inside = 0;
  const left = 1;
  const right = 2;
  const bottom = 4;
  const top = 8;
  const front = 16;
  const back = 32;

  final a_ = a.clone(), b_ = b.clone();

  var clippedSides = 0;
  int computeOutCode(Vector4 v) {
    var code = inside;
    if (v.z < -v.w) {
      code |= front;
    } else if (v.z > v.w) {
      code |= back;
    }
    if (v.x < -v.w) {
      code |= left;
    } else if (v.x > v.w) {
      code |= right;
    }
    if (v.y < -v.w) {
      code |= bottom;
    } else if (v.y > v.w) {
      code |= top;
    }
    return code & (~clippedSides);
  }

  var accept = false;
  double t1 = 0, t2 = 1;
  int outcodeA = 0, outcodeB = 0;
  while (true) {
    var delta = 0.0;
    outcodeA = computeOutCode(a_);
    outcodeB = computeOutCode(b_);
    if ((outcodeA | outcodeB) == 0) {
      accept = true;
      break;
    }
    if ((outcodeA & outcodeB) != 0) {
      accept = false;
      break;
    }
    final outcodeOut = outcodeA > outcodeB ? outcodeA : outcodeB;
    if ((outcodeOut & back) != 0) {
      delta = (a_.z - a_.w) / (b_.w - b_.z + a_.z - a_.w);
      clippedSides |= back;
    } else if ((outcodeOut & front) != 0) {
      delta = (a_.z + a_.w) / (-b_.w - b_.z + a_.z + a_.w);
      clippedSides |= front;
    } else if ((outcodeOut & top) != 0) {
      delta = (a_.y - a_.w) / (b_.w - b_.y + a_.y - a_.w);
      clippedSides |= top;
    } else if ((outcodeOut & bottom) != 0) {
      delta = (a_.y + a_.w) / (-b_.w - b_.y + a_.y + a_.w);
      clippedSides |= bottom;
    } else if ((outcodeOut & right) != 0) {
      delta = (a_.x - a_.w) / (b_.w - b_.x + a_.x - a_.w);
      clippedSides |= right;
    } else if ((outcodeOut & left) != 0) {
      delta = (a_.x + a_.w) / (-b_.w - b_.x + a_.x + a_.w);
      clippedSides |= left;
    }
    if (outcodeOut == outcodeA) {
      a_.setFrom(lerpV4(a_, b_, delta));
      t1 = lerp(t1, t2, delta);
    } else {
      b_.setFrom(lerpV4(a_, b_, delta));
      t2 = lerp(t1, t2, delta);
    }
  }
  assert(t1 >= 0 && t1 <= 1 && t2 >= 0 && t2 <= 1);
  return (accept, t1, t2);
}
