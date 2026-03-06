import 'package:flutter/foundation.dart';
import '../models/statistics_model.dart';
import '../services/statistics_service.dart';
import '../utils/error_handler.dart';
import '../config/service_locator.dart';

/// Provider لإدارة حالة الإحصائيات
class StatisticsProvider with ChangeNotifier {
  final StatisticsService _statisticsService = getIt<StatisticsService>();

  StatisticsModel? _statistics;
  bool _isLoading = false;
  String? _errorMessage;

  DateTime? _lastFetchTime;
  final Duration _cacheDuration = const Duration(minutes: 10);

  // Getters
  StatisticsModel? get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  /// الحصول على الإحصائيات
  Future<void> loadStatistics({bool forceRefresh = false}) async {
    if (!forceRefresh && _statistics != null && _lastFetchTime != null) {
      if (DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
        return; // Use cached data
      }
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _statistics = await _statisticsService.getStatistics();
      _lastFetchTime = DateTime.now();
    } catch (e) {
      // في حالة فشل الدالة المخصصة، نستخدم الطريقة البسيطة
      try {
        _statistics = await _statisticsService.getSimpleStatistics();
        _lastFetchTime = DateTime.now();
      } catch (e2, stackTrace2) {
        _errorMessage = ErrorHandler.getArabicMessage(e2);
        ErrorHandler.logError(e2, stackTrace2);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تحديث الإحصائيات (كل 10 دقائق حسب المواصفات)
  Future<void> refreshStatistics() async {
    await loadStatistics(forceRefresh: true);
  }

  /// مسح رسالة الخطأ
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
