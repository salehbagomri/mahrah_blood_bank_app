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
      case 'number_busy':
        return 'الرقم مشغول دائماً';
      case 'no_answer':
        return 'لا يرد على الاتصال';
      case 'deceased':
        return 'متوفى';
      case 'moved_away':
        return 'انتقل إلى منطقة أخرى';
      case 'health_issues':
        return 'مشاكل صحية';
      case 'other':
        return 'سبب آخر';
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

  /// الحصول على أولوية البلاغ
  String get priority {
    switch (reason) {
      case 'deceased':
        return 'critical'; // حرج
      case 'wrong_number':
      case 'number_not_working':
        return 'high'; // عالي
      case 'moved_away':
      case 'health_issues':
        return 'medium'; // متوسط
      default:
        return 'low'; // منخفض
    }
  }

  /// نص الأولوية بالعربية
  String get priorityText {
    switch (priority) {
      case 'critical':
        return 'حرج';
      case 'high':
        return 'عالي';
      case 'medium':
        return 'متوسط';
      case 'low':
        return 'منخفض';
      default:
        return priority;
    }
  }

  /// الإجراء المقترح بناءً على السبب
  String get suggestedAction {
    switch (reason) {
      case 'deceased':
        return 'delete'; // حذف
      case 'wrong_number':
      case 'number_not_working':
      case 'moved_away':
      case 'health_issues':
        return 'edit'; // تعديل
      default:
        return 'note'; // ملاحظة فقط
    }
  }

  /// نص الإجراء المقترح
  String get suggestedActionText {
    switch (suggestedAction) {
      case 'delete':
        return 'حذف نهائي';
      case 'edit':
        return 'تعديل البيانات';
      case 'note':
        return 'إضافة ملاحظة';
      default:
        return suggestedAction;
    }
  }

  /// استخراج رقم هاتف من الملاحظات (إن وجد)
  String? extractPhoneFromNotes() {
    if (notes == null || notes!.isEmpty) return null;

    // البحث عن رقم يمني (9 أرقام تبدأ بـ 7)
    final RegExp phoneRegex = RegExp(r'7\d{8}');
    final match = phoneRegex.firstMatch(notes!);

    return match?.group(0);
  }
}

