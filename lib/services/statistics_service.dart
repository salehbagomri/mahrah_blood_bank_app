import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/statistics_model.dart';
import 'supabase_service.dart';

/// خدمة الإحصائيات
class StatisticsService {
  final SupabaseService _supabaseService = SupabaseService();
  SupabaseClient get _client => _supabaseService.client;

  /// الحصول على الإحصائيات العامة
  Future<StatisticsModel> getStatistics() async {
    try {
      // استخدام الدالة المخصصة get_statistics
      final response = await _client.rpc('get_statistics').single();

      return StatisticsModel.fromJson(response);
    } catch (e) {
      throw Exception('فشل الحصول على الإحصائيات: ${e.toString()}');
    }
  }

  /// الحصول على إحصائيات بسيطة (بدون استخدام الدالة)
  Future<StatisticsModel> getSimpleStatistics() async {
    try {
      // إجمالي المتبرعين
      final totalDonorsResponse = await _client
          .from('donors')
          .select('id')
          .eq('is_active', true)
          .count();

      final totalDonors = totalDonorsResponse.count;

      // أكثر فصيلة متوفرة
      final bloodTypeResponse = await _client
          .from('donors')
          .select('blood_type')
          .eq('is_active', true);

      final Map<String, int> bloodTypeCount = {};
      for (var donor in bloodTypeResponse as List) {
        final bloodType = donor['blood_type'] as String;
        bloodTypeCount[bloodType] = (bloodTypeCount[bloodType] ?? 0) + 1;
      }

      String? mostCommonBloodType;
      int mostCommonBloodTypeCount = 0;
      if (bloodTypeCount.isNotEmpty) {
        final maxEntry = bloodTypeCount.entries
            .reduce((a, b) => a.value > b.value ? a : b);
        mostCommonBloodType = maxEntry.key;
        mostCommonBloodTypeCount = maxEntry.value;
      }

      // أكثر مديرية نشاطاً
      final districtResponse = await _client
          .from('donors')
          .select('district')
          .eq('is_active', true);

      final Map<String, int> districtCount = {};
      for (var donor in districtResponse as List) {
        final district = donor['district'] as String;
        districtCount[district] = (districtCount[district] ?? 0) + 1;
      }

      String? mostActiveDistrict;
      int mostActiveDistrictCount = 0;
      if (districtCount.isNotEmpty) {
        final maxEntry = districtCount.entries
            .reduce((a, b) => a.value > b.value ? a : b);
        mostActiveDistrict = maxEntry.key;
        mostActiveDistrictCount = maxEntry.value;
      }

      // أحدث متبرع
      final latestDonorResponse = await _client
          .from('donors')
          .select('name, created_at')
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      String? latestDonorName;
      DateTime? latestDonorDate;
      if (latestDonorResponse != null) {
        latestDonorName = latestDonorResponse['name'] as String;
        latestDonorDate = DateTime.parse(latestDonorResponse['created_at'] as String);
      }

      return StatisticsModel(
        totalDonors: totalDonors,
        mostCommonBloodType: mostCommonBloodType,
        mostCommonBloodTypeCount: mostCommonBloodTypeCount,
        mostActiveDistrict: mostActiveDistrict,
        mostActiveDistrictCount: mostActiveDistrictCount,
        latestDonorName: latestDonorName,
        latestDonorDate: latestDonorDate,
        bloodTypeDistribution: bloodTypeCount,
        districtDistribution: districtCount,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      throw Exception('فشل الحصول على الإحصائيات: ${e.toString()}');
    }
  }
}

