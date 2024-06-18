import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';

class _Entry {
  double timePoint;
  double interval;
  Function() callback;
  bool loop;
  String id;

  _Entry({
    required this.timePoint,
    required this.callback,
    required this.interval,
    required this.loop,
    required this.id,
  });
}

int _comparator(_Entry sml, _Entry lgr) {
  return sml.timePoint < lgr.timePoint
      ? -1
      : sml.timePoint == lgr.timePoint
          ? 0
          : 1;
}

/// Allows synchronous future callbacks
class Invoker {
  final _sortedEntries = PriorityQueue<_Entry>(_comparator);
  final _removedIds = <String>{};
  double _currentTimePoint = 0;
  final _idGen = Uuid();

  /// Returns id of the callback
  after(double sec, Function() callback, {bool loop = false}) {
    if (sec < 0) {
      throw ArgumentError.value(sec, 'sec', 'Cannot invoke in the past');
    }
    final id = _idGen.v4();
    _sortedEntries.add(_Entry(
      timePoint: _currentTimePoint + sec,
      callback: callback,
      interval: sec,
      loop: loop,
      id: id,
    ));
    return id;
  }

  /// Removes the callback
  remove(String id) {
    _removedIds.add(id);
  }

  advance(double sec) {
    _currentTimePoint += sec;
    while (_sortedEntries.isNotEmpty) {
      final entry = _sortedEntries.first;
      if (entry.timePoint > _currentTimePoint) return;
      // We execute entry and check if it should be put back into the queue
      if (_removedIds.contains(entry.id)) {
        // If the callback was removed, we do not execute
        _removedIds.remove(entry.id);
      } else {
        entry.callback();
      }
      _sortedEntries.removeFirst();
      if (entry.loop) {
        entry.timePoint += entry.interval;
        _sortedEntries.add(entry);
      }
    }
  }
}

final invoke = Invoker();
