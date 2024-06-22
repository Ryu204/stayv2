import 'package:dart_console/dart_console.dart';
import 'package:meta/meta.dart';
import 'package:stayv2/src/graphics/base_canvas.dart';
import 'package:stayv2/src/graphics/color.dart';
import 'package:stayv2/src/graphics/size_check.dart';
import 'package:stayv2/src/graphics/console_color_buffer.dart';
import 'package:vector_math/vector_math.dart';

/// Represents a 2D screen with pixels within a window
class ConsoleWindow with BaseCanvas, SizeCheck {
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
    final changes = _colorBuffer.swap();
    for (final (iw, ih, c) in changes) {
      _console.cursorPosition = Coordinate(ih, iw);
      _console.setBackgroundColor(c);
      _console.write(' ');
    }
  }

  @override
  void drawPoint(double x, double y, Color c) {
    _colorBuffer.set(x.toInt(), y.toInt(), c);
  }

  @mustCallSuper
  void shutdown() {
    stopWatchSize();
    _console.showCursor();
  }
}
