import 'package:vector_math/vector_math.dart';

enum PrimitiveType { points, lineLoop, line }

class Vertex {
  var color = Colors.white;
  var position = Vector3.zero();

  Vertex(this.position, this.color);
}
