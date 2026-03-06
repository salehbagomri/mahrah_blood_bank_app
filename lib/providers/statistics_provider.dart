import 'package:flutter/foundation.dart';
import '../models/statistics_model.dart';
import '../services/statistics_service.dart';
import '../services/cache_service.dart';
import '../services/connectivity_service.dart';
import '../utils/error_handler.dart';
import '../config/service_locator.dart';

/// Provider لإدارة حالة الإحصائيات مع دعم Offline Mode
class StatisticsProvider with ChangeNotifier {
  final StatisticsService _statisticsService = getIt<StatisticsService>();
  final CacheService _cacheService = getIt<CacheService>();
  final ConnectivityService _connectivityService = getIt<ConnectivityService>();

  StatisticsModel? _statistics;
  bool _isLoading = false;
  bool _isOffline = false;
  String? _errorMessage;

  DateTime? _lastFetchTime;
  final Duration _cacheDuration = const Duration(minutes: 10);

  // Getters
  StatisticsModel? get statistics => _statistics;
  bool get isLoading => _isLoading;
  bool get isOffline => _isOffline;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  /// الحصول على الإحصائيات - Cache First, Network Second
  Future<void> loadStatistics({bool forceRefresh = false}) async {
    // 1) في الذاكرة وحديث → استخدمه
    if (!forceRefresh && _statistics != null && _lastFetchTime != null) {
      if (DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
        return;
      }
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // 2) لا يوجد اتصال → استخدم Hive cache
    if (!_connectivityService.isConnected) {
      _isOffline = true;
      final cached = _cacheService.getCachedStatistics();
      if (cached != null) {
        _statistics = cached;
        _isLoading = false;
        notifyListeners();
        return;
      }
      _errorMessage = 'لا يوجد اتصال بالإنترنت';
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isOffline = false;

    // 3) عرض الكاش فوراً أثناء التحديث من الشبكة
    if (_statistics == null) {
      final cached = _cacheService.getCachedStatistics();
      if (cached != null) {
        _statistics = cached;
        notifyListeners();
      }
    }

    try {
      // 4) جلب من الشبكة
      _statistics = await _statisticsService.getStatistics();
      _lastFetchTime = DateTime.now();
      // 5) حفظ في Hive
      await _cacheService.saveStatistics(_statistics!);
    } catch (e) {
      // في حالة فشل الخدمة، نستخدم الطريقة البسيطة
      try {
        _statistics = await _statisticsService.getSimpleStatistics();
        _lastFetchTime = DateTime.now();
        await _cacheService.saveStatistics(_statistics!);
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
