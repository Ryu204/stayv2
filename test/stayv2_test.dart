import 'package:stayv2/src/app.dart';
import 'package:stayv2/stayv2.dart';
import 'package:test/test.dart';

void main() {
  group('Happy path', () {
    final awesome = Application(AppConfig());

    setUp(() {
      // Additional setup goes here.
    });

    test('First Test', () {
      awesome.run();
    });
  });
}
