import 'package:stayv2/src/utils/more_math.dart';
import 'package:vector_math/vector_math.dart';

/// For personal preferences and convinience, clipping will be performed in
/// homogeneous coordinates

/// An algorithm inspired by Cohen-Sutherland line clipping algorithm
///
/// Ref 1: [https://en.wikipedia.org/wiki/Cohen%E2%80%93Sutherland_algorithm]
///
/// Ref 2: [https://chaosinmotion.com/2016/05/22/3d-clipping-in-homogeneous-coordinates]
bool lineClip(Vector4 a, Vector4 b) {
  const inside = 0;
  const left = 1;
  const right = 2;
  const bottom = 4;
  const top = 8;
  const front = 16;
  const back = 32;

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
    return code;
  }

  var accept = false;
  int outcodeA = 0, outcodeB = 0;
  while (true) {
    var delta = 0.0;
    outcodeA = computeOutCode(a);
    outcodeB = computeOutCode(b);
    if ((outcodeA | outcodeB) == 0) {
      accept = true;
      break;
    }
    if ((outcodeA & outcodeB) != 0) {
      accept = false;
      break;
    }
    final outcodeOut = outcodeB > outcodeA ? outcodeB : outcodeA;
    if ((outcodeOut & back) != 0) {
      delta = (a.z - a.w) / (b.w - b.z + a.z - a.w);
    } else if ((outcodeOut & front) != 0) {
      delta = (a.z + a.w) / (-b.w - b.z + a.z + a.w);
    } else if ((outcodeOut & top) != 0) {
      delta = (a.y - a.w) / (b.w - b.y + a.y - a.w);
    } else if ((outcodeOut & bottom) != 0) {
      delta = (a.y + a.w) / (-b.w - b.y + a.y + a.w);
    } else if ((outcodeOut & right) != 0) {
      delta = (a.x - a.w) / (b.w - b.x + a.x - a.w);
    } else if ((outcodeOut & left) != 0) {
      delta = (a.x + a.w) / (-b.w - b.x + a.x + a.w);
    }
    if (outcodeOut == outcodeA) {
      a = lerpV4(a, b, delta);
    } else {
      b = lerpV4(a, b, delta);
    }
  }
  return accept;
}
