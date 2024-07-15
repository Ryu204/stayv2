import 'dart:math';

import 'package:collection/collection.dart';
import 'package:dart_console/dart_console.dart';
import 'package:stayv2/src/graphics/base_canvas.dart';
import 'package:stayv2/src/graphics/camera.dart';
import 'package:stayv2/src/graphics/color.dart';
import 'package:stayv2/src/graphics/console/ansi.dart';
import 'package:stayv2/src/graphics/console_color_buffer.dart';
import 'package:stayv2/src/graphics/edge_function.dart';
import 'package:stayv2/src/graphics/texture.dart';
import 'package:stayv2/src/utils/more_math.dart';
import 'package:vector_math/vector_math.dart';

/// Perspective division is illustrated well here:
/// [https://www.cs.ucr.edu/~craigs/courses/2020-fall-cs-130/lectures/perspective-correct-interpolation.pdf]

final _eps = 1e-7;

/// Represents a 2D screen with pixels within a window
class ConsoleWindow extends BaseCanvas {
  late ConsoleColorBuffer _colorBuffer;
  final _consoleStdoutBuffer = StringBuffer();
  final _console = Console.scrolling();
  var _needsCleanScreen = true;

  ConsoleWindow() {
    _colorBuffer = ConsoleColorBuffer(near: camera.near, far: camera.far);
    _console.hideCursor();
    onSizeChanged +
        (size) {
          _needsCleanScreen = true;
          _colorBuffer.resize(size.x.floor(), size.y.floor());
          camera.resizeToFit(
            width: displaySize.x,
            height: displaySize.y,
            keepHeight: true,
          );
        };
    startWatchSize(checkSizeInterval: 0.5);
  }

  @override
  Vector2 queryDisplaySize() {
    return Vector2(
      _console.windowWidth.toDouble(),
      _console.windowHeight.toDouble(),
    );
  }

  @override
  clear({Color? color}) {
    _colorBuffer.setAll(color ?? Colors.black);
  }

  @override
  display() {
    if (_needsCleanScreen) {
      _needsCleanScreen = false;
      _console.clearScreen();
    }
    final changes = _colorBuffer.swap();
    _consoleStdoutBuffer.clear();
    for (final (iw, ih, c) in changes) {
      _consoleStdoutBuffer.write(
        '${c.color}${ansiCursorPosition(ih, iw)}${c.character}${c.resetCode}',
      );
    }
    _console.write(_consoleStdoutBuffer);
  }

  @override
  void drawPoint(Vector4 pos, Color c) {
    _colorBuffer.set(
      pos.x.toInt(),
      pos.y.toInt(),
      camera.type == CameraType.perspective ? pos.w : pos.z,
      c,
    );
  }

  /// Bresenham algorithm
  /// Source: https://gist.github.com/bert/1085538#file-plot_line-c
  @override
  void drawLine(Vector4 a, Vector4 b, Color ca, Color cb) {
    final minXy = Vector2([a.x, b.x].min, [a.y, b.y].min);
    final maxXy = Vector2([a.x, b.x].max, [a.y, b.y].max);
    if (minXy.x > displaySize.x - 1 ||
        minXy.y > displaySize.y - 1 ||
        maxXy.x < 0 ||
        maxXy.y < 0) {
      return;
    }
    final length_ = a.xy.distanceTo(b.xy);
    if (length_ < _eps) {
      return;
    }

    var (x0, y0) = (a.x.toInt(), a.y.toInt());
    final (x1, y1) = (b.x.toInt(), b.y.toInt());
    final (dx, sx, dy, sy) = (
      (x1 - x0).abs(),
      x0 < x1 ? 1 : -1,
      (y1 - y0).abs() * -1,
      y0 < y1 ? 1 : -1,
    );
    var err = dx + dy;
    var e2 = 0;
    while (true) {
      final dt =
          sqrt((x0 - a.x) * (x0 - a.x) + (y0 - a.y) * (y0 - a.y)) / length_;
      var (aa, ab) = ((1 - dt) / a.w, dt / b.w);
      final length = aa + ab;
      aa /= length;
      ab /= length;
      _colorBuffer.set(
        x0,
        y0,
        camera.type == CameraType.perspective
            ? a.w * aa + b.w * ab
            : a.z * aa + b.z * ab,
        ca * aa + cb * ab,
      );

      if (x0 == x1 && y0 == y1) break;
      e2 = 2 * err;
      if (e2 >= dy) {
        err += dy;
        x0 += sx;
      }
      if (e2 <= dx) {
        err += dx;
        y0 += sy;
      }
    }
  }

  @override
  void drawTriangle(
    Vector4 a,
    Vector4 b,
    Vector4 c,
    Color ca,
    Color cb,
    Color cc, {
    Texture2d? tex,
    Vector2? texCoordsA,
    Vector2? texCoordsB,
    Vector2? texCoordsC,
  }) {
    // Calculate bounding box of triangle
    final minXy = Vector2([a.x, b.x, c.x].min, [a.y, b.y, c.y].min);
    final maxXy = Vector2([a.x, b.x, c.x].max, [a.y, b.y, c.y].max);
    if (minXy.x >= displaySize.x - 1 ||
        maxXy.x < 0 ||
        minXy.y >= displaySize.y - 1 ||
        maxXy.y < 0) {
      return;
    }
    minXy.x = clamp(minXy.x.floorToDouble(), 0, displaySize.x - 1);
    minXy.y = clamp(minXy.y.floorToDouble(), 0, displaySize.y - 1);
    maxXy.x = clamp(maxXy.x.ceilToDouble(), 0, displaySize.x - 1);
    maxXy.y = clamp(maxXy.y.ceilToDouble(), 0, displaySize.y - 1);

    final area_ = edgeFunction(a.xy, b.xy, c.xy);
    if (area_.abs() < _eps) {
      return;
    }
    // Iterate over each pixel
    for (var px = minXy.x; px <= maxXy.x; ++px) {
      for (var py = minXy.y; py <= maxXy.y; ++py) {
        final center = Vector2(px + 0.5, py + 0.5);
        var (inside, aa_, ab_, ac_) =
            isInsideTriangle(center, a.xy, b.xy, c.xy);
        if (!inside) continue;
        aa_ /= area_;
        ab_ /= area_;
        ac_ /= area_;
        var (aa, ab, ac) = (aa_ / a.w, ab_ / b.w, ac_ / c.w);
        final area = aa + ab + ac;
        aa /= area;
        ab /= area;
        ac /= area;
        final baseColor = ca * aa + cb * ab + cc * ac;
        final texCoord = linearCombV2(
          [texCoordsA!, texCoordsB!, texCoordsC!],
          [aa, ab, ac],
        );
        // TODO: Other blend mode?
        final col =
            tex == null ? baseColor : (baseColor..multiply(tex.get(texCoord)));
        final z = camera.type == CameraType.perspective
            ? a.w * aa + b.w * ab + c.w * ac
            : a.z * aa + b.z * ab + c.z * ac;
        _colorBuffer.set(
          center.x.floor(),
          center.y.floor(),
          z,
          col,
        );
      }
    }
  }

  @override
  void shutdown() {
    super.shutdown();
    _console.showCursor();
  }
}
