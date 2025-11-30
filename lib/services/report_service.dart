import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/report_model.dart';
import 'supabase_service.dart';

/// خدمة البلاغات
class ReportService {
  final SupabaseService _supabaseService = SupabaseService();
  SupabaseClient get _client => _supabaseService.client;

  /// إضافة بلاغ جديد
  Future<ReportModel> addReport({
    required String donorId,
    required String donorPhoneNumber,
    required String reason,
    String? notes,
  }) async {
    try {
      final response = await _client
          .from('reports')
          .insert({
            'donor_id': donorId,
            'donor_phone_number': donorPhoneNumber,
            'reason': reason,
            'notes': notes,
          })
          .select()
          .single();

      return ReportModel.fromJson(response);
    } catch (e) {
      throw Exception('فشل إرسال البلاغ: ${e.toString()}');
    }
  }

  /// الحصول على جميع البلاغات (للأدمن فقط)
  Future<List<ReportModel>> getAllReports({
    String? status,
    int? limit,
  }) async {
    try {
      dynamic query = _client.from('reports').select();

      if (status != null) {
        query = query.eq('status', status);
      }

      query = query.order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      return (response as List)
          .map((json) => ReportModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('فشل الحصول على البلاغات: ${e.toString()}');
    }
  }

  /// الحصول على البلاغات المعلقة (pending)
  Future<List<ReportModel>> getPendingReports() async {
    return getAllReports(status: 'pending');
  }

  /// قبول بلاغ
  Future<ReportModel> approveReport(String reportId) async {
    try {
      final response = await _client
          .from('reports')
          .update({
            'status': 'approved',
            'reviewed_by': _supabaseService.currentUserId,
            'reviewed_at': DateTime.now().toIso8601String(),
          })
          .eq('id', reportId)
          .select()
          .single();

      return ReportModel.fromJson(response);
    } catch (e) {
      throw Exception('فشل قبول البلاغ: ${e.toString()}');
    }
  }

  /// رفض بلاغ
  Future<ReportModel> rejectReport(String reportId) async {
    try {
      final response = await _client
          .from('reports')
          .update({
            'status': 'rejected',
            'reviewed_by': _supabaseService.currentUserId,
            'reviewed_at': DateTime.now().toIso8601String(),
          })
          .eq('id', reportId)
          .select()
          .single();

      return ReportModel.fromJson(response);
    } catch (e) {
      throw Exception('فشل رفض البلاغ: ${e.toString()}');
    }
  }

  /// الحصول على البلاغات الخاصة بمتبرع معين
  Future<List<ReportModel>> getReportsByDonorId(String donorId) async {
    try {
      final response = await _client
          .from('reports')
          .select()
          .eq('donor_id', donorId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ReportModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('فشل الحصول على البلاغات: ${e.toString()}');
    }
  }

  /// حذف بلاغ
  Future<void> deleteReport(String reportId) async {
    try {
      await _client
          .from('reports')
          .delete()
          .eq('id', reportId);
    } catch (e) {
      throw Exception('فشل حذف البلاغ: ${e.toString()}');
    }
  }

  /// الحصول على عدد البلاغات المعلقة
  Future<int> getPendingReportsCount() async {
    try {
      final response = await _client
          .from('reports')
          .select('id')
          .eq('status', 'pending')
          .count();

      return response.count;
    } catch (e) {
      throw Exception('فشل الحصول على عدد البلاغات: ${e.toString()}');
    }
  }
}

