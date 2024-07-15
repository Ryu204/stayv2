import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:dart_console/dart_console.dart';
import 'package:stayv2/src/graphics/console/ansi.dart';
import 'package:vector_math/vector_math.dart';

typedef Color = Vector4;

enum ColorMode {
  none,
  only16,
  trueColor,
}

ColorMode _detectColorMode() {
  if (Platform.isWindows || Platform.isMacOS) {
    return ColorMode.trueColor;
  }
  final colorterm = Platform.environment['COLORTERM'];
  if (['truecolor', '24bit'].contains(colorterm)) {
    return ColorMode.trueColor;
  }
  final term = Platform.environment['TERM'];
  if (term == null) {
    return ColorMode.none;
  }
  const supportTerms = [
    'xterm',
    'screen',
    'linux',
    'rxvt',
    'vt100',
    'vt220',
    'cygwin',
    'ansi',
    'kitty',
    // TODO: Add more?
  ];
  if (supportTerms.firstWhereOrNull((e) => term.contains(e)) != null) {
    return ColorMode.only16;
  }
  return ColorMode.none;
}

final colorMode = _detectColorMode();

String _convertNoColor(Color c) {
  /// [https://stackoverflow.com/a/74186686]
  const characters =
      r" `.-':_,^=;><+!rc*/z?sLTv)J7(|Fi{C}fI31tlu[neoZ5Yxjya]2ESwqkP6h9d4VpOGbUAKXHm8RD#$Bg0MNWQ%&@";
  final intensity = <double>[]
    // ignore: prefer_inlined_adds
    ..addAll([0, 0.0751, 0.0829, 0.0848, 0.1227, 0.1403, 0.1559, 0.185])
    ..addAll([0.2183, 0.2417, 0.2571, 0.2852, 0.2902, 0.2919, 0.3099, 0.3192])
    ..addAll([0.3232, 0.3294, 0.3384, 0.3609, 0.3619, 0.3667, 0.3737, 0.3747])
    ..addAll([0.3838, 0.3921, 0.396, 0.3984, 0.3993, 0.4075, 0.4091, 0.4101])
    ..addAll([0.42, 0.423, 0.4247, 0.4274, 0.4293, 0.4328, 0.4382, 0.4385])
    ..addAll([0.442, 0.4473, 0.4477, 0.4503, 0.4562, 0.458, 0.461, 0.4638])
    ..addAll([0.4667, 0.4686, 0.4693, 0.4703, 0.4833, 0.4881, 0.4944, 0.4953])
    ..addAll([0.4992, 0.5509, 0.5567, 0.5569, 0.5591, 0.5602, 0.5602, 0.565])
    ..addAll([0.5776, 0.5777, 0.5818, 0.587, 0.5972, 0.5999, 0.6043, 0.6049])
    ..addAll([0.6093, 0.6099, 0.6465, 0.6561, 0.6595, 0.6631, 0.6714, 0.6759])
    ..addAll([0.6809, 0.6816, 0.6925, 0.7039, 0.7086, 0.7235, 0.7302, 0.7332])
    ..addAll([0.7602, 0.7834, 0.8037, 0.9999]);
  assert(
    characters.length == intensity.length,
    '${characters.length} != ${intensity.length}',
  );
  final luminance = (0.299 * c.r + 0.587 * c.g + 0.114 * c.b) * c.a;
  return characters[characters.length -
      1 -
      min(lowerBound(intensity, luminance), characters.length - 1)];
}

String _convert16AnsiColor(Color c) {
  final ansi16Colors = [
    (ConsoleColor.black, Vector4(0, 0, 0, 1)),
    (ConsoleColor.blue, Vector4(0, 0, 0.8, 1)),
    (ConsoleColor.brightBlack, Vector4(0.5, 0.5, 0.5, 1.0)),
    (ConsoleColor.brightBlue, Vector4(0, 0, 1, 1)),
    (ConsoleColor.brightCyan, Vector4(0, 1.0, 1.0, 1.0)),
    (ConsoleColor.brightGreen, Vector4(0, 1, 0, 1)),
    (ConsoleColor.brightMagenta, Vector4(1, 0, 1, 1)),
    (ConsoleColor.brightRed, Vector4(1, 0, 0, 1)),
    (ConsoleColor.brightWhite, Vector4(1, 1, 1, 1)),
    (ConsoleColor.brightYellow, Vector4(1, 1, 0, 1)),
    (ConsoleColor.cyan, Vector4(0, 0.8, 0.8, 1.0)),
    (ConsoleColor.green, Vector4(0, 0.8, 0, 1)),
    (ConsoleColor.magenta, Vector4(0.8, 0, 0.8, 1.0)),
    (ConsoleColor.red, Vector4(0.8, 0, 0, 1)),
    (ConsoleColor.white, Vector4(.9, .9, .9, 1)),
    (ConsoleColor.yellow, Vector4(.8, .8, 0, 1)),
  ];
  var closest = double.infinity;
  var res = ConsoleColor.black;
  for (final i in ansi16Colors) {
    final squared = c.distanceToSquared(i.$2);
    if (squared < closest) {
      res = i.$1;
      closest = squared;
    }
  }
  return res.ansiSetBackgroundColorSequence;
}

String _convertTrueColor(Color c) {
  final r = (c.r * 255).floor();
  final g = (c.g * 255).floor();
  final b = (c.b * 255).floor();

  return '\x1b[48;2;$r;$g;${b}m';
}

class TerminalColor {
  final String color;
  final String character;
  final String resetCode;

  TerminalColor(this.color, this.character, this.resetCode);

  bool eq(TerminalColor other) {
    return color == other.color &&
        character == other.character &&
        resetCode == other.resetCode;
  }
}

/// Returns: color, character, reset code
TerminalColor getColorString(Color c) {
  return switch (colorMode) {
    ColorMode.none => TerminalColor(
        '',
        _convertNoColor(c),
        '',
      ),
    ColorMode.only16 => TerminalColor(
        _convert16AnsiColor(c),
        '=',
        ansiResetColor,
      ),
    ColorMode.trueColor => TerminalColor(
        _convertTrueColor(c),
        ' ',
        ansiResetColor,
      ),
  };
}
