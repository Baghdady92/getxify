import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

void main() {
  // https://github.com/jonataslaw/getx/issues/2144
  // GetMaterialApp/GetCupertinoApp did not expose restorationScopeId,
  // making it impossible to enable state restoration at the app level.

  Finder rootRestorationScopeWithId(String id) => find.byWidgetPredicate(
    (widget) => widget is RootRestorationScope && widget.restorationId == id,
  );

  testWidgets(
    'GetMaterialApp forwards restorationScopeId to MaterialApp (getPages)',
    (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          restorationScopeId: 'app',
          initialRoute: '/',
          getPages: [GetPage(name: '/', page: () => const Text('home'))],
        ),
      );
      await tester.pumpAndSettle();

      expect(rootRestorationScopeWithId('app'), findsOneWidget);
    },
  );

  testWidgets('GetMaterialApp forwards restorationScopeId to MaterialApp '
      '(home, imperative navigation)', (tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(restorationScopeId: 'app', home: Text('home')),
    );
    await tester.pumpAndSettle();

    expect(rootRestorationScopeWithId('app'), findsOneWidget);
  });

  testWidgets(
    'GetCupertinoApp forwards restorationScopeId to CupertinoApp (getPages)',
    (tester) async {
      await tester.pumpWidget(
        GetCupertinoApp(
          restorationScopeId: 'app',
          initialRoute: '/',
          getPages: [GetPage(name: '/', page: () => const Text('home'))],
        ),
      );
      await tester.pumpAndSettle();

      expect(rootRestorationScopeWithId('app'), findsOneWidget);
    },
  );

  testWidgets('GetCupertinoApp forwards restorationScopeId to CupertinoApp '
      '(home, imperative navigation)', (tester) async {
    await tester.pumpWidget(
      const GetCupertinoApp(restorationScopeId: 'app', home: Text('home')),
    );
    await tester.pumpAndSettle();

    expect(rootRestorationScopeWithId('app'), findsOneWidget);
  });

  test('router constructors accept restorationScopeId', () {
    const materialRouter = GetMaterialApp.router(restorationScopeId: 'app');
    const cupertinoRouter = GetCupertinoApp.router(restorationScopeId: 'app');

    expect(materialRouter.restorationScopeId, 'app');
    expect(cupertinoRouter.restorationScopeId, 'app');
  });
}
