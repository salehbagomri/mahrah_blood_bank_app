import 'package:flutter/foundation.dart';
import '../models/statistics_model.dart';
import '../services/statistics_service.dart';
import '../utils/error_handler.dart';

/// Provider لإدارة حالة الإحصائيات
class StatisticsProvider with ChangeNotifier {
  final StatisticsService _statisticsService = StatisticsService();

  StatisticsModel? _statistics;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  StatisticsModel? get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  /// الحصول على الإحصائيات
  Future<void> loadStatistics() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _statistics = await _statisticsService.getStatistics();
    } catch (e, stackTrace) {
      // في حالة فشل الدالة المخصصة، نستخدم الطريقة البسيطة
      try {
        _statistics = await _statisticsService.getSimpleStatistics();
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
    await loadStatistics();
  }

  /// مسح رسالة الخطأ
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

