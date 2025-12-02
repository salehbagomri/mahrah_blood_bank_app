import 'donor_model.dart';

/// نموذج إحصائيات لوحة المستشفى
class DashboardStatisticsModel {
  final int totalDonors;
  final int availableDonors;
  final int suspendedDonors;
  final int inactiveDonors; // الحسابات المعطلة
  final int newDonorsThisMonth;
  final String? mostCommonBloodType;
  final int mostCommonBloodTypeCount;
  final int coveredDistrictsCount;
  final Map<String, int> bloodTypeDistribution;
  final Map<String, int> districtDistribution;
  final List<DonorModel> recentDonors;
  final List<DonorModel> recentDonations;
  final DateTime lastUpdated;

  DashboardStatisticsModel({
    required this.totalDonors,
    required this.availableDonors,
    required this.suspendedDonors,
    this.inactiveDonors = 0, // القيمة الافتراضية 0 للتوافق مع الكود القديم
    required this.newDonorsThisMonth,
    this.mostCommonBloodType,
    required this.mostCommonBloodTypeCount,
    required this.coveredDistrictsCount,
    required this.bloodTypeDistribution,
    required this.districtDistribution,
    required this.recentDonors,
    required this.recentDonations,
    required this.lastUpdated,
  });

  /// نسخة من الكائن مع تحديث بعض الحقول
  DashboardStatisticsModel copyWith({
    int? totalDonors,
    int? availableDonors,
    int? suspendedDonors,
    int? inactiveDonors,
    int? newDonorsThisMonth,
    String? mostCommonBloodType,
    int? mostCommonBloodTypeCount,
    int? coveredDistrictsCount,
    Map<String, int>? bloodTypeDistribution,
    Map<String, int>? districtDistribution,
    List<DonorModel>? recentDonors,
    List<DonorModel>? recentDonations,
    DateTime? lastUpdated,
  }) {
    return DashboardStatisticsModel(
      totalDonors: totalDonors ?? this.totalDonors,
      availableDonors: availableDonors ?? this.availableDonors,
      suspendedDonors: suspendedDonors ?? this.suspendedDonors,
      inactiveDonors: inactiveDonors ?? this.inactiveDonors,
      newDonorsThisMonth: newDonorsThisMonth ?? this.newDonorsThisMonth,
      mostCommonBloodType: mostCommonBloodType ?? this.mostCommonBloodType,
      mostCommonBloodTypeCount: mostCommonBloodTypeCount ?? this.mostCommonBloodTypeCount,
      coveredDistrictsCount: coveredDistrictsCount ?? this.coveredDistrictsCount,
      bloodTypeDistribution: bloodTypeDistribution ?? this.bloodTypeDistribution,
      districtDistribution: districtDistribution ?? this.districtDistribution,
      recentDonors: recentDonors ?? this.recentDonors,
      recentDonations: recentDonations ?? this.recentDonations,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
