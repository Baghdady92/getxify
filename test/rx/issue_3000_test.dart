import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

void main() {
  // https://github.com/jonataslaw/getx/issues/3000
  // bindStream never cancelled the previous subscription on rebind, and
  // the cancel disposer was silently dropped outside of an observer build,
  // so stale streams kept overwriting the Rx with old data forever.
  test('bindStream with cancelPrevious replaces the previous binding '
      'so the old stream can no longer overwrite the value', () async {
    final oldRoom = StreamController<List<String>>();
    final newRoom = StreamController<List<String>>();
    final messages = RxList<String>();

    messages.bindStream(oldRoom.stream);
    oldRoom.add(['old message']);
    await Future.delayed(Duration.zero);
    expect(messages, ['old message']);

    messages.bindStream(newRoom.stream, cancelPrevious: true);
    newRoom.add(['new message']);
    await Future.delayed(Duration.zero);
    expect(messages, ['new message']);

    oldRoom.add(['stale message']);
    await Future.delayed(Duration.zero);
    expect(messages, ['new message']);

    await oldRoom.close();
    await newRoom.close();
    messages.close();
  });

  test(
    'bindStream with cancelPrevious cancels the old stream subscription',
    () async {
      var oldCancelled = false;
      final oldSource = StreamController<int>(
        onCancel: () {
          oldCancelled = true;
        },
      );
      final newSource = StreamController<int>();
      final rx = 0.obs;

      rx.bindStream(oldSource.stream);
      rx.bindStream(newSource.stream, cancelPrevious: true);
      await Future.delayed(Duration.zero);
      expect(oldCancelled, true);

      await newSource.close();
      rx.close();
      await oldSource.close();
    },
  );

  test('close() cancels subscriptions created by bindStream outside '
      'an observer build', () async {
    var cancelled = false;
    final source = StreamController<int>(
      onCancel: () {
        cancelled = true;
      },
    );
    final rx = 0.obs;

    rx.bindStream(source.stream);
    source.add(1);
    await Future.delayed(Duration.zero);
    expect(rx.value, 1);
    expect(cancelled, false);

    rx.close();
    await Future.delayed(Duration.zero);
    expect(cancelled, true);

    await source.close();
  });

  test(
    'bindStream still supports multiple simultaneous sources by default',
    () async {
      final first = StreamController<int>();
      final second = StreamController<int>();
      final rx = 0.obs;

      rx.bindStream(first.stream);
      rx.bindStream(second.stream);

      first.add(1);
      await Future.delayed(Duration.zero);
      expect(rx.value, 1);

      second.add(2);
      await Future.delayed(Duration.zero);
      expect(rx.value, 2);

      first.add(3);
      await Future.delayed(Duration.zero);
      expect(rx.value, 3);

      await first.close();
      await second.close();
      rx.close();
    },
  );

  test(
    'bindStream returns the subscription so callers can cancel it manually',
    () async {
      final source = StreamController<int>();
      final rx = 0.obs;

      final sub = rx.bindStream(source.stream);
      source.add(10);
      await Future.delayed(Duration.zero);
      expect(rx.value, 10);

      await sub.cancel();
      source.add(20);
      await Future.delayed(Duration.zero);
      expect(rx.value, 10);

      await source.close();
      rx.close();
    },
  );
}
