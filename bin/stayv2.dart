import 'package:stayv2/stayv2.dart';

void main() {
  try {
    final app = Application(AppConfig());
    app.run();
  } catch (e) {
    if (e is Error) print('Error happened: $e\n${e.stackTrace}');
  }
}
