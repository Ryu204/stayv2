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
    this.updateInterval = 0.016,
  }) {
    size.x = width;
    size.y = height;
  }
}

/// Application (executable) running the game
class Application {
  var _isRunning = true;
  Duration _elapsedTime = Duration.zero;
  DateTime _lastTimePoint = DateTime.now();
  final AppConfig _cfg;

  Application(this._cfg) {
    invoke.after(1, () => print('1s'));
    invoke.after(1.5, () => print('1.5s'), loop: true);
    invoke.after(1, () => print('111s'), loop: true);
  }

  void run() {
    _lastTimePoint = DateTime.now();
    while (_isRunning) {
      final newTimePoint = DateTime.now();
      _elapsedTime += newTimePoint.difference(_lastTimePoint);
      _lastTimePoint = newTimePoint;

      while (_elapsedTime.inMilliseconds >=
          Duration.millisecondsPerSecond * _cfg.updateInterval) {
        _elapsedTime -= Duration(
          milliseconds:
              (Duration.millisecondsPerSecond * _cfg.updateInterval).toInt(),
        );

        _update(_cfg.updateInterval);
      }
    }
  }

  void _update(double dt) {
    invoke.advance(dt);
  }
}
