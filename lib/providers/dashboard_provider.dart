import 'package:flutter/foundation.dart';
import '../models/dashboard_statistics_model.dart';
import '../models/donor_model.dart';
import '../models/statistics_model.dart';
import '../services/donor_service.dart';
import '../services/statistics_service.dart';

/// Provider لإدارة حالة لوحة المستشفى
class DashboardProvider with ChangeNotifier {
  final DonorService _donorService = DonorService();
  final StatisticsService _statisticsService = StatisticsService();

  DashboardStatisticsModel? _statistics;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  DashboardStatisticsModel? get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  /// تحميل جميع بيانات الـ Dashboard بالتوازي
  Future<void> loadDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // تحميل جميع البيانات بالتوازي باستخدام Future.wait
      final results = await Future.wait([
        _statisticsService.getSimpleStatistics(),        // 0
        _donorService.getAvailableDonorsCount(),         // 1
        _donorService.getSuspendedDonors(),              // 2
        _donorService.getNewDonorsThisMonth(),           // 3
        _donorService.getCoveredDistrictsCount(),        // 4
        _donorService.getRecentDonors(limit: 5),         // 5
        _donorService.getRecentDonations(limit: 5),      // 6
        _donorService.getInactiveDonorsCount(),          // 7
      ]);

      final stats = results[0] as StatisticsModel;
      final recentDonors = results[5] as List<DonorModel>;
      final recentDonations = results[6] as List<DonorModel>;

      _statistics = DashboardStatisticsModel(
        totalDonors: stats.totalDonors,
        availableDonors: results[1] as int,
        suspendedDonors: (results[2] as List).length,
        inactiveDonors: results[7] as int,
        newDonorsThisMonth: results[3] as int,
        mostCommonBloodType: stats.mostCommonBloodType,
        mostCommonBloodTypeCount: stats.mostCommonBloodTypeCount,
        coveredDistrictsCount: results[4] as int,
        bloodTypeDistribution: stats.bloodTypeDistribution,
        districtDistribution: stats.districtDistribution,
        recentDonors: recentDonors,
        recentDonations: recentDonations,
        lastUpdated: DateTime.now(),
      );

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'فشل تحميل البيانات: ${e.toString()}';
      debugPrint('Error loading dashboard data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تحديث البيانات (refresh)
  Future<void> refreshDashboard() async {
    await loadDashboardData();
  }

  /// مسح رسالة الخطأ
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
