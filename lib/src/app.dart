import 'package:meta/meta.dart';
import 'package:stayv2/src/graphics/console_window.dart';
import 'package:stayv2/src/graphics/render_state.dart';
import 'package:stayv2/src/graphics/vertex.dart';
import 'package:stayv2/src/utils/invoker.dart';
import 'package:vector_math/vector_math.dart';

/// Application configuration
class AppConfig {
  Vector2 size = Vector2.zero();

  /// Number of seconds between each logic update
  double updateInterval;

  AppConfig({
    double width = 100,
    double height = 40,
    this.updateInterval = 1 / 60,
  }) {
    size.x = width;
    size.y = height;
  }
}

/// Application (executable) running the game
class Application {
  var _isRunning = true;
  final _stopwatch = Stopwatch();
  final AppConfig _cfg;
  final _window = ConsoleWindow();

  Application(this._cfg);

  void run() {
    _stopwatch.start();
    var elapsedTime = 0.0;
    var unresolvedTime = 0.0;
    var hasNewContent = true;

    while (_isRunning) {
      final newElapsedTime =
          _stopwatch.elapsedMicroseconds / Duration.microsecondsPerSecond;
      unresolvedTime += newElapsedTime - elapsedTime;
      elapsedTime = newElapsedTime;

      while (unresolvedTime >= _cfg.updateInterval) {
        unresolvedTime -= _cfg.updateInterval;
        _update(_cfg.updateInterval);
        hasNewContent = true;
      }

      if (hasNewContent) {
        _render(elapsedTime);
        hasNewContent = false;
      }
    }

    shutdown();
  }

  void _update(double dt) {
    invoke.advance(dt);
  }

  void _render(double t) {
    _window.clear(color: Colors.cyan);
    _window.display();
  }

  @mustCallSuper
  void shutdown() {
    _window.shutdown();
  }
}
