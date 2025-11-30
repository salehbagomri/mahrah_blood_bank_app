// اختبارات تطبيق بنك دم محافظة المهرة
//
// ملاحظة: هذه اختبارات أساسية فقط
// للاختبارات الكاملة، يجب استخدام integration_test
// مع mock للـ Supabase

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mahrah_blood_bank/constants/app_strings.dart';
import 'package:mahrah_blood_bank/constants/app_colors.dart';
import 'package:mahrah_blood_bank/utils/validators.dart';
import 'package:mahrah_blood_bank/utils/helpers.dart';

void main() {
  group('App Strings Tests', () {
    test('App name is correct', () {
      expect(AppStrings.appName, equals('بنك دم محافظة المهرة'));
    });

    test('Districts list contains all 9 districts', () {
      expect(AppStrings.districts.length, equals(9));
      expect(AppStrings.districts, contains('الغيضة'));
      expect(AppStrings.districts, contains('سيحوت'));
      expect(AppStrings.districts, contains('حصوين'));
    });
  });

  group('Validators Tests', () {
    test('validateName accepts valid names', () {
      expect(Validators.validateName('أحمد محمد'), isNull);
      expect(Validators.validateName('فاطمة علي'), isNull);
    });

    test('validateName rejects invalid names', () {
      expect(Validators.validateName(''), isNotNull);
      expect(Validators.validateName('ab'), isNotNull);
      expect(Validators.validateName(null), isNotNull);
    });

    test('validateAge accepts valid ages', () {
      expect(Validators.validateAge('25'), isNull);
      expect(Validators.validateAge('18'), isNull);
      expect(Validators.validateAge('65'), isNull);
    });

    test('validateAge rejects invalid ages', () {
      expect(Validators.validateAge('17'), isNotNull);
      expect(Validators.validateAge('66'), isNotNull);
      expect(Validators.validateAge('abc'), isNotNull);
      expect(Validators.validateAge(''), isNotNull);
    });

    test('validatePhoneNumber accepts valid Yemeni numbers', () {
      expect(Validators.validatePhoneNumber('777123456'), isNull);
      expect(Validators.validatePhoneNumber('700000000'), isNull);
    });

    test('validatePhoneNumber rejects invalid numbers', () {
      expect(Validators.validatePhoneNumber(''), isNotNull);
      expect(Validators.validatePhoneNumber('123'), isNotNull);
      expect(Validators.validatePhoneNumber('999999999'), isNotNull);
    });
  });

  group('Helpers Tests', () {
    test('formatPhoneNumber formats correctly', () {
      expect(Helpers.formatPhoneNumber('777123456'), equals('+967777123456'));
      expect(Helpers.formatPhoneNumber('00967777123456'), equals('+967777123456'));
    });

    test('genderToArabic converts correctly', () {
      expect(Helpers.genderToArabic('male'), equals('ذكر'));
      expect(Helpers.genderToArabic('female'), equals('أنثى'));
    });

    test('arabicToGender converts correctly', () {
      expect(Helpers.arabicToGender('ذكر'), equals('male'));
      expect(Helpers.arabicToGender('أنثى'), equals('female'));
    });

    test('getCompatibleBloodTypes returns correct types', () {
      final oNegative = Helpers.getCompatibleBloodTypes('O-');
      expect(oNegative, equals(['O-']));

      final abPositive = Helpers.getCompatibleBloodTypes('AB+');
      expect(abPositive.length, equals(8)); // يستقبل من الجميع
    });
  });

  group('App Colors Tests', () {
    test('Primary color is defined', () {
      expect(AppColors.primary, isNotNull);
    });

    test('Blood type colors are defined', () {
      expect(AppColors.bloodTypeA, isNotNull);
      expect(AppColors.bloodTypeB, isNotNull);
      expect(AppColors.bloodTypeAB, isNotNull);
      expect(AppColors.bloodTypeO, isNotNull);
    });
  });
}
