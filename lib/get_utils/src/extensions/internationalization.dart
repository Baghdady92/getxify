import 'dart:ui';

import '../../../get_core/get_core.dart';

class _IntlHost {
  Locale? locale;

  Locale? fallbackLocale;

  Map<String, Map<String, String>> translations = {};
}

extension LocalesIntl on GetInterface {
  static final _intlHost = _IntlHost();

  Locale? get locale => _intlHost.locale;

  Locale? get fallbackLocale => _intlHost.fallbackLocale;

  set locale(Locale? newLocale) => _intlHost.locale = newLocale;

  set fallbackLocale(Locale? newLocale) => _intlHost.fallbackLocale = newLocale;

  Map<String, Map<String, String>> get translations => _intlHost.translations;

  void addTranslations(Map<String, Map<String, String>> tr) {
    translations.addAll(tr);
  }

  void clearTranslations() {
    translations.clear();
  }

  void appendTranslations(Map<String, Map<String, String>> tr) {
    tr.forEach((key, map) {
      if (translations.containsKey(key)) {
        translations[key]!.addAll(map);
      } else {
        translations[key] = map;
      }
    });
  }
}

extension Trans on String {
  // Builds the candidate translation keys for [locale], from the most
  // specific to the least specific:
  // language_script_country, language_script, language_country, language.
  static List<String> _candidateKeys(Locale locale) {
    final language = locale.languageCode;
    final script = locale.scriptCode;
    final country = locale.countryCode;
    return [
      if (script != null && country != null) "${language}_${script}_$country",
      if (script != null) "${language}_$script",
      if (country != null) "${language}_$country",
      language,
    ];
  }

  // Looks this key up for [locale], trying each candidate key in order of
  // specificity, then falling back to any other translation entry that
  // shares the same language code. Returns null when nothing matches.
  String? _resolveTranslationFor(Locale locale) {
    for (final key in _candidateKeys(locale)) {
      final translation = Get.translations[key];
      if (translation != null && translation.containsKey(this)) {
        return translation[this];
      }
    }
    // Similar-language fallback in the absence of a more specific match.
    final prefix = "${locale.languageCode}_";
    for (final entry in Get.translations.entries) {
      if (entry.key.startsWith(prefix) && entry.value.containsKey(this)) {
        return entry.value[this];
      }
    }
    return null;
  }

  String get tr {
    final locale = Get.locale;
    // Returns the key if locale is null.
    if (locale == null) return this;

    final translation = _resolveTranslationFor(locale);
    if (translation != null) return translation;

    final fallback = Get.fallbackLocale;
    if (fallback != null) {
      return _resolveTranslationFor(fallback) ?? this;
    }
    // If there is no corresponding language or corresponding key, return
    // the key.
    return this;
  }

  String trArgs([List<String> args = const []]) {
    var key = tr;
    if (args.isNotEmpty) {
      for (final arg in args) {
        key = key.replaceFirst(RegExp(r'%s'), arg.toString());
      }
    }
    return key;
  }

  String trPlural([String? pluralKey, int? i, List<String> args = const []]) {
    return i == 1 ? trArgs(args) : pluralKey!.trArgs(args);
  }

  String trParams([Map<String, String> params = const {}]) {
    var trans = tr;
    if (params.isNotEmpty) {
      params.forEach((key, value) {
        trans = trans.replaceAll('@$key', value);
      });
    }
    return trans;
  }

  String trPluralParams([
    String? pluralKey,
    int? i,
    Map<String, String> params = const {},
  ]) {
    return i == 1 ? trParams(params) : pluralKey!.trParams(params);
  }
}
