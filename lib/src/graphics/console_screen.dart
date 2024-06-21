import 'package:dart_console/dart_console.dart';
import 'package:stayv2/src/graphics/color.dart';
import 'package:stayv2/src/graphics/base_screen.dart';
import 'package:stayv2/src/graphics/console_color_buffer.dart';
import 'package:vector_math/vector_math.dart';

/// Represents a 2D screen with pixels within a window
class ConsoleScreen extends BaseScreen {
  final _colorBuffer = ConsoleColorBuffer();
  final _console = Console();

  ConsoleScreen({super.checkSizeInterval = 0.5})
      : super(hasResizeCallback: false) {
    onSizeChanged +
        (size) {
          _colorBuffer.resize(size.x.toInt(), size.y.toInt());
        };
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
}
