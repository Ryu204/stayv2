import 'package:stayv2/src/graphics/base_canvas.dart';
import 'package:stayv2/src/graphics/basic_shape.dart';
import 'package:stayv2/src/graphics/texture.dart';
import 'package:stayv2/src/graphics/transformable.dart';
import 'package:stayv2/src/graphics/vertex.dart';
import 'package:vector_math/vector_math.dart';

enum CuboidUvType {
  cross,
  separate,
}

class Cuboid extends Transformable with BasicShape {
  final _size = Vector3.zero();
  Texture2d? _texture;

  static final _ebo = [0, 2, 1, 0, 3, 2]
    // ignore: prefer_inlined_adds
    ..addAll([4, 5, 6, 4, 6, 7])
    ..addAll([8, 9, 10, 8, 10, 11])
    ..addAll([12, 14, 13, 12, 15, 14])
    ..addAll([17, 16, 19, 17, 19, 18])
    ..addAll([21, 23, 20, 21, 22, 23]);

  Cuboid({
    required double w,
    required double h,
    required double d,
    CuboidUvType uvType = CuboidUvType.separate,
  }) {
    vertices_ = List.generate(
      24,
      (_) => Vertex(Vector3.zero(), Colors.white),
      growable: false,
    );
    size = Vector3(w, h, d);
    _uvUnwrap(uvType);
  }

  void _uvUnwrap(CuboidUvType t) {
    switch (t) {
      case CuboidUvType.cross:
        //     20 23
        //     21 22
        // 1 2 13 14 10 9 6 5
        // 0 3 12 15 11 8 7 4
        //     17 18
        //     16 19

        // Top
        vertices_[0].texCoords.setValues(0 / 4, 2 / 3);
        vertices_[1].texCoords.setValues(0 / 4, 1 / 3);
        vertices_[2].texCoords.setValues(1 / 4, 1 / 3);
        vertices_[3].texCoords.setValues(1 / 4, 2 / 3);

        // Front
        vertices_[12].texCoords.setFrom(vertices_[3].texCoords);
        vertices_[13].texCoords.setFrom(vertices_[2].texCoords);
        vertices_[14].texCoords.setValues(2 / 4, 1 / 3);
        vertices_[15].texCoords.setValues(2 / 4, 2 / 3);

        // Bottom
        vertices_[8].texCoords.setValues(3 / 4, 2 / 3);
        vertices_[9].texCoords.setValues(3 / 4, 1 / 3);
        vertices_[10].texCoords.setFrom(vertices_[14].texCoords);
        vertices_[11].texCoords.setFrom(vertices_[15].texCoords);

        // Back
        vertices_[4].texCoords.setValues(4 / 4, 2 / 3);
        vertices_[5].texCoords.setValues(4 / 4, 1 / 3);
        vertices_[6].texCoords.setFrom(vertices_[9].texCoords);
        vertices_[7].texCoords.setFrom(vertices_[8].texCoords);

        // Left
        vertices_[16].texCoords.setValues(1 / 4, 3 / 3);
        vertices_[17].texCoords.setFrom(vertices_[12].texCoords);
        vertices_[18].texCoords.setFrom(vertices_[15].texCoords);
        vertices_[19].texCoords.setValues(2 / 4, 3 / 3);

        // Right
        vertices_[20].texCoords.setValues(1 / 4, 0 / 3);
        vertices_[21].texCoords.setFrom(vertices_[13].texCoords);
        vertices_[22].texCoords.setFrom(vertices_[14].texCoords);
        vertices_[23].texCoords.setValues(2 / 4, 0 / 3);
        break;
      case CuboidUvType.separate:
        for (final i in [0, 7, 11, 12, 21, 16]) {
          vertices_[i].texCoords.setValues(0, 0);
        }
        for (final i in [1, 6, 10, 13, 20, 17]) {
          vertices_[i].texCoords.setValues(1, 0);
        }
        for (final i in [2, 5, 9, 14, 23, 18]) {
          vertices_[i].texCoords.setValues(1, 1);
        }
        for (final i in [3, 4, 8, 15, 22, 19]) {
          vertices_[i].texCoords.setValues(0, 1);
        }
        break;
    }
  }

  set size(Vector3 val) {
    //   04(16)-------------------15(20)
    //  /                     d->/|
    // 3(12)(17)--w-----(21)(13)2 |
    // |                        | |
    // |                      h | |
    // | 78(19)                 | 69(23)
    // |                        |/
    // (11)(15)(18)-----(22)(14)(10)
    _size.setFrom(val);
    vertices_[0].position.setValues(-val.x / 2, val.y / 2, val.z / 2);
    vertices_[4].position.setFrom(vertices_[0].position);
    vertices_[16].position.setFrom(vertices_[0].position);
    vertices_[1].position.setValues(val.x / 2, val.y / 2, val.z / 2);
    vertices_[5].position.setFrom(vertices_[1].position);
    vertices_[20].position.setFrom(vertices_[1].position);
    vertices_[2].position.setValues(val.x / 2, val.y / 2, -val.z / 2);
    vertices_[13].position.setFrom(vertices_[2].position);
    vertices_[21].position.setFrom(vertices_[2].position);
    vertices_[3].position.setValues(-val.x / 2, val.y / 2, -val.z / 2);
    vertices_[12].position.setFrom(vertices_[3].position);
    vertices_[17].position.setFrom(vertices_[3].position);
    vertices_[8].position.setValues(-val.x / 2, -val.y / 2, val.z / 2);
    vertices_[7].position.setFrom(vertices_[8].position);
    vertices_[19].position.setFrom(vertices_[8].position);
    vertices_[9].position.setValues(val.x / 2, -val.y / 2, val.z / 2);
    vertices_[6].position.setFrom(vertices_[9].position);
    vertices_[23].position.setFrom(vertices_[9].position);
    vertices_[10].position.setValues(val.x / 2, -val.y / 2, -val.z / 2);
    vertices_[22].position.setFrom(vertices_[10].position);
    vertices_[14].position.setFrom(vertices_[10].position);
    vertices_[11].position.setValues(-val.x / 2, -val.y / 2, -val.z / 2);
    vertices_[15].position.setFrom(vertices_[11].position);
    vertices_[18].position.setFrom(vertices_[11].position);
  }

  @override
  void drawOn(BaseCanvas c, RenderState s) {
    s.transform.multiply(transform);
    s.texture = _texture;
    c.drawVertices(vertices_, PrimitiveType.triangle, s, ebo: _ebo);
  }
}
