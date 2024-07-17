import 'dart:collection';

import 'package:stayv2/src/graphics/color.dart';
import 'package:stayv2/src/utils/more_math.dart';
import 'package:vector_math/vector_math.dart';

class TrueColorCell {
  final _layers = <(double, Color)>[];
  Color? _calculated;

  void reset(double zVal, Color c) {
    _layers.length = 0;
    add(zVal, c);
  }

  void add(double zVal, Color c) {
    _layers.add((zVal, c));
    _calculated = null;
  }

  Color calculate() {
    int comparer((double, Color) s, (double, Color) l) {
      return s.$1.compareTo(l.$1);
    }

    if (_calculated != null) return _calculated!.clone();
    assert(_layers.isNotEmpty, 'Did you clear the windows first?');
    _layers.sort(comparer);
    final pixel = _layers.last.$2.rgb * _layers.last.$2.a;
    final n = _layers.length;
    for (var i = n - 2; i >= 0; --i) {
      pixel.setFrom(lerpV3(pixel, _layers[i].$2.rgb, _layers[i].$2.a));
    }
    _calculated = Vector4(pixel.r, pixel.g, pixel.b, 1.0);
    return _calculated!;
  }
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
      List.generate(2, (_) => <TerminalColor>[], growable: false);
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
        (_) => TrueColorCell(),
      ));
    } else {
      _trueColor.length = count;
    }

    for (final buf in _displayDoubleBuffer) {
      if (buf.length < count) {
        buf.addAll(List.generate(
          count - buf.length,
          (_) => TerminalColor('', '', ''),
        ));
      } else {
        buf.length = count;
      }
    }
  }

  void setAll(Color col) {
    for (final i in _trueColor) {
      i.reset(double.infinity, col);
    }
  }

  /// If [iw] or [ih] or [zBuf] is not inside the screen, nothing happens
  void set(int iw, int ih, double zBuf, Color bgr) {
    if (iw < 0 || ih < 0 || iw >= _w || ih >= _h || zBuf < near || zBuf > far) {
      return;
    }
    final cell = _trueColor[ih * _w + iw];
    cell.add(zBuf, bgr);
  }

  /// Returns list of pixel needs to be updated after comparing to the last swap call.
  List<(int iw, int ih, TerminalColor c)> swap() {
    final res = <(int iw, int ih, TerminalColor c)>[];
    for (final (i, c) in _trueColor.indexed) {
      final newColor = getColorString(c.calculate());
      _displayDoubleBuffer[_activeDisplayBuffer][i] = newColor;
      final needsUpdate =
          !newColor.eq(_displayDoubleBuffer[1 - _activeDisplayBuffer][i]);
      if (needsUpdate || _needRefresh) {
        res.add((i % _w, i ~/ _w, newColor));
      }
    }
    _activeDisplayBuffer = 1 - _activeDisplayBuffer;
    _needRefresh = false;
    return res;
  }
}
