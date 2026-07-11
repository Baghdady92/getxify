import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('home'));
  }
}

void main() {
  setUp(() {
    Get.locale = null;
  });

  tearDown(() {
    Get.locale = null;
    Get.reset();
  });

  Future<void> setDeviceLocale(WidgetTester tester, Locale locale) async {
    tester.platformDispatcher.localeTestValue = locale;
    tester.platformDispatcher.localesTestValue = [locale];
    await tester.pumpAndSettle();
  }

  Future<void> resetDeviceLocale(WidgetTester tester) async {
    tester.platformDispatcher.clearLocaleTestValue();
    tester.platformDispatcher.clearLocalesTestValue();
    await tester.pumpAndSettle();
  }

  testWidgets(
    'system locale change does not override locale set via GetMaterialApp',
    (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          locale: const Locale('en', 'US'),
          getPages: [GetPage(name: '/', page: () => const Home())],
        ),
      );
      await tester.pumpAndSettle();

      expect(Get.locale, const Locale('en', 'US'));

      await setDeviceLocale(tester, const Locale('fr', 'FR'));

      expect(Get.locale, const Locale('en', 'US'));

      await resetDeviceLocale(tester);
    },
  );

  testWidgets(
    'system locale change does not override locale set via Get.updateLocale',
    (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          getPages: [GetPage(name: '/', page: () => const Home())],
        ),
      );
      await tester.pumpAndSettle();

      Get.updateLocale(const Locale('ar', 'EG'));
      await tester.pumpAndSettle();
      expect(Get.locale, const Locale('ar', 'EG'));

      await setDeviceLocale(tester, const Locale('fr', 'FR'));

      expect(Get.locale, const Locale('ar', 'EG'));

      await resetDeviceLocale(tester);
    },
  );

  testWidgets(
    'device locale change is still adopted when the app never set a locale',
    (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          getPages: [GetPage(name: '/', page: () => const Home())],
        ),
      );
      await tester.pumpAndSettle();

      await setDeviceLocale(tester, const Locale('pt', 'BR'));

      expect(Get.locale, const Locale('pt', 'BR'));

      await setDeviceLocale(tester, const Locale('fr', 'FR'));

      expect(Get.locale, const Locale('fr', 'FR'));

      await resetDeviceLocale(tester);
    },
  );
}
