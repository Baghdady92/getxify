import 'dart:async';

class GetQueue {
  final List<_Item> _queue = [];
  bool _active = false;

  Future<T> add<T>(FutureOr<T> Function() job) {
    var completer = Completer<T>();
    _queue.add(_Item(completer, job));
    _check();
    return completer.future;
  }

  void cancelAllJobs() {
    for (final item in _queue) {
      item.completer.completeError('Canceled');
    }
    _queue.clear();
  }

  void _check() async {
    if (!_active && _queue.isNotEmpty) {
      _active = true;
      var item = _queue.removeAt(0);
      try {
        item.completer.complete(await item.job());
      } catch (e, st) {
        item.completer.completeError(e, st);
      }
      _active = false;
      _check();
    }
  }
}

class _Item {
  final Completer completer;
  final Function job;

  _Item(this.completer, this.job);
}
