import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';

/// خدمة التحديث الإجباري داخل التطبيق
/// تستخدم Google Play In-App Updates API
class UpdateService {
  /// التحقق من وجود تحديث وإجبار المستخدم على التحديث
  /// يُستدعى في initState للصفحة الرئيسية
  static Future<void> checkForUpdate(BuildContext context) async {
    // التحديث يعمل فقط على Android
    if (!Platform.isAndroid) return;

    try {
      final updateInfo = await InAppUpdate.checkForUpdate();

      debugPrint('📱 Update available: ${updateInfo.updateAvailability}');
      debugPrint('📱 Immediate allowed: ${updateInfo.immediateUpdateAllowed}');
      debugPrint('📱 Flexible allowed: ${updateInfo.flexibleUpdateAllowed}');

      // إذا يوجد تحديث متاح
      if (updateInfo.updateAvailability ==
          UpdateAvailability.updateAvailable) {
        // محاولة التحديث الفوري (Immediate) — يجبر المستخدم
        if (updateInfo.immediateUpdateAllowed) {
          try {
            await InAppUpdate.performImmediateUpdate();
            // إذا وصلنا هنا يعني المستخدم ثبّت التحديث
          } catch (e) {
            debugPrint('⚠️ Immediate update failed: $e');
            // إذا فشل الفوري، نجرب المرن
            if (updateInfo.flexibleUpdateAllowed) {
              await _performFlexibleUpdate();
            }
          }
        } else if (updateInfo.flexibleUpdateAllowed) {
          await _performFlexibleUpdate();
        }
      }
    } catch (e) {
      // التطبيق لم يُنشر بعد على Play Store أو خطأ آخر
      debugPrint('⚠️ In-app update check failed: $e');
      debugPrint('   (هذا طبيعي إذا التطبيق لم ينشر بعد على Play Store)');
    }
  }

  /// تحديث مرن (يحمّل في الخلفية ثم يطلب التثبيت)
  static Future<void> _performFlexibleUpdate() async {
    try {
      await InAppUpdate.startFlexibleUpdate();
      // بعد اكتمال التحميل، نطلب التثبيت
      await InAppUpdate.completeFlexibleUpdate();
    } catch (e) {
      debugPrint('⚠️ Flexible update failed: $e');
    }
  }
}
