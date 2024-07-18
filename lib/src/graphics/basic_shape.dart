import 'package:meta/meta.dart';
import 'package:stayv2/src/graphics/color.dart';
import 'package:stayv2/src/graphics/drawable.dart';
import 'package:stayv2/src/graphics/texture.dart';
import 'package:stayv2/src/graphics/vertex.dart';

mixin BasicShape implements Drawable {
  @protected
  late List<Vertex> vertices_;
  @protected
  Texture2d? texture_;

  set color(Color c) {
    for (final v in vertices_) {
      v.color.setFrom(c);
    }
  }

  void setRandomColor() {
    for (final v in vertices_) {
      v.color.setFrom(Color.random()..a = 1);
    }
  }

  set texture(Texture2d? t) {
    texture_ = t;
  }
}
