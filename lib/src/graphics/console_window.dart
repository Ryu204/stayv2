import 'package:collection/collection.dart';
import 'package:dart_console/dart_console.dart';
import 'package:stayv2/src/graphics/base_canvas.dart';
import 'package:stayv2/src/graphics/color.dart';
import 'package:stayv2/src/graphics/console/ansi.dart';
import 'package:stayv2/src/graphics/console_color_buffer.dart';
import 'package:stayv2/src/graphics/edge_function.dart';
import 'package:stayv2/src/utils/more_math.dart';
import 'package:vector_math/vector_math.dart';

final _eps = 1e-7;

/// Represents a 2D screen with pixels within a window
class ConsoleWindow extends BaseCanvas {
  final _colorBuffer = ConsoleColorBuffer();
  final _consoleStdoutBuffer = StringBuffer();
  final _console = Console.scrolling();
  var _needsCleanScreen = true;

  ConsoleWindow() {
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
    for (final (iw, ih, c, s) in changes) {
      _consoleStdoutBuffer.writeAll([
        ansiCursorPosition(ih, iw),
        c.ansiSetBackgroundColorSequence,
        s,
      ]);
    }
    _console.write(_consoleStdoutBuffer);
  }

  @override
  void drawPoint(Vector3 pos, Color c) {
    _colorBuffer.set(pos.x.toInt(), pos.y.toInt(), pos.x, fg: c);
  }

  /// Bresenham algorithm
  /// Source: https://gist.github.com/bert/1085538#file-plot_line-c
  @override
  void drawLine(Vector3 a, Vector3 b, Color ca, Color cb) {
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
    int cx = 0, cy = 0;
    final length = a.xy.distanceTo(b.xy);
    while (true) {
      var symbol = cx == 0
          ? (cy == 0 ? ConsoleSymbol.dot : ConsoleSymbol.vertical)
          : (cy == 0
              ? ConsoleSymbol.horizontal
              : (cx * cy > 0
                  ? ConsoleSymbol.swayLeft
                  : ConsoleSymbol.swayRight));
      final dt =
          Vector2(x0.toDouble(), y0.toDouble()).distanceTo(a.xy) / length;
      _colorBuffer.set(
        x0,
        y0,
        lerp(a.z, b.z, dt),
        fg: lerpV4(ca, cb, dt),
        symbol: symbol.flag,
      );
      cx = cy = 0;

      if (x0 == x1 && y0 == y1) break;
      e2 = 2 * err;
      if (e2 >= dy) {
        err += dy;
        x0 += sx;
        cx = sx;
      }
      if (e2 <= dx) {
        err += dx;
        y0 += sy;
        cy = sy;
      }
    }
  }

  @override
  void drawTriangle(
    Vector3 a,
    Vector3 b,
    Vector3 c,
    Color ca,
    Color cb,
    Color cc,
  ) {
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

    final w = edgeFunction(a.xy, b.xy, c.xy);
    if (w.abs() < _eps) {
      return;
    }
    // Iterate over each pixel
    for (var px = minXy.x; px <= maxXy.x; ++px) {
      for (var py = minXy.y; py <= maxXy.y; ++py) {
        final center = Vector2(px + 0.5, py + 0.5);
        var (inside, wa, wb, wc) = isInsideTriangle(center, a.xy, b.xy, c.xy);
        wa /= w;
        wb /= w;
        wc /= w;
        if (!inside) continue;
        final col = ca * wa + cb * wb + cc * wc;
        _colorBuffer.set(
          center.x.floor(),
          center.y.floor(),
          a.z * wa + b.z * wb + c.z * wc,
          fg: col,
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
