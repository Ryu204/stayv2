import 'package:stayv2/src/graphics/color.dart';
import 'package:meta/meta.dart';
import 'package:stayv2/src/utils/event.dart';
import 'package:stayv2/src/utils/invoker.dart';
import 'package:vector_math/vector_math.dart';

/// Keeps track of display size
abstract class PhysicalScreen {
  final onSizeChanged = Event<Vector2>();
  var _currentSize = Vector2.zero();
  String? _invokeId;

  Vector2 queryDisplaySize();

  /// If derived class does not have native resize callback, manual checking
  /// is enabled every [resizeCheckInterval] milliseconds
  PhysicalScreen({
    hasResizeCallback = false,
    double checkSizeInterval = 0.5,
  }) {
    _currentSize = queryDisplaySize();
    if (!hasResizeCallback) {
      _invokeId = invoke.after(checkSizeInterval, _checkSizeDiff, loop: true);
    }
  }

  Vector2 get displaySize {
    return _currentSize;
  }

  _checkSizeDiff() {
    final newSize = queryDisplaySize();
    if (newSize != _currentSize) {
      _currentSize.setFrom(newSize);
      onSizeChanged.invoke(_currentSize);
    }
  }

  @mustCallSuper
  shutdown() {
    if (_invokeId != null) {
      invoke.remove(_invokeId!);
    }
  }
}

/// Represents a 2D screen with pixels within a window.]
abstract class Screen extends PhysicalScreen {
  /// Use 2 buffers to enable double buffering
  final _colorBuffers = List.filled(2, <Color>[], growable: false);
  var _activeBuffer = 0;

  clear(Color color) {
    for (final i in _colorBuffers[_activeBuffer]) {
      i.setFrom(color);
    }
  }

  set(int w, int h, Color color) {
    assert(w < displaySize.x && h < displaySize.y, 'Invalid pixel access');
    _colorBuffers[_activeBuffer][h * displaySize.x.toInt() + w].setFrom(color);
  }

  @mustCallSuper
  display() {
    _activeBuffer = (_activeBuffer + 1) % 2;
  }
}
