import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

void main() {
  setUp(() {
    Get.clearTranslations();
    Get.addTranslations({
      'zh_Hant': {'hello': '你好（繁體）'},
      'zh_Hant_TW': {'hello': '你好（台灣繁體）'},
      'zh_CN': {'hello': '你好（简体）'},
      'en_US': {'hello': 'Hello', 'only_english': 'English only'},
    });
    Get.fallbackLocale = const Locale('en', 'US');
  });

  tearDown(() {
    Get.clearTranslations();
    Get.locale = null;
    Get.fallbackLocale = null;
  });

  test('scriptCode-only locale prefers language_script key', () {
    Get.locale = const Locale.fromSubtags(
      languageCode: 'zh',
      scriptCode: 'Hant',
    );
    expect('hello'.tr, '你好（繁體）');
  });

  test('script + country locale prefers language_script_country key', () {
    Get.locale = const Locale.fromSubtags(
      languageCode: 'zh',
      scriptCode: 'Hant',
      countryCode: 'TW',
    );
    expect('hello'.tr, '你好（台灣繁體）');
  });

  test(
    'script + country falls back to language_script before language_country',
    () {
      Get.locale = const Locale.fromSubtags(
        languageCode: 'zh',
        scriptCode: 'Hant',
        countryCode: 'HK',
      );
      expect('hello'.tr, '你好（繁體）');
    },
  );

  test('locale without script still resolves language_country key', () {
    Get.locale = const Locale('zh', 'CN');
    expect('hello'.tr, '你好（简体）');
  });

  test('similar-language fallback still works for unknown country', () {
    Get.locale = const Locale('en', 'EN');
    expect('hello'.tr, 'Hello');
  });

  test('missing key falls back to fallbackLocale, then to the key itself', () {
    Get.locale = const Locale.fromSubtags(
      languageCode: 'zh',
      scriptCode: 'Hant',
    );
    expect('only_english'.tr, 'English only');
    expect('missing_key'.tr, 'missing_key');
  });

  test('fallbackLocale with scriptCode resolves script-specific keys', () {
    Get.locale = const Locale('fr', 'FR');
    Get.fallbackLocale = const Locale.fromSubtags(
      languageCode: 'zh',
      scriptCode: 'Hant',
      countryCode: 'TW',
    );
    expect('hello'.tr, '你好（台灣繁體）');
  });
}
