import 'package:dart_console/dart_console.dart';
import 'package:stayv2/src/graphics/base_canvas.dart';
import 'package:stayv2/src/graphics/color.dart';
import 'package:stayv2/src/graphics/console_color_buffer.dart';
import 'package:vector_math/vector_math.dart';

/// Represents a 2D screen with pixels within a window
class ConsoleWindow extends BaseCanvas {
  final _colorBuffer = ConsoleColorBuffer();
  final _console = Console();

  ConsoleWindow() {
    _console.hideCursor();
    onSizeChanged +
        (size) {
          _colorBuffer.resize(size.x.toInt(), size.y.toInt());
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
    super.display();
    final changes = _colorBuffer.swap();
    for (final (iw, ih, c, s) in changes) {
      _console.cursorPosition = Coordinate(ih, iw);
      _console.setBackgroundColor(c);
      _console.write(s);
    }
  }

  @override
  void drawPoint(double x, double y, Color c) {
    _colorBuffer.set(x.toInt(), y.toInt(), fg: c);
  }

  /// Source: https://gist.github.com/bert/1085538#file-plot_line-c
  @override
  void drawLine(Vector2 a, Vector2 b, Color ca, Color cb) {
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
    while (true) {
      var symbol = cx == 0
          ? (cy == 0 ? ConsoleSymbol.dot : ConsoleSymbol.vertical)
          : (cy == 0
              ? ConsoleSymbol.horizontal
              : (cx * cy > 0
                  ? ConsoleSymbol.swayLeft
                  : ConsoleSymbol.swayRight));
      _colorBuffer.set(x0, y0, symbol: symbol.flag);
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
  void shutdown() {
    super.shutdown();
    _console.showCursor();
  }
}
