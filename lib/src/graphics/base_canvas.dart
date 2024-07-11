import 'dart:math';

import 'package:stayv2/src/graphics/camera.dart';
import 'package:stayv2/src/graphics/clipping.dart';
import 'package:stayv2/src/graphics/color.dart';
import 'package:stayv2/src/graphics/drawable.dart';
import 'package:stayv2/src/graphics/size_check.dart';
import 'package:stayv2/src/graphics/vertex.dart';
import 'package:stayv2/src/graphics/render_state.dart';
import 'package:stayv2/src/utils/more_math.dart';
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

  void drawPoint(Vector4 pos, Color c);
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
    /// We copy [ebo] to modify it in subsequence calculations
    List<int> ebo_;
    if (ebo != null) {
      ebo_ = List.from(ebo);
    } else {
      ebo_ = List.generate(points.length, (i) => i);
    }

    /// [ebo_] will index these 2 lists by negative index
    List<Vertex> addedVertices = [];
    List<Vector4> addedHomoCoords = [];

    List<Vector4> homoCoords = [];

    Vertex pointAt(int id) {
      return id >= 0 ? points[id] : addedVertices[-id - 1];
    }

    Vector4 homoCoordAt(int id) {
      return id >= 0 ? homoCoords[id] : addedHomoCoords[-id - 1];
    }

    void clip() {
      switch (type) {
        case PrimitiveType.point:
          ebo_.retainWhere((i) => pointClip(homoCoords[i]));
          break;
        case PrimitiveType.line:
          for (var i = 0; i + 1 < ebo_.length;) {
            final (tf0, tf1, p0, p1) = (
              homoCoords[ebo_[i]],
              homoCoords[ebo_[i + 1]],
              points[ebo_[i]],
              points[ebo_[i + 1]],
            );
            final (shouldDraw, t1, t2) = lineClip(tf0, tf1);
            if (!shouldDraw) {
              ebo_.removeRange(i, i + 2);
              continue;
            }
            if (t1 > epsilon) {
              addedVertices
                  .add(Vertex(Vector3.zero(), lerpV4(p0.color, p1.color, t1)));
              addedHomoCoords.add(lerpV4(tf0, tf1, t1));
              ebo_[i] = -addedVertices.length;
            }
            if (t2 < 1.0 - epsilon) {
              addedVertices
                  .add(Vertex(Vector3.zero(), lerpV4(p0.color, p1.color, t2)));
              addedHomoCoords.add(lerpV4(tf0, tf1, t2));
              ebo_[i + 1] = -addedVertices.length;
            }
            i += 2;
          }
          break;
        default:
        // TODO: add more clipping
      }
    }

    final mvp = camera.projectAndViewProduct().multiplied(st.transform);
    final (top, left, width, height) = (0.0, 0.0, displaySize.x, displaySize.y);

    homoCoords = points.map((v) {
      final position = Vector4(v.position.x, v.position.y, v.position.z, 1);
      mvp.transform(position);
      return position;
    }).toList();
    clip();

    /// convert homogeneous coord to screen space coord
    void convertToScreenSpace(Vector4 v) {
      v.x /= v.w;
      v.y /= v.w;
      v.z /= v.w;
      v.setFrom(camera.viewportTransform(
        top: top,
        left: left,
        width: width,
        height: height,
        ndc: v.clone(),
      ));
    }

    homoCoords.forEach(convertToScreenSpace);
    addedHomoCoords.forEach(convertToScreenSpace);

    if (type == PrimitiveType.point) {
      for (final i in ebo_) {
        drawPoint(homoCoordAt(i), pointAt(i).color);
      }
    } else if (type == PrimitiveType.lineLoop) {
      final n = ebo_.length;
      assert(n >= 3, 'Cannot create line loop with < 3 vertices');
      // Draw every lines except the one connecting `n-1` and `0` vertex
      for (var i = 1; i < n; ++i) {
        final (id, idpp) = (ebo_[i - 1], ebo_[i]);
        drawLine(
          homoCoordAt(id),
          homoCoordAt(idpp),
          pointAt(id).color,
          pointAt(idpp).color,
        );
      }
      drawLine(
        homoCoordAt(ebo_.last),
        homoCoordAt(ebo_.first),
        pointAt(ebo_.last).color,
        pointAt(ebo_.first).color,
      );
    } else if (type == PrimitiveType.line) {
      final n = ebo_.length;
      assert(n.isEven, 'Cannot build lines with odd number of vertices');
      for (var j = 0; j < n; j += 2) {
        final (i, ipp) = (ebo_[j], ebo_[j + 1]);
        drawLine(
          homoCoordAt(i),
          homoCoordAt(ipp),
          pointAt(i).color,
          pointAt(ipp).color,
        );
      }
    } else if (type == PrimitiveType.triangle) {
      final n = ebo_.length;
      assert(n % 3 == 0, 'Cannot build triangles with [n % 3 != 0]');
      for (var j = 0; j < n; j += 3) {
        final [a, b, c] = [j, j + 1, j + 2]
            .map((i) => (
                  homoCoordAt(ebo_[i]),
                  pointAt(ebo_[i]),
                ))
            .toList();
        drawTriangle(a.$1, b.$1, c.$1, a.$2.color, b.$2.color, c.$2.color);
      }
    } else {
      throw UnimplementedError();
    }
  }
}
