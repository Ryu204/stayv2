import 'package:stayv2/src/graphics/base_canvas.dart';

abstract class Drawable {
  void drawOn(BaseCanvas c, RenderState s);
}
