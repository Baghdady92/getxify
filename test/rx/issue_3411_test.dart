import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

abstract class PaymentEntity {
  const PaymentEntity(this.id);
  final int id;
}

class PaymentModel extends PaymentEntity {
  const PaymentModel(super.id);
}

void main() {
  group('issue #3411: default-constructed Rx collections are typed as E', () {
    test('RxList<E>() accepts elements of E and its subtypes', () {
      final RxList<PaymentEntity> payments = RxList<PaymentEntity>();
      expect(() => payments.add(const PaymentModel(1)), returnsNormally);
      payments.add(const PaymentModel(2));
      payments.addAll(const [PaymentModel(3), PaymentModel(4)]);
      expect(payments.length, 4);
      expect(payments.first.id, 1);
    });

    test('RxList created via .obs on empty typed list accepts adds', () {
      final payments = <PaymentEntity>[].obs;
      payments.add(const PaymentModel(1));
      expect(payments.length, 1);
    });

    test('RxSet<E>() accepts elements of E and its subtypes', () {
      final RxSet<PaymentEntity> payments = RxSet<PaymentEntity>();
      expect(() => payments.add(const PaymentModel(1)), returnsNormally);
      payments.add(const PaymentModel(2));
      expect(payments.length, 2);
    });

    test('RxMap<K, V>() accepts entries of K/V and their subtypes', () {
      final RxMap<String, PaymentEntity> payments =
          RxMap<String, PaymentEntity>();
      expect(
        () => payments['a'] = const PaymentModel(1),
        returnsNormally,
      );
      payments['b'] = const PaymentModel(2);
      expect(payments.length, 2);
    });

    test('RxList still aliases a caller-supplied backing list', () {
      final backing = <int>[1, 2];
      final rx = RxList<int>(backing);
      rx.add(3);
      expect(backing, [1, 2, 3]);
    });

    test('RxList.unmodifiable remains unmodifiable', () {
      final rx = RxList<int>.unmodifiable([1, 2]);
      expect(() => rx.add(3), throwsUnsupportedError);
    });
  });
}
