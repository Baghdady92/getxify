part of '../rx_types.dart';

/// Create a list similar to `List<T>` but reactive.
class RxList<E> extends GetListenable<List<E>>
    with ListMixin<E>, RxObjectMixin<List<E>> {
  RxList([List<E>? initial]) : super(initial ?? <E>[]);

  factory RxList.filled(int length, E fill, {bool growable = false}) {
    return RxList(List.filled(length, fill, growable: growable));
  }

  factory RxList.empty({bool growable = false}) {
    return RxList(List.empty(growable: growable));
  }

  /// Creates a list containing all [elements].
  factory RxList.from(Iterable elements, {bool growable = true}) {
    return RxList(List.from(elements, growable: growable));
  }

  /// Creates a list from [elements].
  factory RxList.of(Iterable<E> elements, {bool growable = true}) {
    return RxList(List.of(elements, growable: growable));
  }

  /// Generates a list of values.
  factory RxList.generate(
    int length,
    E Function(int index) generator, {
    bool growable = true,
  }) {
    return RxList(List.generate(length, generator, growable: growable));
  }

  /// Creates an unmodifiable list containing all [elements].
  factory RxList.unmodifiable(Iterable elements) {
    return RxList(List.unmodifiable(elements));
  }

  @override
  Iterator<E> get iterator => value.iterator;

  @override
  void operator []=(int index, E val) {
    value[index] = val;
    refresh();
  }

  /// Special override to push() element(s) in a reactive way
  /// inside the List.
  @override
  RxList<E> operator +(Iterable<E> val) {
    addAll(val);
    return this;
  }

  @override
  E operator [](int index) {
    return value[index];
  }

  @override
  void add(E element) {
    value.add(element);
    refresh();
  }

  @override
  void addAll(Iterable<E> iterable) {
    value.addAll(iterable);
    refresh();
  }

  @override
  bool remove(Object? element) {
    final removed = value.remove(element);
    refresh();
    return removed;
  }

  @override
  void removeWhere(bool Function(E element) test) {
    value.removeWhere(test);
    refresh();
  }

  @override
  void retainWhere(bool Function(E element) test) {
    value.retainWhere(test);
    refresh();
  }

  @override
  int get length => value.length;

  @override
  set length(int newLength) {
    value.length = newLength;
    refresh();
  }

  @override
  void clear() {
    value.clear();
    refresh();
  }

  @override
  E removeAt(int index) {
    final result = value.removeAt(index);
    refresh();
    return result;
  }

  @override
  E removeLast() {
    final result = value.removeLast();
    refresh();
    return result;
  }

  @override
  void removeRange(int start, int end) {
    value.removeRange(start, end);
    refresh();
  }

  @override
  void insert(int index, E element) {
    value.insert(index, element);
    refresh();
  }

  @override
  void insertAll(int index, Iterable<E> iterable) {
    value.insertAll(index, iterable);
    refresh();
  }

  @override
  Iterable<E> get reversed => value.reversed;

  @override
  void setRange(int start, int end, Iterable<E> iterable, [int skipCount = 0]) {
    value.setRange(start, end, iterable, skipCount);
    refresh();
  }

  @override
  void fillRange(int start, int end, [E? fill]) {
    value.fillRange(start, end, fill);
    refresh();
  }

  @override
  void replaceRange(int start, int end, Iterable<E> newContents) {
    value.replaceRange(start, end, newContents);
    refresh();
  }

  @override
  void setAll(int index, Iterable<E> iterable) {
    value.setAll(index, iterable);
    refresh();
  }

  @override
  Iterable<E> where(bool Function(E) test) {
    return value.where(test);
  }

  @override
  Iterable<T> whereType<T>() {
    return value.whereType<T>();
  }

  @override
  void sort([int Function(E a, E b)? compare]) {
    value.sort(compare);
    refresh();
  }
}

extension ListExtension<E> on List<E> {
  RxList<E> get obs => RxList<E>(this);

  /// Add [item] to [List<E>] only if [item] is not null.
  void addNonNull(E item) {
    if (item != null) add(item);
  }

  /// Add [item] to [List<E>] only if [condition] is true.
  void addIf(Object? condition, E item) {
    if (condition is Condition) condition = condition();
    if (condition is bool && condition) add(item);
  }

  /// Adds [Iterable<E>] to [List<E>] only if [condition] is true.
  void addAllIf(Object? condition, Iterable<E> items) {
    if (condition is Condition) condition = condition();
    if (condition is bool && condition) addAll(items);
  }

  /// Replaces all existing items of this list with [item]
  ///
  /// On an [RxList] the backing list is replaced with a fresh growable
  /// list rather than mutated in place, so this works even when the list
  /// was created from a fixed-length or unmodifiable source (e.g.
  /// `List.empty().obs` or `const [].obs`), and listeners are notified
  /// exactly once.
  void assign(E item) {
    if (this is RxList) {
      final rx = this as RxList;
      // toList() preserves the backing list's runtime element type while
      // always producing a growable, mutable copy.
      rx.value = rx.value.toList()
        ..clear()
        ..add(item);
    } else {
      clear();
      add(item);
    }
  }

  /// Replaces all existing items of this list with [items]
  ///
  /// On an [RxList] the backing list is replaced with a fresh growable
  /// list rather than mutated in place, so this works even when the list
  /// was created from a fixed-length or unmodifiable source (e.g.
  /// `List.empty().obs` or `const [].obs`), and listeners are notified
  /// exactly once.
  void assignAll(Iterable<E> items) {
    if (this is RxList) {
      final rx = this as RxList;
      rx.value = rx.value.toList()
        ..clear()
        ..addAll(items);
    } else {
      clear();
      addAll(items);
    }
  }
}
