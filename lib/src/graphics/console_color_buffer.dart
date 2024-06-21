import 'package:dart_console/dart_console.dart';
import 'package:stayv2/src/graphics/color.dart';
import 'package:vector_math/vector_math.dart';

/// Keeps track of colors on the screen
///
/// Including real game colors and indexed ones of console
class ConsoleColorBuffer {
  var _w = 0;
  var _h = 0;
  final _trueColor = <Color>[];
  final _displayDoubleBuffer =
      List.generate(2, (_) => <ConsoleColor>[], growable: false);
  var _activeDisplayBuffer = 0;
  var _needRefresh = true;

  void resize(int w, int h) {
    _needRefresh = true;
    _w = w;
    _h = h;
    final count = _w * _h;

    if (_trueColor.length < count) {
      _trueColor.addAll(List.generate(
        count - _trueColor.length,
        (_) => Colors.aliceBlue,
      ));
    } else {
      _trueColor.length = count;
    }

    for (final buf in _displayDoubleBuffer) {
      if (buf.length < count) {
        buf.addAll(List.generate(
          count - buf.length,
          (_) => ConsoleColor.black,
        ));
      } else {
        buf.length = count;
      }
    }
  }

  void setAll(Color col) {
    for (final i in _trueColor) {
      i.setFrom(col);
    }
  }

  void set(int iw, int ih, Color c) {
    _trueColor[ih * _w + iw].setFrom(c);
  }

  /// Returns list of pixel needs to be updated after comparing to the last swap call.
  List<(int iw, int ih, ConsoleColor c)> swap() {
    final res = <(int iw, int ih, ConsoleColor c)>[];
    for (final (i, c) in _trueColor.indexed) {
      final newColor = closestColorMatch(c);
      _displayDoubleBuffer[_activeDisplayBuffer][i] = newColor;
      final needsUpdate =
          newColor != _displayDoubleBuffer[1 - _activeDisplayBuffer][i];
      if (needsUpdate || _needRefresh) {
        res.add((i % _w, i ~/ _w, newColor));
      }
    }
    _activeDisplayBuffer = 1 - _activeDisplayBuffer;
    _needRefresh = false;
    return res;
  }
}
