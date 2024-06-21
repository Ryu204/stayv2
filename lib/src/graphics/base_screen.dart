import 'package:meta/meta.dart';
import 'package:stayv2/src/graphics/color.dart';
import 'package:stayv2/src/utils/event.dart';
import 'package:stayv2/src/utils/invoker.dart';
import 'package:vector_math/vector_math.dart';

/// Keeps track of display size
abstract class BaseScreen {
  final onSizeChanged = Event<Vector2>();
  final _currentSize = Vector2.zero();
  String? _invokeId;

  /// Returns the screen display size in pixels
  Vector2 queryDisplaySize();
  void display();
  void clear({Color color});

  /// If derived class does not have native resize callback, manual checking
  /// is enabled every [resizeCheckInterval] milliseconds
  BaseScreen({
    required bool hasResizeCallback,
    required double checkSizeInterval,
  }) {
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
    // TODO: Call this eventually
    if (_invokeId != null) {
      invoke.remove(_invokeId!);
    }
  }
}
