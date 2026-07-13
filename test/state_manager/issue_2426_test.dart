import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

class SingleTickController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late final Ticker ticker;
  final tick = 0.obs;

  @override
  void onInit() {
    super.onInit();
    ticker = createTicker((_) {});
    ticker.start();
  }

  @override
  void onClose() {
    ticker.dispose();
    super.onClose();
  }
}

class MultiTickController extends GetxController
    with GetTickerProviderStateMixin {
  late final Ticker firstTicker;
  late final Ticker secondTicker;

  @override
  void onInit() {
    super.onInit();
    firstTicker = createTicker((_) {});
    secondTicker = createTicker((_) {});
    firstTicker.start();
    secondTicker.start();
  }

  @override
  void onClose() {
    firstTicker.dispose();
    secondTicker.dispose();
    super.onClose();
  }
}

class _TickerModeHost extends StatefulWidget {
  const _TickerModeHost({required this.child});

  final Widget child;

  @override
  State<_TickerModeHost> createState() => _TickerModeHostState();
}

class _TickerModeHostState extends State<_TickerModeHost> {
  bool _enabled = true;

  // ignore: use_setters_to_change_properties
  void setEnabled(bool value) {
    setState(() => _enabled = value);
  }

  @override
  Widget build(BuildContext context) {
    return TickerMode(enabled: _enabled, child: widget.child);
  }
}

void main() {
  _TickerModeHostState hostState(WidgetTester tester) =>
      tester.state<_TickerModeHostState>(find.byType(_TickerModeHost));

  testWidgets(
    'GetSingleTickerProviderStateMixin ticker is muted when TickerMode '
    'disables tickers under GetBuilder',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: _TickerModeHost(
            child: GetBuilder<SingleTickController>(
              init: SingleTickController(),
              builder: (controller) => const SizedBox(),
            ),
          ),
        ),
      );

      final controller = Get.find<SingleTickController>();
      expect(controller.ticker.muted, isFalse);
      expect(controller.ticker.isTicking, isTrue);

      hostState(tester).setEnabled(false);
      await tester.pump();

      expect(controller.ticker.muted, isTrue);
      expect(controller.ticker.isTicking, isFalse);

      hostState(tester).setEnabled(true);
      await tester.pump();

      expect(controller.ticker.muted, isFalse);
      expect(controller.ticker.isTicking, isTrue);

      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'GetTickerProviderStateMixin tickers are muted when TickerMode '
    'disables tickers under GetBuilder',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: _TickerModeHost(
            child: GetBuilder<MultiTickController>(
              init: MultiTickController(),
              builder: (controller) => const SizedBox(),
            ),
          ),
        ),
      );

      final controller = Get.find<MultiTickController>();
      expect(controller.firstTicker.muted, isFalse);
      expect(controller.secondTicker.muted, isFalse);

      hostState(tester).setEnabled(false);
      await tester.pump();

      expect(controller.firstTicker.muted, isTrue);
      expect(controller.secondTicker.muted, isTrue);

      hostState(tester).setEnabled(true);
      await tester.pump();

      expect(controller.firstTicker.muted, isFalse);
      expect(controller.secondTicker.muted, isFalse);

      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'GetSingleTickerProviderStateMixin ticker is muted when TickerMode '
    'disables tickers under GetX',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: _TickerModeHost(
            child: GetX<SingleTickController>(
              init: SingleTickController(),
              builder: (controller) => Text('tick: ${controller.tick.value}'),
            ),
          ),
        ),
      );

      final controller = Get.find<SingleTickController>();
      expect(controller.ticker.muted, isFalse);

      hostState(tester).setEnabled(false);
      await tester.pump();

      expect(controller.ticker.muted, isTrue);

      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'ticker created after the controller is bound honors the current '
    'TickerMode',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: _TickerModeHost(
            child: GetBuilder<MultiTickController>(
              init: MultiTickController(),
              builder: (controller) => const SizedBox(),
            ),
          ),
        ),
      );

      final controller = Get.find<MultiTickController>();
      hostState(tester).setEnabled(false);
      await tester.pump();

      final lateTicker = controller.createTicker((_) {});
      expect(lateTicker.muted, isTrue);
      lateTicker.dispose();

      await tester.pumpWidget(const SizedBox());
    },
  );
}
