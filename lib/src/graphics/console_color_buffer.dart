import 'package:dart_console/dart_console.dart';
import 'package:stayv2/src/graphics/color.dart';
import 'package:vector_math/vector_math.dart';

enum ConsoleSymbol {
  vertical(1),
  horizontal(2),
  swayLeft(4),
  swayRight(8),
  dot(16);

  final int flag;

  const ConsoleSymbol(this.flag);

  static String get(int c) {
    return switch (c) {
      1 => '|',
      2 => '-',
      3 => '+',
      4 => '\\',
      5 => '.',
      6 => '.',
      7 => '.',
      8 => '/',
      9 => '.',
      10 => '.',
      11 => '.',
      12 => 'X',
      13 => '.',
      14 => '.',
      15 => '.',
      16 => '*',
      > 16 && < 32 => get(c - 16),
      _ => ' '
    };
  }
}

class ConsoleCell {
  ConsoleColor bgr;
  int symbols;

  ConsoleCell(this.bgr, this.symbols);

  @override
  bool operator ==(Object other) {
    if (other is ConsoleCell == false) return false;
    final cell = other as ConsoleCell;
    return symbols == cell.symbols && bgr == cell.bgr;
  }

  @override
  int get hashCode => Object.hash(bgr, symbols);
}

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
  final _trueColor = <TrueColorCell>[];
  final _displayDoubleBuffer =
      List.generate(2, (_) => <ConsoleCell>[], growable: false);
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
        (_) => TrueColorCell(Colors.aliceBlue, 0, double.infinity),
      ));
    } else {
      _trueColor.length = count;
    }

    for (final buf in _displayDoubleBuffer) {
      if (buf.length < count) {
        buf.addAll(List.generate(
          count - buf.length,
          (_) => ConsoleCell(ConsoleColor.black, 0),
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
    }
  }

  void set(int iw, int ih, double zBuf, {Color? fg, int symbol = 0}) {
    final cell = _trueColor[ih * _w + iw];
    if (zBuf > cell.zBuffer) return;
    if (fg != null) cell.bgr.setFrom(fg);
    cell.symbols |= symbol;
  }

  /// Returns list of pixel needs to be updated after comparing to the last swap call.
  List<(int iw, int ih, ConsoleColor c, String s)> swap() {
    final res = <(int iw, int ih, ConsoleColor c, String s)>[];
    for (final (i, c) in _trueColor.indexed) {
      final displayCell = _displayDoubleBuffer[_activeDisplayBuffer][i];
      final newColor = closestColorMatch(c.bgr);
      displayCell.bgr = newColor;
      displayCell.symbols = c.symbols;
      final needsUpdate =
          displayCell != _displayDoubleBuffer[1 - _activeDisplayBuffer][i];
      if (needsUpdate || _needRefresh) {
        res.add((i % _w, i ~/ _w, newColor, ConsoleSymbol.get(c.symbols)));
      }
    }
    _activeDisplayBuffer = 1 - _activeDisplayBuffer;
    _needRefresh = false;
    return res;
  }
}
