// Regression test for https://github.com/jonataslaw/getx/issues/2564
//
// GetPage used to fail with an opaque assertion when the route name did
// not start with '/'. The assert message now states the offending name
// and that route names must start with a slash, pointing to the fix.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

void main() {
  test(
      'GetPage throws a descriptive AssertionError when the route name '
      'does not start with a slash', () {
    expect(
      () => GetPage(name: 'profile', page: () => const SizedBox()),
      throwsA(
        isA<AssertionError>().having(
          (error) => error.message,
          'message',
          allOf(
            contains('"profile"'),
            contains('must start with a slash'),
            contains('/profile'),
          ),
        ),
      ),
    );
  });

  test('GetPage accepts a route name that starts with a slash', () {
    final page = GetPage(name: '/profile', page: () => const SizedBox());
    expect(page.name, '/profile');
  });
}
