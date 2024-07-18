import 'package:stayv2/src/graphics/base_canvas.dart';
import 'package:stayv2/src/graphics/basic_shape.dart';
import 'package:stayv2/src/graphics/transformable.dart';
import 'package:stayv2/src/graphics/vertex.dart';
import 'package:vector_math/vector_math.dart';

class Rectangle extends Transformable with BasicShape {
  final _size = Vector2.zero();

  Rectangle({required double w, required double h}) {
    vertices_ = List.generate(
      4,
      (_) => Vertex(Vector3.zero(), Colors.white),
      growable: false,
    );
    size = Vector2(w, h);
    vertices_[0].texCoords.setValues(0, 0);
    vertices_[1].texCoords.setValues(1, 0);
    vertices_[2].texCoords.setValues(1, 1);
    vertices_[3].texCoords.setValues(0, 1);
  }

  set size(Vector2 val) {
    /// 0  1
    ///
    /// 3  2
    _size.setFrom(val);
    vertices_[0].position.setValues(-val.x / 2, val.y / 2, 0);
    vertices_[1].position.setValues(val.x / 2, val.y / 2, 0);
    vertices_[2].position.setValues(val.x / 2, -val.y / 2, 0);
    vertices_[3].position.setValues(-val.x / 2, -val.y / 2, 0);
  }

  @override
  void drawOn(BaseCanvas c, RenderState s) {
    s.transform.multiply(transform);
    s.texture = texture_;
    c.drawVertices(
      vertices_,
      PrimitiveType.triangle,
      s,
      ebo: [0, 2, 1, 0, 3, 2],
    );
  }
}
