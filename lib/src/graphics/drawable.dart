import 'package:stayv2/src/graphics/base_canvas.dart';

abstract class Drawable {
  /// Render the entity on [c] with state [s]
  ///
  /// Implementations can call [drawVertices] on [c]
  void drawOn(BaseCanvas c, RenderState s);
}
