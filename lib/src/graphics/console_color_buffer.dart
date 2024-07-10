import 'package:dart_console/dart_console.dart';
import 'package:stayv2/src/graphics/color.dart';
import 'package:vector_math/vector_math.dart';

class TrueColorCell {
  Color bgr;
  int symbols;
  double zBuffer;

  TrueColorCell(this.bgr, this.symbols, this.zBuffer);
}

/// Keeps track of colors on the screen
///
/// Including real game colors and indexed ones of console
class ConsoleColorBuffer {
  var _w = 0;
  var _h = 0;
  double near = 0.1;
  double far = 100;
  final _trueColor = <TrueColorCell>[];
  final _displayDoubleBuffer =
      List.generate(2, (_) => <ConsoleColor>[], growable: false);
  var _activeDisplayBuffer = 0;
  var _needRefresh = true;

  ConsoleColorBuffer({required this.near, required this.far});

  void resize(int w, int h) {
    _needRefresh = true;
    _w = w;
    _h = h;
    final count = _w * _h;

    if (_trueColor.length < count) {
      _trueColor.addAll(List.generate(
        count - _trueColor.length,
        (_) => TrueColorCell(Colors.aliceBlue, 0, double.infinity),
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
      i.bgr.setFrom(col);
      i.symbols = 0;
      i.zBuffer = double.infinity;
    }
  }

  /// If [iw] or [ih] or [zBuf] is not inside the screen, nothing happens
  void set(int iw, int ih, double zBuf, Color bgr) {
    if (iw < 0 || ih < 0 || iw >= _w || ih >= _h || zBuf < near || zBuf > far) {
      return;
    }
    final cell = _trueColor[ih * _w + iw];
    if (zBuf > cell.zBuffer) return;
    cell.zBuffer = zBuf;
    cell.bgr.setFrom(bgr);
  }

  /// Returns list of pixel needs to be updated after comparing to the last swap call.
  List<(int iw, int ih, ConsoleColor c)> swap() {
    final res = <(int iw, int ih, ConsoleColor c)>[];
    for (final (i, c) in _trueColor.indexed) {
      final newColor = closestColorMatch(c.bgr);
      _displayDoubleBuffer[_activeDisplayBuffer][i] = newColor;
      final needsUpdate = newColor.index !=
          _displayDoubleBuffer[1 - _activeDisplayBuffer][i].index;
      if (needsUpdate || _needRefresh) {
        res.add((i % _w, i ~/ _w, newColor));
      }
    }
    _activeDisplayBuffer = 1 - _activeDisplayBuffer;
    _needRefresh = false;
    return res;
  }
}
