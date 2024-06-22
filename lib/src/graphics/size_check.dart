import 'package:meta/meta.dart';
import 'package:stayv2/src/utils/event.dart';
import 'package:stayv2/src/utils/invoker.dart';
import 'package:vector_math/vector_math.dart';

/// Keeps track of display size
mixin SizeCheck {
  final onSizeChanged = Event<Vector2>();
  Vector2? _currentSize = Vector2.zero();
  String? _invokeId;

  /// Returns the screen display size in pixels
  Vector2 queryDisplaySize();

  /// Manual checking is enabled every [resizeCheckInterval] milliseconds
  void startWatchSize({required double checkSizeInterval}) {
    _invokeId = invoke.after(checkSizeInterval, _checkSizeDiff, loop: true);
  }

  Vector2 get displaySize {
    return _currentSize ?? queryDisplaySize();
  }

  _checkSizeDiff() {
    final newSize = queryDisplaySize();
    var willInvoke = false;
    if (_currentSize == null) {
      willInvoke = true;
      _currentSize = newSize;
    } else if (newSize != _currentSize) {
      willInvoke = true;
      _currentSize!.setFrom(newSize);
    }

    if (willInvoke) {
      onSizeChanged.invoke(_currentSize!);
    }
  }

  stopWatchSize() {
    if (_invokeId != null) {
      invoke.remove(_invokeId!);
    }
  }
}
