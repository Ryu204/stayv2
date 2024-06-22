import 'package:meta/meta.dart';
import 'package:stayv2/src/graphics/camera.dart';
import 'package:stayv2/src/graphics/color.dart';
import 'package:stayv2/src/graphics/drawable.dart';
import 'package:stayv2/src/graphics/size_check.dart';
import 'package:stayv2/src/graphics/vertex.dart';
import 'package:stayv2/src/graphics/render_state.dart';
import 'package:vector_math/vector_math.dart';
export 'package:stayv2/src/graphics/render_state.dart';

abstract class BaseCanvas extends SizeCheck {
  final camera = Camera.ortho(width: 10, height: 10);

  /// Draw a point in screen coordinate [x],[y]
  ///
  /// [x] and [y] is guranteed to be inside visible area of screen
  ///
  /// User should not call this method
  void drawPoint(double x, double y, Color c);

  /// Draw a line in screen coordinate connecting 2 point [a],[b]
  ///
  /// [a] and [b] is guranteed to be inside visible area of screen
  ///
  /// User should not call this method
  void drawLine(Vector2 a, Vector2 b, Color ca, Color cb);
  void clear({Color color});

  /// Call `super.display()` first to update camera aspect ratio
  @mustCallSuper
  void display() {
    camera.resizeToFit(
      keepHeight: true,
      width: displaySize.x,
      height: displaySize.y,
    );
  }

  void draw(Drawable d, {RenderState? st}) {
    d.drawOn(this, st ?? RenderState.identity());
  }

  void drawVertices(
    List<Vertex> points,
    PrimitiveType type,
    RenderState st, {
    List<int>? ebo,
  }) {
    final mvp = camera.projectAndViewProduct().multiplied(st.transform);
    final (top, left, width, height) = (0.0, 0.0, displaySize.x, displaySize.y);
    final transformed = points.map((v) {
      final ndc = mvp.transformed3(v.position);
      final winSpace = camera.viewportTransform(
          top: top, left: left, width: width, height: height, ndc: ndc);
      return winSpace;
    }).toList();

    if (type == PrimitiveType.points) {
      for (final (i, v) in transformed.indexed) {
        drawPoint(v.x, v.y, points[i].color);
      }
    } else if (type == PrimitiveType.lineLoop && ebo == null) {
      final n = transformed.length;
      if (n > 2) {
        // Draw every lines except the one connecting `n-1` and `0` vertex
        for (var i = 1; i < n; ++i) {
          final (a, b) = (transformed[i - 1], transformed[i]);
          drawLine(
            a.xy,
            b.xy,
            points[i - 1].color,
            points[i].color,
          );
        }
      }
      drawLine(
        transformed.last.xy,
        transformed.first.xy,
        points.last.color,
        points.first.color,
      );
    } else if (type == PrimitiveType.line && ebo != null) {
      final n = ebo.length;
      assert(n.isEven);
      for (var j = 0; j < n; j += 2) {
        final (i, ipp) = (ebo[j], ebo[j + 1]);
        drawLine(
          transformed[i].xy,
          transformed[ipp].xy,
          points[i].color,
          points[ipp].color,
        );
      }
    } else {
      throw UnimplementedError();
    }
  }
}
