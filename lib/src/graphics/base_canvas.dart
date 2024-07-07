import 'dart:math';

import 'package:stayv2/src/graphics/camera.dart';
import 'package:stayv2/src/graphics/color.dart';
import 'package:stayv2/src/graphics/drawable.dart';
import 'package:stayv2/src/graphics/size_check.dart';
import 'package:stayv2/src/graphics/vertex.dart';
import 'package:stayv2/src/graphics/render_state.dart';
import 'package:vector_math/vector_math.dart';
export 'package:stayv2/src/graphics/render_state.dart';

abstract class BaseCanvas extends SizeCheck {
  final camera = Camera.perspective(
    width: 10,
    height: 10,
    fovYRadians: pi / 3,
    far: 1000,
    near: 3,
  )
    ..setRotation(pi, axis: Vector3(0, 1, 0))
    ..move(Vector3(0, 0, -6));
  // final camera = Camera.ortho(width: 10, height: 10, far: 100)
  //   ..setRotation(pi, axis: Vector3(0, 1, 0))
  //   ..move(Vector3(0, 0, -1));

  void drawPoint(Vector3 pos, Color c);
  void drawLine(Vector4 a, Vector4 b, Color ca, Color cb);
  void drawTriangle(
      Vector4 a, Vector4 b, Vector4 c, Color ca, Color cb, Color cc);
  void clear({Color color});
  void display();

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
      final position = Vector4(v.position.x, v.position.y, v.position.z, 1);
      mvp.transform(position);
      position.x /= position.w;
      position.y /= position.w;
      position.z /= position.w;
      final winSpace = camera.viewportTransform(
        top: top,
        left: left,
        width: width,
        height: height,
        ndc: position,
      );
      return winSpace;
    }).toList();

    if (type == PrimitiveType.point) {
      for (final (i, v) in transformed.indexed) {
        drawPoint(v.xyz, points[i].color);
      }
    } else if (type == PrimitiveType.lineLoop && ebo == null) {
      final n = transformed.length;
      if (n > 2) {
        // Draw every lines except the one connecting `n-1` and `0` vertex
        for (var i = 1; i < n; ++i) {
          final (a, b) = (transformed[i - 1], transformed[i]);
          drawLine(
            a,
            b,
            points[i - 1].color,
            points[i].color,
          );
        }
      }
      drawLine(
        transformed.last,
        transformed.first,
        points.last.color,
        points.first.color,
      );
    } else if (type == PrimitiveType.line && ebo != null) {
      final n = ebo.length;
      assert(n.isEven);
      for (var j = 0; j < n; j += 2) {
        final (i, ipp) = (ebo[j], ebo[j + 1]);
        drawLine(
          transformed[i],
          transformed[ipp],
          points[i].color,
          points[ipp].color,
        );
      }
    } else if (type == PrimitiveType.triangle && ebo != null) {
      final n = ebo.length;
      assert(n % 3 == 0);
      for (var j = 0; j < n; j += 3) {
        final [a, b, c] = [j, j + 1, j + 2]
            .map((i) => (
                  transformed[ebo[i]],
                  points[ebo[i]],
                ))
            .toList();
        drawTriangle(a.$1, b.$1, c.$1, a.$2.color, b.$2.color, c.$2.color);
      }
    } else {
      throw UnimplementedError();
    }
  }
}
