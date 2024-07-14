import 'package:dart_console/dart_console.dart';
import 'package:vector_math/vector_math.dart';

typedef Color = Vector4;

final _colorsMap = [
  (ConsoleColor.black, Vector4(0, 0, 0, 1)),
  (ConsoleColor.blue, Vector4(0, 0, 0.5, 1)),
  (ConsoleColor.brightBlack, Vector4(0.5, 0.5, 0.5, 1.0)),
  (ConsoleColor.brightBlue, Vector4(0, 0, 1, 1)),
  (ConsoleColor.brightCyan, Vector4(0, 1.0, 1.0, 1.0)),
  (ConsoleColor.brightGreen, Vector4(0, 1, 0, 1)),
  (ConsoleColor.brightMagenta, Vector4(1, 0, 1, 1)),
  (ConsoleColor.brightRed, Vector4(1, 0, 0, 1)),
  (ConsoleColor.brightWhite, Vector4(1, 1, 1, 1)),
  (ConsoleColor.cyan, Vector4(0, 0.5, 0.5, 1.0)),
  (ConsoleColor.green, Vector4(0, 0.5, 0, 1)),
  (ConsoleColor.magenta, Vector4(0.5, 0, 0.5, 1.0)),
  (ConsoleColor.red, Vector4(0.5, 0, 0, 1)),
  (ConsoleColor.white, Vector4(.7, .7, .7, 1)),
  (ConsoleColor.yellow, Vector4(.5, .5, 0, 1)),
];

ConsoleColor closestColorMatch(Color c) {
  var closest = double.infinity;
  var res = ConsoleColor.black;
  for (final i in _colorsMap) {
    final squared = c.distanceToSquared(i.$2);
    if (squared < closest) {
      res = i.$1;
      closest = squared;
    }
  }
  return res;
}
