/// نموذج بيانات البلاغات
class ReportModel {
  final String id;
  final String donorId;
  final String donorPhoneNumber; // نسخة من رقم المتبرع وقت الإبلاغ
  final String reason; // السبب: number_not_working, wrong_number, refuses_to_donate, other
  final String? notes;
  final String status; // pending, approved, rejected
  final String? reviewedBy; // معرف الأدمن الذي راجع البلاغ
  final DateTime? reviewedAt;
  final DateTime createdAt;

  ReportModel({
    required this.id,
    required this.donorId,
    required this.donorPhoneNumber,
    required this.reason,
    this.notes,
    this.status = 'pending',
    this.reviewedBy,
    this.reviewedAt,
    required this.createdAt,
  });

  /// تحويل من JSON إلى Model
  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as String,
      donorId: json['donor_id'] as String,
      donorPhoneNumber: json['donor_phone_number'] as String,
      reason: json['reason'] as String,
      notes: json['notes'] as String?,
      status: json['status'] as String? ?? 'pending',
      reviewedBy: json['reviewed_by'] as String?,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// تحويل من Model إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'donor_id': donorId,
      'donor_phone_number': donorPhoneNumber,
      'reason': reason,
      'notes': notes,
      'status': status,
      'reviewed_by': reviewedBy,
      'reviewed_at': reviewedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// نسخ مع تعديل بعض الحقول
  ReportModel copyWith({
    String? id,
    String? donorId,
    String? donorPhoneNumber,
    String? reason,
    String? notes,
    String? status,
    String? reviewedBy,
    DateTime? reviewedAt,
    DateTime? createdAt,
  }) {
    return ReportModel(
      id: id ?? this.id,
      donorId: donorId ?? this.donorId,
      donorPhoneNumber: donorPhoneNumber ?? this.donorPhoneNumber,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// هل البلاغ قيد المراجعة؟
  bool get isPending => status == 'pending';

  /// هل تم قبول البلاغ؟
  bool get isApproved => status == 'approved';

  /// هل تم رفض البلاغ؟
  bool get isRejected => status == 'rejected';

  /// الحصول على نص السبب بالعربية
  String get reasonText {
    switch (reason) {
      case 'number_not_working':
        return 'الرقم لا يعمل';
      case 'wrong_number':
        return 'رقم خاطئ';
      case 'refuses_to_donate':
        return 'يرفض التبرع';
      case 'other':
        return 'أخرى';
      default:
        return reason;
    }
  }

  /// الحصول على نص الحالة بالعربية
  String get statusText {
    switch (status) {
      case 'pending':
        return 'قيد المراجعة';
      case 'approved':
        return 'تم القبول';
      case 'rejected':
        return 'تم الرفض';
      default:
        return status;
    }
  }
}

