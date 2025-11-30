import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/donor_model.dart';
import 'supabase_service.dart';

/// خدمة إدارة المتبرعين
class DonorService {
  final SupabaseService _supabaseService = SupabaseService();
  SupabaseClient get _client => _supabaseService.client;

  /// البحث عن متبرعين
  /// 
  /// [bloodType] - فصيلة الدم المطلوبة
  /// [district] - المديرية المطلوبة
  /// [availableOnly] - البحث عن المتبرعين المتاحين فقط
  Future<List<DonorModel>> searchDonors({
    String? bloodType,
    String? district,
    bool availableOnly = true,
  }) async {
    try {
      // استخدام الدالة المخصصة search_donors
      final response = await _client.rpc(
        'search_donors',
        params: {
          'p_blood_type': bloodType,
          'p_district': district,
          'p_available_only': availableOnly,
        },
      ).select();

      return (response as List)
          .map((json) => DonorModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('فشل البحث عن المتبرعين: ${e.toString()}');
    }
  }

  /// الحصول على متبرع واحد حسب المعرف
  Future<DonorModel?> getDonorById(String id) async {
    try {
      final response = await _client
          .from('donors')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return DonorModel.fromJson(response);
    } catch (e) {
      throw Exception('فشل الحصول على بيانات المتبرع: ${e.toString()}');
    }
  }

  /// إضافة متبرع جديد
  Future<DonorModel> addDonor(DonorModel donor) async {
    try {
      final response = await _client
          .from('donors')
          .insert({
            'name': donor.name,
            'phone_number': donor.phoneNumber,
            'blood_type': donor.bloodType,
            'district': donor.district,
            'age': donor.age,
            'gender': donor.gender,
            'notes': donor.notes,
            'added_by': _supabaseService.currentUserId,
          })
          .select()
          .single();

      return DonorModel.fromJson(response);
    } catch (e) {
      if (e.toString().contains('duplicate key')) {
        throw Exception('رقم الهاتف مسجل بالفعل');
      }
      throw Exception('فشل إضافة المتبرع: ${e.toString()}');
    }
  }

  /// تحديث بيانات متبرع
  Future<DonorModel> updateDonor(DonorModel donor) async {
    try {
      final response = await _client
          .from('donors')
          .update({
            'name': donor.name,
            'phone_number': donor.phoneNumber,
            'blood_type': donor.bloodType,
            'district': donor.district,
            'age': donor.age,
            'gender': donor.gender,
            'notes': donor.notes,
            'is_available': donor.isAvailable,
            'last_donation_date': donor.lastDonationDate?.toIso8601String(),
            'suspended_until': donor.suspendedUntil?.toIso8601String(),
            'is_active': donor.isActive,
          })
          .eq('id', donor.id)
          .select()
          .single();

      return DonorModel.fromJson(response);
    } catch (e) {
      throw Exception('فشل تحديث بيانات المتبرع: ${e.toString()}');
    }
  }

  /// البحث عن متبرع برقم الهاتف
  Future<DonorModel?> findDonorByPhone(String phoneNumber) async {
    try {
      final response = await _client
          .from('donors')
          .select()
          .eq('phone_number', phoneNumber)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return DonorModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// حذف متبرع (الأدمن فقط)
  Future<void> deleteDonor(String id) async {
    try {
      await _client
          .from('donors')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('فشل حذف المتبرع: ${e.toString()}');
    }
  }

  /// إيقاف متبرع لمدة 6 أشهر
  Future<DonorModel> suspendDonorFor6Months(String id) async {
    try {
      final suspendedUntil = DateTime.now().add(const Duration(days: 180));
      
      final response = await _client
          .from('donors')
          .update({
            'suspended_until': suspendedUntil.toIso8601String(),
            'last_donation_date': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      return DonorModel.fromJson(response);
    } catch (e) {
      throw Exception('فشل إيقاف المتبرع: ${e.toString()}');
    }
  }

  /// الحصول على المتبرعين الموقوفين
  Future<List<DonorModel>> getSuspendedDonors() async {
    try {
      final now = DateTime.now().toIso8601String();
      
      final response = await _client
          .from('donors')
          .select()
          .not('suspended_until', 'is', null)
          .gt('suspended_until', now)
          .order('suspended_until', ascending: true);

      return (response as List)
          .map((json) => DonorModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('فشل الحصول على المتبرعين الموقوفين: ${e.toString()}');
    }
  }

  /// الحصول على جميع المتبرعين (للمستشفى والأدمن)
  Future<List<DonorModel>> getAllDonors({
    int? limit,
    int? offset,
  }) async {
    try {
      var query = _client
          .from('donors')
          .select()
          .order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 50) - 1);
      }

      final response = await query;

      return (response as List)
          .map((json) => DonorModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('فشل الحصول على المتبرعين: ${e.toString()}');
    }
  }

  /// البحث بالاسم أو رقم الهاتف
  Future<List<DonorModel>> searchByNameOrPhone(String query) async {
    try {
      final response = await _client
          .from('donors')
          .select()
          .or('name.ilike.%$query%,phone_number.ilike.%$query%')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => DonorModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('فشل البحث: ${e.toString()}');
    }
  }

  /// الحصول على عدد المتبرعين حسب فصيلة الدم
  Future<Map<String, int>> getDonorCountByBloodType() async {
    try {
      final response = await _client
          .from('donors')
          .select('blood_type')
          .eq('is_active', true);

      final Map<String, int> counts = {};
      
      for (var donor in response as List) {
        final bloodType = donor['blood_type'] as String;
        counts[bloodType] = (counts[bloodType] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      throw Exception('فشل الحصول على الإحصائيات: ${e.toString()}');
    }
  }

  /// الحصول على عدد المتبرعين حسب المديرية
  Future<Map<String, int>> getDonorCountByDistrict() async {
    try {
      final response = await _client
          .from('donors')
          .select('district')
          .eq('is_active', true);

      final Map<String, int> counts = {};
      
      for (var donor in response as List) {
        final district = donor['district'] as String;
        counts[district] = (counts[district] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      throw Exception('فشل الحصول على الإحصائيات: ${e.toString()}');
    }
  }
}

