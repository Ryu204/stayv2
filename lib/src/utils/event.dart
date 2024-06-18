import 'package:uuid/uuid.dart';

/// Allows subsription and notification
class Event<T> {
  final Map<String, Function(T)> _callbacks = {};
  final _idGen = Uuid();

  /// Returns the id of registered callback
  operator +(Function(T) callback) {
    final id = _idGen.v4();
    _callbacks[id] = callback;
    return id;
  }

  operator -(String id) {
    _callbacks.remove(id);
  }

  invoke(T arg) {
    for (final cb in _callbacks.values) {
      cb(arg);
    }
  }
}
