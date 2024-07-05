import 'package:vector_math/vector_math.dart';

/// Results indicate if p is in the left/right side of vector
/// `end - begin`
///
/// If result is positive, p is in the right
double edgeFunction(Vector2 p, Vector2 begin, Vector2 end) {
  return (p.x - begin.x) * (end.y - begin.y) -
      (p.y - begin.y) * (end.x - begin.x);
}

/// Returns
/// * is [p] inside triangle formed by [a], [b] and [c]
/// * edge function value of [p], [b], [c]
/// * edge function value of [p], [c], [a]
/// * edge function value of [p], [a], [b]
/// [a][b][c] is expected to be in CCW order
(bool, double, double, double) isInsideTriangle(
    Vector2 p, Vector2 a, Vector2 b, Vector2 c) {
  final (ra, rb, rc) = (
    edgeFunction(p, b, c),
    edgeFunction(p, c, a),
    edgeFunction(p, a, b),
  );
  final (ea, eb, ec) = (c - b, a - c, b - a);

  if ((ra == 0 && !_isTopLeftEdge(ea)) ||
      (rb == 0 && !_isTopLeftEdge(eb)) ||
      (rc == 0 && !_isTopLeftEdge(ec))) {
    return (false, ra, rb, rc);
  }
  if ((ra >= 0 && rb >= 0 && rc >= 0) || (ra < 0 && rb < 0 && rc < 0)) {
    return (true, ra, rb, rc);
  }
  return (false, ra, rb, rc);
}

bool _isTopLeftEdge(e) {
  return e.y < 0 || (e.y == 0 && e.x < 0);
}
