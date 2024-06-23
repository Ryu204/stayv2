import 'package:meta/meta.dart';
import 'package:stayv2/src/graphics/console_window.dart';
import 'package:stayv2/src/graphics/cuboid.dart';
import 'package:stayv2/src/graphics/rectangle.dart';
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

  // TODO: remove
  Rectangle rect = Rectangle(w: 2, h: 2)..move(Vector3(3, 1, 0));
  // Rectangle rect2 = Rectangle(w: 1, h: 3)..move(Vector3(2, 2, 0));
  Cuboid cube = Cuboid(w: 1, h: 1, d: 5)..move(Vector3(-1, -1, 0));
  final randomAxis = Vector3(123, 234, 98).normalized();

  void _render(double t) {
    rect.color = Colors.red;
    rect.setRotation(t / 3, axis: Vector3(0, 1, 0));
    // rect2.setRotation(t / 2);
    cube.setRotation(t, axis: randomAxis);
    _window.clear(color: Colors.cyan);
    _window.draw(rect);
    randomAxis.length = 3;
    _window.drawVertices(
      [
        Vertex(Vector3(-1, -1, 0), Colors.aqua),
        Vertex(randomAxis + Vector3(-1, -1, 0), Colors.beige)
      ],
      PrimitiveType.lineLoop,
      RenderState.identity(),
    );
    // _window.draw(rect2);
    _window.draw(cube);
    // _window.drawPoint(1, 1, Colors.black);
    // _window.drawPoint(1, 2, Colors.black);
    // _window.drawPoint(2, 2, Colors.black);
    // _window.drawPoint(2, 1, Colors.black);
    _window.display();
  }

  @mustCallSuper
  void shutdown() {
    _window.shutdown();
  }
}
