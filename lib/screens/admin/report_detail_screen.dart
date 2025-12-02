import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../models/report_model.dart';
import '../../models/donor_model.dart';
import '../../services/donor_service.dart';
import '../../services/report_service.dart';
import '../../providers/donor_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state.dart';
import '../../utils/helpers.dart';
import '../admin/edit_donor_screen.dart';

/// شاشة تفاصيل البلاغ المحسّنة
class ReportDetailScreen extends StatefulWidget {
  final ReportModel report;

  const ReportDetailScreen({
    super.key,
    required this.report,
  });

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  final _donorService = DonorService();
  final _reportService = ReportService();

  DonorModel? _donor;
  List<ReportModel> _previousReports = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _extractedPhone;

  @override
  void initState() {
    super.initState();
    _loadData();
    _extractedPhone = widget.report.extractPhoneFromNotes();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // جلب بيانات المتبرع
      final donor = await _donorService.getDonorById(widget.report.donorId);

      // جلب سجل البلاغات السابقة
      final reports = await _reportService.getReportsByDonorId(widget.report.donorId);

      // استبعاد البلاغ الحالي من القائمة
      final previousReports = reports.where((r) => r.id != widget.report.id).toList();

      if (mounted) {
        setState(() {
          _donor = donor;
          _previousReports = previousReports;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل البلاغ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_all),
            onPressed: _copyAllData,
            tooltip: 'نسخ جميع البيانات',
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'جاري تحميل البيانات...')
          : _errorMessage != null
              ? EmptyState(
                  icon: Icons.error_outline,
                  title: 'حدث خطأ',
                  message: _errorMessage!,
                  actionLabel: 'إعادة المحاولة',
                  onAction: _loadData,
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Badge الأولوية
          _buildPriorityBanner(),

          const SizedBox(height: 16),

          // معلومات البلاغ
          _buildReportInfoCard(),

          const SizedBox(height: 16),

          // بيانات المتبرع
          if (_donor != null) _buildDonorInfoCard(),

          const SizedBox(height: 16),

          // سجل البلاغات السابقة
          if (_previousReports.isNotEmpty) _buildPreviousReportsCard(),

          const SizedBox(height: 24),

          // الإجراءات السريعة
          if (widget.report.isPending) _buildQuickActions(),
        ],
      ),
    );
  }

  /// Banner الأولوية
  Widget _buildPriorityBanner() {
    Color color;
    IconData icon;
    String text;

    switch (widget.report.priority) {
      case 'critical':
        color = AppColors.error;
        icon = Icons.warning;
        text = '⚠️ بلاغ حرج - يحتاج إجراء فوري!';
        break;
      case 'high':
        color = Colors.orange;
        icon = Icons.priority_high;
        text = '🔶 بلاغ ذو أولوية عالية';
        break;
      case 'medium':
        color = AppColors.warning;
        icon = Icons.info;
        text = 'ℹ️ بلاغ متوسط الأولوية';
        break;
      default:
        color = AppColors.info;
        icon = Icons.info_outline;
        text = 'ℹ️ بلاغ للمتابعة';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'الإجراء المقترح: ${widget.report.suggestedActionText}',
                  style: TextStyle(
                    color: color.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// معلومات البلاغ
  Widget _buildReportInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.report_problem, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'معلومات البلاغ',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('السبب', widget.report.reasonText, Icons.error_outline),
            if (widget.report.notes != null && widget.report.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildNotesSection(),
            ],
            const SizedBox(height: 12),
            _buildInfoRow(
              'تاريخ البلاغ',
              Helpers.formatDateTime(widget.report.createdAt),
              Icons.calendar_today,
            ),
            const SizedBox(height: 12),
            _buildInfoRow('الحالة', widget.report.statusText, Icons.check_circle),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notes, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                'الملاحظات:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(widget.report.notes!),

          // إذا تم استخراج رقم من الملاحظات
          if (_extractedPhone != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.phone_android, color: AppColors.success, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'رقم محتمل تم استخراجه:',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _extractedPhone!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: () => _copyText(_extractedPhone!),
                    color: AppColors.success,
                    tooltip: 'نسخ الرقم',
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// بيانات المتبرع
  Widget _buildDonorInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'بيانات المتبرع',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('الاسم', _donor!.name, Icons.badge),
            const SizedBox(height: 12),
            _buildInfoRow('الرقم المسجل', widget.report.donorPhoneNumber, Icons.phone, isPhone: true),
            if (_donor!.phoneNumber2 != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow('الرقم 2', _donor!.phoneNumber2!, Icons.phone, isPhone: true),
            ],
            if (_donor!.phoneNumber3 != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow('الرقم 3', _donor!.phoneNumber3!, Icons.phone, isPhone: true),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow('الفصيلة', _donor!.bloodType, Icons.bloodtype),
                ),
                Expanded(
                  child: _buildInfoRow('المديرية', _donor!.district, Icons.location_on),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('الحالة', _getDonorStatus(), Icons.info,
                statusColor: _getDonorStatusColor()),
            if (_donor!.lastDonationDate != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                'آخر تبرع',
                DateFormat('yyyy-MM-dd').format(_donor!.lastDonationDate!),
                Icons.calendar_month,
              ),
            ],
            const SizedBox(height: 16),
            // أزرار الاتصال
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Helpers.makePhoneCall(_donor!.phoneNumber),
                    icon: const Icon(Icons.phone, size: 18),
                    label: const Text('اتصال'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Helpers.openWhatsApp(_donor!.phoneNumber),
                    icon: const Icon(Icons.chat, size: 18),
                    label: const Text('واتساب'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _viewDonorFullProfile,
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('الملف'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getDonorStatus() {
    if (!_donor!.isActive) return 'معطل';
    if (_donor!.isSuspended) return 'موقوف';
    return 'متاح';
  }

  Color _getDonorStatusColor() {
    if (!_donor!.isActive) return AppColors.error;
    if (_donor!.isSuspended) return AppColors.warning;
    return AppColors.success;
  }

  /// سجل البلاغات السابقة
  Widget _buildPreviousReportsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: AppColors.warning),
                const SizedBox(width: 8),
                Text(
                  'سجل البلاغات (${_previousReports.length} بلاغ سابق)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),
            ..._previousReports.map((report) => _buildReportHistoryItem(report)),
          ],
        ),
      ),
    );
  }

  Widget _buildReportHistoryItem(ReportModel report) {
    Color statusColor;
    if (report.isApproved) {
      statusColor = AppColors.success;
    } else if (report.isRejected) {
      statusColor = AppColors.error;
    } else {
      statusColor = AppColors.warning;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.reasonText,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('yyyy-MM-dd').format(report.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                report.statusText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// الإجراءات السريعة
  Widget _buildQuickActions() {
    return Card(
      color: AppColors.primary.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flash_on, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'إجراء سريع',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // زر: قبول + تعديل البيانات
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _approveAndEdit,
                icon: const Icon(Icons.edit),
                label: const Text('قبول + تعديل البيانات'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // زر: قبول + حذف نهائي (للحالات الحرجة)
            if (widget.report.priority == 'critical')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _approveAndDelete,
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('قبول + حذف نهائي'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

            const SizedBox(height: 10),

            // زر: قبول فقط
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _approveOnly,
                icon: const Icon(Icons.check),
                label: const Text('قبول فقط (بدون إجراء)'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.success,
                  side: BorderSide(color: AppColors.success),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // زر: رفض البلاغ
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _rejectReport,
                icon: const Icon(Icons.close),
                label: const Text('رفض البلاغ'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon,
      {bool isPhone = false, Color? statusColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: statusColor,
                      ),
                    ),
                  ),
                  if (isPhone)
                    IconButton(
                      icon: const Icon(Icons.copy, size: 16),
                      onPressed: () => _copyText(value),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'نسخ',
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== الإجراءات ====================

  /// قبول + تعديل البيانات
  Future<void> _approveAndEdit() async {
    // قبول البلاغ أولاً
    final approved = await _approveReport();
    if (!approved || !mounted) return;

    // فتح شاشة التعديل
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDonorScreen(donor: _donor!),
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم قبول البلاغ وتعديل بيانات المتبرع بنجاح'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop(true); // العودة لقائمة البلاغات
    }
  }

  /// قبول + حذف نهائي
  Future<void> _approveAndDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف النهائي'),
        content: Text(
          'هل أنت متأكد من حذف المتبرع "${_donor!.name}" نهائياً؟\n\n'
          'السبب: ${widget.report.reasonText}\n\n'
          'لا يمكن التراجع عن هذا الإجراء!',
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('حذف نهائي'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // قبول البلاغ
      await _reportService.approveReport(widget.report.id);

      // حذف المتبرع
      await context.read<DonorProvider>().deleteDonor(_donor!.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم قبول البلاغ وحذف المتبرع نهائياً'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// قبول فقط
  Future<void> _approveOnly() async {
    final approved = await _approveReport();
    if (approved && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  /// رفض البلاغ
  Future<void> _rejectReport() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('رفض البلاغ'),
        content: const Text('هل تريد رفض هذا البلاغ؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('رفض'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _reportService.rejectReport(widget.report.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم رفض البلاغ'),
            backgroundColor: AppColors.warning,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// قبول البلاغ (مساعد)
  Future<bool> _approveReport() async {
    try {
      await _reportService.approveReport(widget.report.id);
      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل قبول البلاغ: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return false;
    }
  }

  /// عرض الملف الكامل للمتبرع
  void _viewDonorFullProfile() {
    // يمكن تنفيذ هذا لاحقاً - الانتقال لشاشة إدارة المتبرعين مع تصفية
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ميزة قيد التطوير')),
    );
  }

  /// نسخ نص
  void _copyText(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم النسخ'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  /// نسخ جميع البيانات
  void _copyAllData() {
    final data = '''
=== معلومات البلاغ ===
السبب: ${widget.report.reasonText}
الملاحظات: ${widget.report.notes ?? 'لا توجد'}
التاريخ: ${Helpers.formatDateTime(widget.report.createdAt)}
الحالة: ${widget.report.statusText}
الأولوية: ${widget.report.priorityText}

=== بيانات المتبرع ===
الاسم: ${_donor?.name ?? 'غير متوفر'}
الرقم: ${widget.report.donorPhoneNumber}
الفصيلة: ${_donor?.bloodType ?? 'غير متوفر'}
المديرية: ${_donor?.district ?? 'غير متوفر'}
الحالة: ${_getDonorStatus()}

${_previousReports.isNotEmpty ? '=== سجل البلاغات السابقة (${_previousReports.length}) ===' : ''}
${_previousReports.map((r) => '- ${r.reasonText} (${DateFormat('yyyy-MM-dd').format(r.createdAt)}) - ${r.statusText}').join('\n')}
''';

    Clipboard.setData(ClipboardData(text: data));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ جميع البيانات'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
