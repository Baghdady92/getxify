import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

// https://github.com/jonataslaw/getx/issues/1855
// trPlural only supports the two-form (one/other) rule, which is wrong for
// Arabic, Russian, Polish, etc. trPluralCases exposes every CLDR plural
// category through a pluggable Get.pluralResolver.
void main() {
  PluralCase russianRule(int count, Locale? locale) {
    if (count % 10 == 1 && count % 100 != 11) return PluralCase.one;
    if (count % 10 >= 2 &&
        count % 10 <= 4 &&
        (count % 100 < 12 || count % 100 > 14)) {
      return PluralCase.few;
    }
    return PluralCase.many;
  }

  PluralCase arabicRule(int count, Locale? locale) {
    if (count == 0) return PluralCase.zero;
    if (count == 1) return PluralCase.one;
    if (count == 2) return PluralCase.two;
    if (count % 100 >= 3 && count % 100 <= 10) return PluralCase.few;
    if (count % 100 >= 11) return PluralCase.many;
    return PluralCase.other;
  }

  setUp(() {
    Get.clearTranslations();
    Get.addTranslations({
      'en_US': {
        'songs_one': '%s song',
        'songs_other': '%s songs',
        'apples_one': 'You have @count apple',
        'apples_other': 'You have @count apples',
      },
      'ru_RU': {
        'songs_one': '%s песня',
        'songs_few': '%s песни',
        'songs_many': '%s песен',
        'apples_one': 'У вас @count яблоко',
        'apples_few': 'У вас @count яблока',
        'apples_many': 'У вас @count яблок',
      },
      'ar_SA': {
        'songs_zero': 'لا أغاني',
        'songs_one': 'أغنية واحدة',
        'songs_two': 'أغنيتان',
        'songs_few': '%s أغانٍ',
        'songs_many': '%s أغنية',
      },
    });
    Get.locale = const Locale('en', 'US');
    Get.fallbackLocale = null;
    Get.pluralResolver = null;
  });

  tearDown(() {
    Get.pluralResolver = null;
    Get.clearTranslations();
  });

  const songCases = {
    PluralCase.zero: 'songs_zero',
    PluralCase.one: 'songs_one',
    PluralCase.two: 'songs_two',
    PluralCase.few: 'songs_few',
    PluralCase.many: 'songs_many',
    PluralCase.other: 'songs_other',
  };

  const appleCases = {
    PluralCase.one: 'apples_one',
    PluralCase.few: 'apples_few',
    PluralCase.many: 'apples_many',
    PluralCase.other: 'apples_other',
  };

  test('default resolver applies the two-form English rule', () {
    expect('songs'.trPluralCases(songCases, 1, ['1']), '1 song');
    expect('songs'.trPluralCases(songCases, 0, ['0']), '0 songs');
    expect('songs'.trPluralCases(songCases, 5, ['5']), '5 songs');
  });

  test('unmatched category falls back to other, then to the key itself', () {
    expect(
      'songs'.trPluralCases({PluralCase.one: 'songs_one'}, 1, ['1']),
      '1 song',
    );
    // No entry for the resolved category and no "other": the key itself.
    expect('songs'.trPluralCases({PluralCase.one: 'songs_one'}, 7), 'songs');
    // Resolved category missing, "other" present.
    expect(
      'songs'.trPluralCases({PluralCase.other: 'songs_other'}, 1, ['1']),
      '1 songs',
    );
  });

  test('custom resolver enables Russian plural rules', () {
    Get.locale = const Locale('ru', 'RU');
    Get.pluralResolver = russianRule;

    expect('songs'.trPluralCases(songCases, 1, ['1']), '1 песня');
    expect('songs'.trPluralCases(songCases, 21, ['21']), '21 песня');
    expect('songs'.trPluralCases(songCases, 3, ['3']), '3 песни');
    expect('songs'.trPluralCases(songCases, 24, ['24']), '24 песни');
    expect('songs'.trPluralCases(songCases, 5, ['5']), '5 песен');
    expect('songs'.trPluralCases(songCases, 12, ['12']), '12 песен');
    expect('songs'.trPluralCases(songCases, 111, ['111']), '111 песен');
  });

  test(
    'custom resolver enables Arabic plural rules including zero and two',
    () {
      Get.locale = const Locale('ar', 'SA');
      Get.pluralResolver = arabicRule;

      expect('songs'.trPluralCases(songCases, 0), 'لا أغاني');
      expect('songs'.trPluralCases(songCases, 1), 'أغنية واحدة');
      expect('songs'.trPluralCases(songCases, 2), 'أغنيتان');
      expect('songs'.trPluralCases(songCases, 3, ['3']), '3 أغانٍ');
      expect('songs'.trPluralCases(songCases, 11, ['11']), '11 أغنية');
    },
  );

  test('resolver receives the count and the active locale', () {
    int? seenCount;
    Locale? seenLocale;
    Get.pluralResolver = (count, locale) {
      seenCount = count;
      seenLocale = locale;
      return PluralCase.other;
    };

    'songs'.trPluralCases(songCases, 42, ['42']);
    expect(seenCount, 42);
    expect(seenLocale, const Locale('en', 'US'));
  });

  test('trPluralCasesParams substitutes named parameters', () {
    expect(
      'apples'.trPluralCasesParams(appleCases, 1, {'count': '1'}),
      'You have 1 apple',
    );
    expect(
      'apples'.trPluralCasesParams(appleCases, 4, {'count': '4'}),
      'You have 4 apples',
    );

    Get.locale = const Locale('ru', 'RU');
    Get.pluralResolver = russianRule;
    expect(
      'apples'.trPluralCasesParams(appleCases, 2, {'count': '2'}),
      'У вас 2 яблока',
    );
    expect(
      'apples'.trPluralCasesParams(appleCases, 5, {'count': '5'}),
      'У вас 5 яблок',
    );
  });

  test('trPlural and trPluralParams keep their original behavior', () {
    expect('songs_one'.trPlural('songs_other', 1, ['1']), '1 song');
    expect('songs_one'.trPlural('songs_other', 2, ['2']), '2 songs');
    expect(
      'apples_one'.trPluralParams('apples_other', 1, {'count': '1'}),
      'You have 1 apple',
    );
    expect(
      'apples_one'.trPluralParams('apples_other', 3, {'count': '3'}),
      'You have 3 apples',
    );

    // Installing a resolver must not change trPlural's two-form contract.
    Get.pluralResolver = (count, locale) => PluralCase.many;
    expect('songs_one'.trPlural('songs_other', 1, ['1']), '1 song');
  });
}
