import 'package:stayv2/src/graphics/base_canvas.dart';
import 'package:stayv2/src/graphics/color.dart';
import 'package:stayv2/src/graphics/drawable.dart';
import 'package:stayv2/src/graphics/transformable.dart';
import 'package:stayv2/src/graphics/vertex.dart';
import 'package:vector_math/vector_math.dart';

class Rectangle extends Transformable implements Drawable {
  final _vertices = List.generate(
    4,
    (_) => Vertex(Vector3.zero(), Colors.white),
    growable: false,
  );
  final _size = Vector2.zero();

  Rectangle({required double w, required double h}) {
    size = Vector2(w, h);
    _vertices[0].texCoords.setValues(0, 0);
    _vertices[1].texCoords.setValues(1, 0);
    _vertices[2].texCoords.setValues(1, 1);
    _vertices[3].texCoords.setValues(0, 1);
  }

  set size(Vector2 val) {
    // 0--w--1
    // |     |
    // h     |
    // |     |
    // 3-----2
    _size.setFrom(val);
    _vertices[0].position.setValues(-val.x / 2, val.y / 2, 0);
    _vertices[1].position.setValues(val.x / 2, val.y / 2, 0);
    _vertices[2].position.setValues(val.x / 2, -val.y / 2, 0);
    _vertices[3].position.setValues(-val.x / 2, -val.y / 2, 0);
  }

  set color(Color c) {
    for (final v in _vertices) {
      v.color.setFrom(c);
    }
    // TODO: remove
    _vertices[0].color.setFrom(Colors.red);
    _vertices[1].color.setFrom(Colors.blue);
    _vertices[2].color.setFrom(Colors.white);
    _vertices[3].color.setFrom(Colors.green);
  }

  @override
  void drawOn(BaseCanvas c, RenderState s) {
    s.transform.multiply(transform);
    c.drawVertices(
      _vertices,
      PrimitiveType.triangle,
      s,
      ebo: [0, 2, 1, 0, 3, 2],
      texture: c.defaultTexture,
    );
  }
}
