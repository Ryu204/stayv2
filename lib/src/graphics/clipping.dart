/// For personal preferences and convinience, clipping will be performed in
/// homogeneous coordinates
library;

import 'package:stayv2/src/utils/more_math.dart';
import 'package:vector_math/vector_math.dart';

bool pointClip(Vector4 a) {
  return a.w <= 0 ? false : [a.x, a.y, a.z].every((i) => -a.w <= i && i <= a.w);
}

/// An algorithm inspired by Cohen-Sutherland line clipping algorithm
///
/// Ref 1: [https://en.wikipedia.org/wiki/Cohen%E2%80%93Sutherland_algorithm]
///
/// Ref 2: [https://chaosinmotion.com/2016/05/22/3d-clipping-in-homogeneous-coordinates]
///
/// Returns:
/// * whether the line is at least partially inside clipping frustum
/// * start point defined by [t1] in range [0,1]
/// * end point defined by [t2] in range [0,1]
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

/// Implementation of 3D Sutherland-Hodgeman algorithm in homogeneous space
(bool, List<Vector3>?) triangleClip(
  Vector4 a,
  Vector4 b,
  Vector4 c,
) {
  // return (
  //   true,
  //   [Vector3(1, 0, 0), Vector3(0, 1, 0), Vector3(0.333, 0.333, 0.333)]
  // );
  bool isInsidePlaneNth(int order, Vector4 v) {
    return switch (order) {
      0 => v.x >= -v.w,
      1 => v.x <= v.w,
      2 => v.y >= -v.w,
      3 => v.y <= v.w,
      4 => v.z >= -v.w,
      5 => v.z <= v.w,
      _ => throw UnimplementedError()
    };
  }

  double intersectionWithPlaneNth(int order, Vector4 a_, Vector4 b_) {
    return switch (order) {
      5 => (a_.z - a_.w) / (b_.w - b_.z + a_.z - a_.w),
      4 => (a_.z + a_.w) / (-b_.w - b_.z + a_.z + a_.w),
      3 => (a_.y - a_.w) / (b_.w - b_.y + a_.y - a_.w),
      2 => (a_.y + a_.w) / (-b_.w - b_.y + a_.y + a_.w),
      1 => (a_.x - a_.w) / (b_.w - b_.x + a_.x - a_.w),
      0 => (a_.x + a_.w) / (-b_.w - b_.x + a_.x + a_.w),
      _ => throw UnimplementedError()
    };
  }

  /// Each point plus their barycentric coords regarding [a][b][c]
  var input = [
    (a, Vector3(1, 0, 0)),
    (b, Vector3(0, 1, 0)),
    (c, Vector3(0, 0, 1)),
  ];
  final output = <(Vector4, Vector3)>[];

  // Iterate over 6 clipping planes
  for (var plane = 0; plane < 6; ++plane) {
    output.length = 0;
    if (input.length < 3) break;
    final firstPointInside = isInsidePlaneNth(plane, input.first.$1);
    var lastOneInside = firstPointInside;
    if (lastOneInside) {
      output.add(input.first);
    }
    for (var i = 1; i < input.length; ++i) {
      final inside = isInsidePlaneNth(plane, input[i].$1);
      if (inside && lastOneInside) {
        output.add(input[i]);
      } else if (inside != lastOneInside) {
        final dt =
            intersectionWithPlaneNth(plane, input[i].$1, input[i - 1].$1);
        output.add((
          lerpV4(input[i].$1, input[i - 1].$1, dt),
          lerpV3(input[i].$2, input[i - 1].$2, dt)
        ));
        if (inside) output.add(input[i]);
      }
      lastOneInside = inside;
    }
    if (lastOneInside != firstPointInside) {
      final dt = intersectionWithPlaneNth(plane, input.first.$1, input.last.$1);
      output.add((
        lerpV4(input.first.$1, input.last.$1, dt),
        lerpV3(input.first.$2, input.last.$2, dt)
      ));
    }
    input = List.from(output);
  }

  if (output.length < 3) return (false, null);
  final allVertices = output.indexed.map((e) => e.$2.$2).toList();
  return (true, allVertices);
}
