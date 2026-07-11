import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getxify/getxify.dart';

void main() {
  setUp(() {
    Get.clearTranslations();
    Get.addTranslations({
      'en_US': {
        'correct_answer_message':
            'You answered correctly on @correctAnswers of @questionsPerGame '
                'questions!',
      },
      'he_IL': {
        'correct_answer_message':
            'ענית נכון על @correctAnswers מתוך @questionsPerGame שאלות !',
        'malformed_message': 'ענית נכון על correctAnswers@ שאלות',
      },
    });
  });

  tearDown(() {
    Get.clearTranslations();
    Get.locale = null;
    Get.fallbackLocale = null;
  });

  test('trParams substitutes @ placeholders in an LTR (English) string', () {
    Get.locale = const Locale('en', 'US');
    expect(
      'correct_answer_message'.trParams({
        'correctAnswers': '9',
        'questionsPerGame': '10',
      }),
      'You answered correctly on 9 of 10 questions!',
    );
  });

  test('trParams substitutes @ placeholders in an RTL (Hebrew) string', () {
    Get.locale = const Locale('he', 'IL');
    expect(
      'correct_answer_message'.trParams({
        'correctAnswers': '9',
        'questionsPerGame': '10',
      }),
      'ענית נכון על 9 מתוך 10 שאלות !',
    );
  });

  test('trParams handles multi-codepoint values inside RTL text', () {
    Get.locale = const Locale('he', 'IL');
    expect(
      'correct_answer_message'.trParams({
        'correctAnswers': '11',
        'questionsPerGame': '22',
      }),
      'ענית נכון על 11 מתוך 22 שאלות !',
    );
  });

  test(
    'trParams does not substitute a logically reversed key@ placeholder',
    () {
      Get.locale = const Locale('he', 'IL');
      // 'correctAnswers@' has the '@' logically after the name (a common
      // RTL-editor authoring mistake); it must be left untouched.
      expect(
        'malformed_message'.trParams({'correctAnswers': '9'}),
        'ענית נכון על correctAnswers@ שאלות',
      );
    },
  );
}
