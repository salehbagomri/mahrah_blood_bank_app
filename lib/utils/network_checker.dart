import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

/// فاحص الاتصال بالإنترنت
///
/// يوفر طرق للتحقق من الاتصال بالإنترنت ومراقبة التغيرات
class NetworkChecker {
  static final NetworkChecker _instance = NetworkChecker._internal();
  factory NetworkChecker() => _instance;
  NetworkChecker._internal();

  /// Stream controller لمراقبة حالة الاتصال
  final _connectionController = StreamController<bool>.broadcast();

  /// الحالة الحالية للاتصال
  bool _isConnected = true;

  /// آخر وقت تم فيه الفحص
  DateTime? _lastCheckTime;

  /// مدة الانتظار قبل إعادة الفحص (لتجنب الفحص المتكرر)
  static const _checkCooldown = Duration(seconds: 3);

  /// Stream للاستماع لتغيرات الاتصال
  Stream<bool> get connectionStream => _connectionController.stream;

  /// الحالة الحالية للاتصال
  bool get isConnected => _isConnected;

  /// التحقق من الاتصال بالإنترنت
  ///
  /// يحاول الاتصال بعدة خوادم موثوقة:
  /// 1. Google DNS (8.8.8.8)
  /// 2. Cloudflare DNS (1.1.1.1)
  /// 3. Google.com
  Future<bool> checkConnection() async {
    // تجنب الفحص المتكرر
    if (_lastCheckTime != null) {
      final timeSinceLastCheck = DateTime.now().difference(_lastCheckTime!);
      if (timeSinceLastCheck < _checkCooldown) {
        return _isConnected;
      }
    }

    try {
      // محاولة 1: Google DNS (الأسرع)
      final result = await InternetAddress.lookup('8.8.8.8')
          .timeout(const Duration(seconds: 5));

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _updateConnectionStatus(true);
        return true;
      }
    } catch (e) {
      debugPrint('فحص Google DNS فشل: $e');
    }

    try {
      // محاولة 2: Cloudflare DNS
      final result = await InternetAddress.lookup('1.1.1.1')
          .timeout(const Duration(seconds: 5));

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _updateConnectionStatus(true);
        return true;
      }
    } catch (e) {
      debugPrint('فحص Cloudflare DNS فشل: $e');
    }

    try {
      // محاولة 3: Google.com
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _updateConnectionStatus(true);
        return true;
      }
    } catch (e) {
      debugPrint('فحص Google.com فشل: $e');
    }

    // جميع المحاولات فشلت
    _updateConnectionStatus(false);
    return false;
  }

  /// التحقق السريع من الاتصال (محاولة واحدة فقط)
  Future<bool> quickCheck() async {
    try {
      final result = await InternetAddress.lookup('8.8.8.8')
          .timeout(const Duration(seconds: 3));

      final connected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      _updateConnectionStatus(connected);
      return connected;
    } catch (e) {
      _updateConnectionStatus(false);
      return false;
    }
  }

  /// تحديث حالة الاتصال
  void _updateConnectionStatus(bool connected) {
    _lastCheckTime = DateTime.now();

    if (_isConnected != connected) {
      _isConnected = connected;
      _connectionController.add(connected);

      debugPrint('📡 حالة الاتصال: ${connected ? "متصل ✅" : "غير متصل ❌"}');
    }
  }

  /// إعادة تعيين وقت آخر فحص (للسماح بفحص فوري)
  void resetCooldown() {
    _lastCheckTime = null;
  }

  /// تنظيف الموارد
  void dispose() {
    _connectionController.close();
  }
}

/// Extension لسهولة الوصول من BuildContext
extension NetworkCheckerContext on BuildContext {
  /// التحقق من الاتصال بالإنترنت
  Future<bool> checkInternetConnection() async {
    return await NetworkChecker().checkConnection();
  }

  /// فحص سريع للاتصال
  Future<bool> quickCheckConnection() async {
    return await NetworkChecker().quickCheck();
  }
}
