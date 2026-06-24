part of '../rx_types.dart';

/// Extension on [Rx<num>] providing basic operators.
extension RxNumExt<T extends num> on Rx<T> {
  /// Multiplication operator.
  num operator *(num other) => value * other;

  /// Modulo operator.
  num operator %(num other) => value % other;

  /// Division operator.
  double operator /(num other) => value / other;

  /// Truncating division operator.
  int operator ~/(num other) => value ~/ other;

  /// Negate operator.
  num operator -() => -value;

  /// Relational less than operator.
  bool operator <(num other) => value < other;

  /// Relational less than or equal operator.
  bool operator <=(num other) => value <= other;

  /// Relational greater than operator.
  bool operator >(num other) => value > other;

  /// Relational greater than or equal operator.
  bool operator >=(num other) => value >= other;
}

/// Extension on [Rx<num?>] providing basic operators.
extension RxnNumExt<T extends num> on Rx<T?> {
  /// Multiplication operator.
  num? operator *(num other) => value != null ? value! * other : null;

  /// Modulo operator.
  num? operator %(num other) => value != null ? value! % other : null;

  /// Division operator.
  double? operator /(num other) => value != null ? value! / other : null;

  /// Truncating division operator.
  int? operator ~/(num other) => value != null ? value! ~/ other : null;

  /// Negate operator.
  num? operator -() => value != null ? -value! : null;

  /// Relational less than operator.
  bool? operator <(num other) => value != null ? value! < other : null;

  /// Relational less than or equal operator.
  bool? operator <=(num other) => value != null ? value! <= other : null;

  /// Relational greater than operator.
  bool? operator >(num other) => value != null ? value! > other : null;

  /// Relational greater than or equal operator.
  bool? operator >=(num other) => value != null ? value! >= other : null;
}

/// Rx class for `num` type.
class RxNum extends Rx<num> {
  RxNum(super.initial);

  /// Addition operator.
  num operator +(num other) {
    value += other;
    return value;
  }

  /// Subtraction operator.
  num operator -(num other) {
    value -= other;
    return value;
  }
}

/// Rx class for nullable `num` type.
class RxnNum extends Rx<num?> {
  RxnNum([super.initial]);

  /// Addition operator.
  num? operator +(num other) {
    if (value != null) {
      value = value! + other;
      return value;
    }
    return null;
  }

  /// Subtraction operator.
  num? operator -(num other) {
    if (value != null) {
      value = value! - other;
      return value;
    }
    return null;
  }
}

/// Rx class for `double` type.
class RxDouble extends Rx<double> {
  RxDouble(super.initial);
}

/// Rx class for nullable `double` type.
class RxnDouble extends Rx<double?> {
  RxnDouble([super.initial]);
}

/// Rx class for `int` type.
class RxInt extends Rx<int> {
  RxInt(super.initial);

  /// Addition operator.
  RxInt operator +(int other) {
    value = value + other;
    return this;
  }

  /// Subtraction operator.
  RxInt operator -(int other) {
    value = value - other;
    return this;
  }
}

/// Rx class for nullable `int` type.
class RxnInt extends Rx<int?> {
  RxnInt([super.initial]);

  /// Addition operator.
  RxnInt operator +(int other) {
    if (value != null) {
      value = value! + other;
    }
    return this;
  }

  /// Subtraction operator.
  RxnInt operator -(int other) {
    if (value != null) {
      value = value! - other;
    }
    return this;
  }
}

/// Extension on [Rx<double>] providing basic double operators.
extension RxDoubleExt on Rx<double> {
  /// Addition operator.
  Rx<double> operator +(num other) {
    value = value + other;
    return this;
  }

  /// Subtraction operator.
  Rx<double> operator -(num other) {
    value = value - other;
    return this;
  }

  /// Multiplication operator.
  double operator *(num other) => value * other;

  /// Modulo operator.
  double operator %(num other) => value % other;

  /// Division operator.
  double operator /(num other) => value / other;

  /// Truncating division operator.
  int operator ~/(num other) => value ~/ other;

  /// Negate operator.
  double operator -() => -value;
}

/// Extension on [Rx<double?>] providing basic double operators.
extension RxnDoubleExt on Rx<double?> {
  /// Addition operator.
  Rx<double?>? operator +(num other) {
    if (value != null) {
      value = value! + other;
      return this;
    }
    return null;
  }

  /// Subtraction operator.
  Rx<double?>? operator -(num other) {
    if (value != null) {
      value = value! - other;
      return this;
    }
    return null;
  }

  /// Multiplication operator.
  double? operator *(num other) => value != null ? value! * other : null;

  /// Modulo operator.
  double? operator %(num other) => value != null ? value! % other : null;

  /// Division operator.
  double? operator /(num other) => value != null ? value! / other : null;

  /// Truncating division operator.
  int? operator ~/(num other) => value != null ? value! ~/ other : null;

  /// Negate operator.
  double? operator -() => value != null ? -value! : null;
}

/// Extension on [Rx<int>] providing basic integer operators.
extension RxIntExt on Rx<int> {
  /// Bit-wise and operator.
  int operator &(int other) => value & other;

  /// Bit-wise or operator.
  int operator |(int other) => value | other;

  /// Bit-wise xor operator.
  int operator ^(int other) => value ^ other;

  /// Bit-wise negate operator.
  int operator ~() => ~value;

  /// Bit-wise shift left operator.
  int operator <<(int shiftAmount) => value << shiftAmount;

  /// Bit-wise shift right operator.
  int operator >>(int shiftAmount) => value >> shiftAmount;

  /// Bit-wise unsigned shift right operator.
  int operator >>>(int shiftAmount) => value >>> shiftAmount;

  /// Division operator.
  double operator /(num other) => value / other;

  /// Unary negate operator.
  int operator -() => -value;
}

/// Extension on [Rx<int?>] providing basic integer operators.
extension RxnIntExt on Rx<int?> {
  /// Bit-wise and operator.
  int? operator &(int other) => value != null ? value! & other : null;

  /// Bit-wise or operator.
  int? operator |(int other) => value != null ? value! | other : null;

  /// Bit-wise xor operator.
  int? operator ^(int other) => value != null ? value! ^ other : null;

  /// Bit-wise negate operator.
  int? operator ~() => value != null ? ~value! : null;

  /// Bit-wise shift left operator.
  int? operator <<(int shiftAmount) => value != null ? value! << shiftAmount : null;

  /// Bit-wise shift right operator.
  int? operator >>(int shiftAmount) => value != null ? value! >> shiftAmount : null;

  /// Bit-wise unsigned shift right operator.
  int? operator >>>(int shiftAmount) => value != null ? value! >>> shiftAmount : null;

  /// Division operator.
  double? operator /(num other) => value != null ? value! / other : null;

  /// Unary negate operator.
  int? operator -() => value != null ? -value! : null;
}
