import 'package:stayv2/src/utils/event.dart';
import 'package:stayv2/src/utils/invoker.dart';
import 'package:vector_math/vector_math.dart';

/// Keeps track of display size
mixin SizeCheck {
  final onSizeChanged = Event<Vector2>();
  final _currentSize = Vector2.zero();
  String? _invokeId;

  /// Returns the screen display size in pixels
  Vector2 queryDisplaySize();

  /// Manual checking is enabled every [resizeCheckInterval] milliseconds
  void startWatchSize({required double checkSizeInterval}) {
    _checkSizeDiff();
    _invokeId = invoke.after(checkSizeInterval, _checkSizeDiff, loop: true);
  }

  Vector2 get displaySize {
    return _currentSize;
  }

  void _checkSizeDiff() {
    final newSize = queryDisplaySize();
    if (newSize != _currentSize) {
      _currentSize.setFrom(newSize);
      onSizeChanged.invoke(_currentSize);
    }
  }

  stopWatchSize() {
    if (_invokeId != null) {
      invoke.remove(_invokeId!);
    }
  }
}
