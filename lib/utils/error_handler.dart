import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// أنواع الأخطاء
enum ErrorType {
  network,          // مشكلة في الاتصال بالإنترنت
  timeout,          // انتهت مهلة الاتصال
  permission,       // مشكلة في الصلاحيات
  duplicate,        // بيانات مكررة
  notFound,         // البيانات غير موجودة
  authentication,   // مشكلة في تسجيل الدخول
  server,           // خطأ من السيرفر
  validation,       // خطأ في البيانات المدخلة
  unknown,          // خطأ غير معروف
}

/// معالج الأخطاء المركزي
///
/// يحول جميع الأخطاء التقنية إلى رسائل عربية واضحة للمستخدم
class ErrorHandler {
  /// تحويل الخطأ إلى رسالة عربية واضحة
  static String getArabicMessage(dynamic error) {
    if (error == null) return 'حدث خطأ غير متوقع';

    // معالجة أخطاء الشبكة
    if (error is SocketException) {
      return 'لا يوجد اتصال بالإنترنت. يرجى التحقق من الاتصال والمحاولة مرة أخرى';
    }

    // معالجة انتهاء المهلة
    if (error is TimeoutException) {
      return 'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى';
    }

    // معالجة أخطاء Supabase (PostgreSQL)
    if (error is PostgrestException) {
      return _handlePostgrestException(error);
    }

    // معالجة أخطاء المصادقة
    if (error is AuthException) {
      return _handleAuthException(error);
    }

    // معالجة أخطاء التخزين
    if (error is StorageException) {
      return 'فشل في حفظ الملف. يرجى المحاولة مرة أخرى';
    }

    // معالجة أخطاء الصيغة
    if (error is FormatException) {
      return 'خطأ في صيغة البيانات المدخلة';
    }

    // معالجة Exception العامة
    if (error is Exception) {
      final message = error.toString().replaceFirst('Exception: ', '');

      // تحقق إذا كانت الرسالة بالعربية بالفعل
      if (_isArabic(message)) {
        return message;
      }

      // حاول استخراج معلومات مفيدة
      if (message.contains('JWT')) {
        return 'انتهت جلسة العمل. يرجى تسجيل الدخول مرة أخرى';
      }

      if (message.contains('duplicate') || message.contains('unique')) {
        return 'البيانات مكررة. هذا السجل موجود بالفعل';
      }

      if (message.contains('not found') || message.contains('404')) {
        return 'البيانات المطلوبة غير موجودة';
      }

      if (message.contains('permission') || message.contains('403')) {
        return 'ليس لديك صلاحية لتنفيذ هذا الإجراء';
      }

      return message;
    }

    // الحالة الافتراضية
    final errorString = error.toString();

    // تحقق إذا كانت الرسالة بالعربية بالفعل
    if (_isArabic(errorString)) {
      return errorString;
    }

    return 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى';
  }

  /// معالجة أخطاء PostgreSQL/Supabase
  static String _handlePostgrestException(PostgrestException error) {
    final code = error.code;
    final message = error.message;

    // أخطاء شائعة في PostgreSQL
    switch (code) {
      case '23505': // unique_violation
        return 'البيانات مكررة. هذا السجل موجود بالفعل';

      case '23503': // foreign_key_violation
        return 'لا يمكن تنفيذ هذا الإجراء بسبب ارتباطات أخرى';

      case '42501': // insufficient_privilege
        return 'ليس لديك صلاحية لتنفيذ هذا الإجراء';

      case '42P01': // undefined_table
        return 'خطأ في الخادم. يرجى المحاولة لاحقاً';

      case 'PGRST116': // no rows returned
        return 'البيانات المطلوبة غير موجودة';

      case 'PGRST301': // JWT expired
        return 'انتهت جلسة العمل. يرجى تسجيل الدخول مرة أخرى';

      default:
        // حاول استخراج معلومات من الرسالة
        if (message.toLowerCase().contains('duplicate')) {
          return 'البيانات مكررة. هذا السجل موجود بالفعل';
        }
        if (message.toLowerCase().contains('not found')) {
          return 'البيانات المطلوبة غير موجودة';
        }

        debugPrint('PostgrestException: code=$code, message=$message');
        return 'فشل في تنفيذ العملية. يرجى المحاولة مرة أخرى';
    }
  }

  /// معالجة أخطاء المصادقة
  static String _handleAuthException(AuthException error) {
    final message = error.message.toLowerCase();

    if (message.contains('invalid login credentials') ||
        message.contains('invalid email or password')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
    }

    if (message.contains('email not confirmed')) {
      return 'يجب تأكيد البريد الإلكتروني أولاً';
    }

    if (message.contains('user already registered')) {
      return 'هذا البريد الإلكتروني مسجل بالفعل';
    }

    if (message.contains('network request failed')) {
      return 'لا يوجد اتصال بالإنترنت';
    }

    if (message.contains('jwt')) {
      return 'انتهت جلسة العمل. يرجى تسجيل الدخول مرة أخرى';
    }

    debugPrint('AuthException: ${error.message}');
    return 'فشل تسجيل الدخول. يرجى المحاولة مرة أخرى';
  }

  /// تحديد نوع الخطأ
  static ErrorType getErrorType(dynamic error) {
    if (error is SocketException) return ErrorType.network;
    if (error is TimeoutException) return ErrorType.timeout;

    if (error is PostgrestException) {
      final code = error.code;
      if (code == '23505') return ErrorType.duplicate;
      if (code == '42501') return ErrorType.permission;
      if (code == 'PGRST116') return ErrorType.notFound;
      return ErrorType.server;
    }

    if (error is AuthException) return ErrorType.authentication;
    if (error is FormatException) return ErrorType.validation;

    if (error is Exception) {
      final message = error.toString().toLowerCase();
      if (message.contains('jwt')) return ErrorType.authentication;
      if (message.contains('duplicate')) return ErrorType.duplicate;
      if (message.contains('not found')) return ErrorType.notFound;
      if (message.contains('permission') || message.contains('403')) {
        return ErrorType.permission;
      }
    }

    return ErrorType.unknown;
  }

  /// الحصول على أيقونة مناسبة لنوع الخطأ
  static IconData getErrorIcon(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off_rounded;
      case ErrorType.timeout:
        return Icons.access_time_rounded;
      case ErrorType.permission:
        return Icons.lock_rounded;
      case ErrorType.duplicate:
        return Icons.content_copy_rounded;
      case ErrorType.notFound:
        return Icons.search_off_rounded;
      case ErrorType.authentication:
        return Icons.person_off_rounded;
      case ErrorType.server:
        return Icons.cloud_off_rounded;
      case ErrorType.validation:
        return Icons.error_outline_rounded;
      case ErrorType.unknown:
        return Icons.warning_rounded;
    }
  }

  /// الحصول على لون مناسب لنوع الخطأ
  static Color getErrorColor(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Colors.orange;
      case ErrorType.timeout:
        return Colors.amber;
      case ErrorType.permission:
        return Colors.red;
      case ErrorType.duplicate:
        return Colors.blue;
      case ErrorType.notFound:
        return Colors.grey;
      case ErrorType.authentication:
        return Colors.deepOrange;
      case ErrorType.server:
        return Colors.purple;
      case ErrorType.validation:
        return Colors.brown;
      case ErrorType.unknown:
        return Colors.red.shade700;
    }
  }

  /// الحصول على اقتراح حل للمستخدم
  static String getSuggestion(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return 'تحقق من الاتصال بالإنترنت أو Wi-Fi';
      case ErrorType.timeout:
        return 'تأكد من قوة الاتصال وحاول مرة أخرى';
      case ErrorType.permission:
        return 'اتصل بالإدارة إذا كنت بحاجة إلى صلاحيات إضافية';
      case ErrorType.duplicate:
        return 'السجل موجود بالفعل في النظام';
      case ErrorType.notFound:
        return 'قد يكون السجل محذوفاً أو غير موجود';
      case ErrorType.authentication:
        return 'تحقق من بيانات تسجيل الدخول';
      case ErrorType.server:
        return 'المشكلة من الخادم، حاول لاحقاً';
      case ErrorType.validation:
        return 'تحقق من البيانات المدخلة';
      case ErrorType.unknown:
        return 'حاول مرة أخرى، وإن استمرت المشكلة اتصل بالدعم';
    }
  }

  /// التحقق إذا كان النص يحتوي على أحرف عربية
  static bool _isArabic(String text) {
    // يتحقق إذا كان النص يحتوي على 30% أحرف عربية على الأقل
    if (text.isEmpty) return false;

    final arabicChars = text.runes.where((rune) {
      return rune >= 0x0600 && rune <= 0x06FF; // نطاق الأحرف العربية
    }).length;

    return arabicChars / text.length >= 0.3;
  }

  /// تسجيل الخطأ (للتطوير)
  static void logError(dynamic error, [StackTrace? stackTrace]) {
    debugPrint('═══════════════════════════════════════════');
    debugPrint('❌ خطأ: ${getArabicMessage(error)}');
    debugPrint('🔍 نوع الخطأ: ${getErrorType(error)}');
    debugPrint('📝 التفاصيل التقنية: $error');
    if (stackTrace != null) {
      debugPrint('📚 Stack Trace:\n$stackTrace');
    }
    debugPrint('═══════════════════════════════════════════');
  }
}
