import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'error_handler.dart';

/// مسجل الأخطاء عبر Firebase Crashlytics
///
/// يرسل الأخطاء المهمة إلى Firebase للمتابعة والتحليل
class FirebaseErrorLogger {
  static final FirebaseErrorLogger _instance = FirebaseErrorLogger._internal();
  factory FirebaseErrorLogger() => _instance;
  FirebaseErrorLogger._internal();

  /// تهيئة Crashlytics
  static Future<void> initialize() async {
    if (kDebugMode) {
      // في وضع التطوير، نعطل Crashlytics لتجنب إرسال الأخطاء التجريبية
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
      debugPrint('🔧 Firebase Crashlytics معطل في وضع التطوير');
    } else {
      // في الإنتاج، نفعل Crashlytics
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      debugPrint('✅ Firebase Crashlytics مفعّل في الإنتاج');
    }

    // التقاط جميع أخطاء Flutter التلقائية
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);

      // أيضاً نطبع في Console
      debugPrint('═══════════════════════════════════════════');
      debugPrint('❌ خطأ Flutter تلقائي:');
      debugPrint('📝 ${errorDetails.exception}');
      debugPrint('📚 Stack: ${errorDetails.stack}');
      debugPrint('═══════════════════════════════════════════');
    };

    // التقاط الأخطاء خارج Flutter (Platform/Native errors)
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);

      debugPrint('═══════════════════════════════════════════');
      debugPrint('❌ خطأ Platform:');
      debugPrint('📝 $error');
      debugPrint('📚 Stack: $stack');
      debugPrint('═══════════════════════════════════════════');

      return true;
    };
  }

  /// تسجيل خطأ في Crashlytics
  static Future<void> logError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
    Map<String, dynamic>? context,
    bool fatal = false,
  }) async {
    try {
      // في وضع التطوير، نطبع فقط في Console
      if (kDebugMode) {
        debugPrint('═══════════════════════════════════════════');
        debugPrint('❌ خطأ: ${ErrorHandler.getArabicMessage(error)}');
        debugPrint('🔍 نوع الخطأ: ${ErrorHandler.getErrorType(error)}');
        debugPrint('📝 التفاصيل التقنية: $error');
        if (reason != null) debugPrint('💡 السبب: $reason');
        if (context != null) debugPrint('📋 السياق: $context');
        if (stackTrace != null) debugPrint('📚 Stack Trace:\n$stackTrace');
        debugPrint('═══════════════════════════════════════════');
        return;
      }

      // في الإنتاج، نرسل إلى Crashlytics
      final crashlytics = FirebaseCrashlytics.instance;

      // تسجيل السياق إذا وُجد
      if (context != null) {
        for (var entry in context.entries) {
          await crashlytics.setCustomKey(entry.key, entry.value.toString());
        }
      }

      // تسجيل السبب
      if (reason != null) {
        await crashlytics.setCustomKey('error_reason', reason);
      }

      // تسجيل معلومات إضافية
      await crashlytics.setCustomKey('error_type', ErrorHandler.getErrorType(error).toString());
      await crashlytics.setCustomKey('arabic_message', ErrorHandler.getArabicMessage(error));

      // تسجيل الخطأ
      await crashlytics.recordError(
        error,
        stackTrace,
        reason: reason,
        fatal: fatal,
      );

      debugPrint('📤 تم إرسال الخطأ إلى Firebase Crashlytics');
    } catch (e) {
      debugPrint('⚠️ فشل إرسال الخطأ إلى Crashlytics: $e');
    }
  }

  /// تسجيل حدث مخصص (لتتبع المشاكل غير الخطيرة)
  static Future<void> log(String message, {Map<String, dynamic>? parameters}) async {
    try {
      if (kDebugMode) {
        debugPrint('📝 Log: $message ${parameters ?? ""}');
        return;
      }

      await FirebaseCrashlytics.instance.log(message);

      if (parameters != null) {
        for (var entry in parameters.entries) {
          await FirebaseCrashlytics.instance.setCustomKey(
            entry.key,
            entry.value.toString(),
          );
        }
      }
    } catch (e) {
      debugPrint('⚠️ فشل تسجيل Log: $e');
    }
  }

  /// تعيين معلومات المستخدم (للتتبع في Crashlytics)
  static Future<void> setUserInfo({
    required String userId,
    String? email,
    String? name,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('👤 User Info: ID=$userId, Name=$name');
        return;
      }

      final crashlytics = FirebaseCrashlytics.instance;
      await crashlytics.setUserIdentifier(userId);

      if (email != null) {
        await crashlytics.setCustomKey('user_email', email);
      }

      if (name != null) {
        await crashlytics.setCustomKey('user_name', name);
      }
    } catch (e) {
      debugPrint('⚠️ فشل تعيين معلومات المستخدم: $e');
    }
  }

  /// مسح معلومات المستخدم (عند تسجيل الخروج)
  static Future<void> clearUserInfo() async {
    try {
      if (kDebugMode) {
        debugPrint('🧹 تم مسح معلومات المستخدم');
        return;
      }

      await FirebaseCrashlytics.instance.setUserIdentifier('');
    } catch (e) {
      debugPrint('⚠️ فشل مسح معلومات المستخدم: $e');
    }
  }

  /// إجبار إرسال crash (للاختبار فقط)
  static void testCrash() {
    if (kDebugMode) {
      debugPrint('⚠️ اختبار Crash معطل في وضع التطوير');
      return;
    }

    FirebaseCrashlytics.instance.crash();
  }
}
