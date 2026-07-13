import 'dart:io';

import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

class TickerMixinController extends GetxController
    with GetSingleTickerProviderStateMixin {}

class MultiTickerMixinController extends GetxController
    with GetTickerProviderStateMixin {}

void main() {
  test('ticker provider mixin file uses the corrected file name', () {
    const base = 'lib/get_state_manager/src/rx_flutter';
    expect(File('$base/rx_ticker_provider_mixin.dart').existsSync(), isTrue);
    expect(File('$base/rx_ticket_provider_mixin.dart').existsSync(), isFalse);
  });

  test('ticker provider mixins remain exported from the public barrel', () {
    final single = TickerMixinController();
    final multi = MultiTickerMixinController();

    expect(single, isA<TickerProvider>());
    expect(multi, isA<TickerProvider>());

    final ticker = single.createTicker((_) {});
    expect(ticker, isA<Ticker>());
    ticker.dispose();

    final firstTicker = multi.createTicker((_) {});
    final secondTicker = multi.createTicker((_) {});
    expect(firstTicker, isNot(same(secondTicker)));
    firstTicker.dispose();
    secondTicker.dispose();
  });
}
