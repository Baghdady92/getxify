part of '../rx_types.dart';

/// Rx class for `String` type.
class RxString extends Rx<String> implements Comparable<String>, Pattern {
  RxString(super.initial);

  @override
  Iterable<Match> allMatches(String string, [int start = 0]) {
    return value.allMatches(string, start);
  }

  @override
  Match? matchAsPrefix(String string, [int start = 0]) {
    return value.matchAsPrefix(string, start);
  }

  @override
  int compareTo(String other) {
    return value.compareTo(other);
  }
}

/// Rx class for nullable `String` type.
class RxnString extends Rx<String?> implements Comparable<String>, Pattern {
  RxnString([super.initial]);

  @override
  Iterable<Match> allMatches(String string, [int start = 0]) {
    return value!.allMatches(string, start);
  }

  @override
  Match? matchAsPrefix(String string, [int start = 0]) {
    return value!.matchAsPrefix(string, start);
  }

  @override
  int compareTo(String other) {
    return value!.compareTo(other);
  }
}

/// Extension on [Rx<String>] providing standard operators.
extension RxStringExt on Rx<String> {
  /// Concatenation operator.
  String operator +(String val) => value + val;
}

/// Extension on [Rx<String?>] providing standard operators.
extension RxnStringExt on Rx<String?> {
  /// Concatenation operator.
  String operator +(String val) => (value ?? '') + val;
}
