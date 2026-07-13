import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

class _PingIntent extends Intent {
  const _PingIntent();
}

void main() {
  tearDown(Get.reset);

  // Regression tests for https://github.com/jonataslaw/getx/issues/2615:
  // GetMaterialApp/GetCupertinoApp declared `shortcuts` as
  // Map<LogicalKeySet, Intent>? instead of Map<ShortcutActivator, Intent>?,
  // rejecting SingleActivator/CharacterActivator keys (and
  // WidgetsApp.defaultShortcuts) at compile time even though
  // MaterialApp/CupertinoApp accept the wider type.

  testWidgets(
    'GetMaterialApp accepts Map<ShortcutActivator, Intent> shortcuts',
    (tester) async {
      var pinged = 0;
      final Map<ShortcutActivator, Intent> shortcuts = {
        ...WidgetsApp.defaultShortcuts,
        const SingleActivator(LogicalKeyboardKey.keyP, control: true):
            const _PingIntent(),
      };

      await tester.pumpWidget(
        GetMaterialApp(
          shortcuts: shortcuts,
          home: Scaffold(
            body: Actions(
              actions: {
                _PingIntent: CallbackAction<_PingIntent>(
                  onInvoke: (_) => pinged++,
                ),
              },
              child: const Focus(autofocus: true, child: Text('home')),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyP);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyP);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);

      expect(pinged, 1);
    },
  );

  testWidgets(
    'GetCupertinoApp accepts Map<ShortcutActivator, Intent> shortcuts',
    (tester) async {
      var pinged = 0;
      final Map<ShortcutActivator, Intent> shortcuts = {
        const CharacterActivator('q'): const _PingIntent(),
      };

      await tester.pumpWidget(
        GetCupertinoApp(
          shortcuts: shortcuts,
          home: Actions(
            actions: {
              _PingIntent: CallbackAction<_PingIntent>(
                onInvoke: (_) => pinged++,
              ),
            },
            child: const Focus(autofocus: true, child: Text('home')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.keyQ, character: 'q');

      expect(pinged, 1);
    },
  );

  testWidgets(
    'GetMaterialApp.router forwards ShortcutActivator shortcuts',
    (tester) async {
      await tester.pumpWidget(
        GetMaterialApp.router(
          shortcuts: <ShortcutActivator, Intent>{
            const SingleActivator(LogicalKeyboardKey.escape):
                const _PingIntent(),
          },
          getPages: [
            GetPage(
              name: '/',
              page: () => const Scaffold(body: Text('router home')),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('router home'), findsOneWidget);
    },
  );
}
