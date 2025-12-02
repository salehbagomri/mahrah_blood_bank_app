import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

/// مساعد إعادة المحاولة للعمليات الفاشلة
class RetryHelper {
  /// تنفيذ عملية مع إعادة محاولة تلقائية
  ///
  /// [operation]: العملية المطلوب تنفيذها
  /// [maxRetries]: عدد المحاولات القصوى (افتراضي: 3)
  /// [delayFactor]: معامل التأخير بين المحاولات (افتراضي: 1 ثانية)
  /// [shouldRetry]: دالة اختيارية للتحقق إذا كان يجب إعادة المحاولة
  static Future<T> retry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
    bool exponentialBackoff = true,
    bool Function(dynamic error)? shouldRetry,
  }) async {
    int attempt = 0;
    dynamic lastError;

    while (attempt < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        lastError = e;
        attempt++;

        // تحقق إذا كان يجب إعادة المحاولة
        if (shouldRetry != null && !shouldRetry(e)) {
          rethrow;
        }

        // إذا وصلنا للحد الأقصى، نرمي الخطأ
        if (attempt >= maxRetries) {
          rethrow;
        }

        // حساب وقت الانتظار
        final delay = exponentialBackoff
            ? initialDelay * (1 << (attempt - 1)) // تضاعف أسي: 1s, 2s, 4s
            : initialDelay;

        debugPrint(
          '⚠️ المحاولة $attempt من $maxRetries فشلت. إعادة المحاولة بعد ${delay.inSeconds} ثانية...',
        );

        await Future.delayed(delay);
      }
    }

    // هذا السطر لن يتم الوصول إليه أبداً، لكنه مطلوب للتحليل الثابت
    throw lastError;
  }

  /// إعادة المحاولة فقط لأخطاء الشبكة
  static Future<T> retryOnNetworkError<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
  }) async {
    return retry<T>(
      operation,
      maxRetries: maxRetries,
      shouldRetry: (error) {
        // إعادة المحاولة فقط لأخطاء الشبكة
        return error is SocketException ||
               error is TimeoutException ||
               (error is Exception &&
                error.toString().toLowerCase().contains('network'));
      },
    );
  }

  /// إعادة المحاولة مع timeout
  static Future<T> retryWithTimeout<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    return retry<T>(
      () => operation().timeout(
        timeout,
        onTimeout: () {
          throw TimeoutException(
            'انتهت مهلة العملية بعد ${timeout.inSeconds} ثانية',
          );
        },
      ),
      maxRetries: maxRetries,
      shouldRetry: (error) => error is TimeoutException || error is SocketException,
    );
  }
}
