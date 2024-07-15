import 'package:uuid/uuid.dart';

class ResourceHolder<Resource> {
  final _data = <String, Resource>{};
  final _idGen = Uuid();

  String add(Resource res) {
    final key = _idGen.v4();
    _data[key] = res;
    return key;
  }

  bool has(String key) {
    return _data.containsKey(key);
  }

  Resource get(String key) {
    if (!has(key)) {
      throw ArgumentError('Non existent key');
    }
    return _data[key]!;
  }
}
