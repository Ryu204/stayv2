import 'package:vector_math/vector_math.dart';

enum PrimitiveType { point, line, triangle }

class Vertex {
  var color = Colors.white;
  var position = Vector3.zero();
  Vector2 texCoords;

  Vertex(this.position, this.color) : texCoords = Vector2.zero();
  Vertex.withTexCoords(this.position, this.color, this.texCoords);
}
