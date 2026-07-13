import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/get_rx/get_rx.dart';

void main() {
  // https://github.com/jonataslaw/getx/issues/2250
  // assignAll on an RxSet notified listeners twice: once for the internal
  // clear() (with an empty set) and once for the addAll(). Listeners must
  // receive exactly one event, carrying the final contents.
  test(
    'RxSet.assignAll notifies exactly once with the final contents',
    () async {
      final set = {1, 2, 3}.obs;
      final events = <Set<int>>[];
      set.listen((value) => events.add(Set<int>.of(value)));

      set.assignAll({4, 5});
      await Future.delayed(Duration.zero);

      expect(events.length, 1);
      expect(events.single, {4, 5});
      expect(set, {4, 5});
    },
  );

  test('RxSet.assign notifies exactly once with the final contents', () async {
    final set = {1, 2, 3}.obs;
    final events = <Set<int>>[];
    set.listen((value) => events.add(Set<int>.of(value)));

    set.assign(9);
    await Future.delayed(Duration.zero);

    expect(events.length, 1);
    expect(events.single, {9});
    expect(set, {9});
  });

  test('assignAll still replaces contents on a plain (non-reactive) Set', () {
    final set = {1, 2, 3};
    set.assignAll({4, 5});
    expect(set, {4, 5});

    set.assign(9);
    expect(set, {9});
  });
}
