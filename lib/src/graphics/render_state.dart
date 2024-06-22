import 'package:vector_math/vector_math.dart';

class RenderState {
  Matrix4 transform = Matrix4.identity();

  RenderState(this.transform);

  RenderState.identity();
}
