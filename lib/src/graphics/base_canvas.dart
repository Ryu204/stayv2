import 'package:stayv2/src/graphics/camera.dart';
import 'package:stayv2/src/graphics/color.dart';
import 'package:stayv2/src/graphics/drawable.dart';
import 'package:stayv2/src/graphics/vertex.dart';
import 'package:stayv2/src/graphics/render_state.dart';
import 'package:vector_math/vector_math.dart';
export 'package:stayv2/src/graphics/render_state.dart';

mixin BaseCanvas {
  final camera = Camera.ortho(width: 10, height: 10);

  Vector2 get displaySize;

  /// Draw a point in screen coordinate [x],[y]
  ///
  /// [x] and [y] is guranteed to be inside visible area of screen
  ///
  /// User should not call this method
  void drawPoint(double x, double y, Color c);
  void display();
  void clear({Color color});

  void draw(Drawable d, {RenderState? st}) {
    d.drawOn(this, st ?? RenderState.identity());
  }

  void drawVertices(List<Vertex> points, PrimitiveType type, RenderState st) {
    final mvp = camera.projectAndViewProduct().multiplied(st.transform);
    final (top, left, width, height) = (0.0, 0.0, displaySize.x, displaySize.y);
    final transformed = points.map((v) {
      final ndc = mvp.transform3(v.position);
      final winSpace = camera.viewportTransform(
          top: top, left: left, width: width, height: height, ndc: ndc);
      return winSpace;
    }).toList();
    for (final (i, v) in transformed.indexed) {
      drawPoint(v.x, v.y, points[i].color);
    }
  }
}
