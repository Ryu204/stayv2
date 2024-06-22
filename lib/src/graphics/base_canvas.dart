import 'package:stayv2/src/graphics/color.dart';
import 'package:stayv2/src/graphics/drawable.dart';
import 'package:stayv2/src/graphics/render_state.dart';
export 'package:stayv2/src/graphics/render_state.dart';

abstract class BaseCanvas {
  void display();
  void clear({Color color});
  void draw(Drawable d, RenderState st) {}
}
