import 'package:stayv2/src/graphics/base_canvas.dart';
import 'package:stayv2/src/graphics/color.dart';
import 'package:stayv2/src/graphics/drawable.dart';
import 'package:stayv2/src/graphics/transformable.dart';
import 'package:stayv2/src/graphics/vertex.dart';
import 'package:vector_math/vector_math.dart';

class Cuboid extends Transformable implements Drawable {
  final _vertices = List.generate(
    8,
    (_) => Vertex(Vector3.zero(), Colors.white),
    growable: false,
  );
  final _size = Vector3.zero();

  /// Each pair is start and end point of a line
  static final _ebo = [0, 1, 1, 2, 2, 3, 3, 0]
    // ignore: prefer_inlined_adds
    ..addAll([0, 4, 1, 5, 2, 7, 3, 6])
    ..addAll([4, 5, 5, 7, 7, 6, 6, 4]);

  Cuboid({
    required double w,
    required double h,
    required double d,
  }) {
    size = Vector3(w, h, d);
  }

  set size(Vector3 val) {
    //   0-------1
    //  /    d->/|
    // 3--w----2 |
    // |       | |
    // |       h |
    // | 4     | 5
    // |       |/
    // 6-------7
    _size.setFrom(val);
    _vertices[0].position.setValues(-val.x / 2, val.y / 2, val.z / 2);
    _vertices[1].position.setValues(val.x / 2, val.y / 2, val.z / 2);
    _vertices[5].position.setValues(val.x / 2, -val.y / 2, val.z / 2);
    _vertices[4].position.setValues(-val.x / 2, -val.y / 2, val.z / 2);

    _vertices[3].position.setValues(-val.x / 2, val.y / 2, -val.z / 2);
    _vertices[2].position.setValues(val.x / 2, val.y / 2, -val.z / 2);
    _vertices[7].position.setValues(val.x / 2, -val.y / 2, -val.z / 2);
    _vertices[6].position.setValues(-val.x / 2, -val.y / 2, -val.z / 2);
  }

  set color(Color c) {
    for (final v in _vertices) {
      v.color.setFrom(c);
    }
  }

  @override
  void drawOn(BaseCanvas c, RenderState s) {
    s.transform.multiply(transform);
    c.drawVertices(_vertices, PrimitiveType.line, s, ebo: _ebo);
  }
}
