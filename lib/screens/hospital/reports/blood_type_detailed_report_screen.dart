import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/donor_provider.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/empty_state.dart';
import '../../../utils/report_export_utils.dart';
import '../../../models/donor_model.dart';

/// تقرير فصائل الدم المفصّل مع خيارات التصدير
class BloodTypeDetailedReportScreen extends StatefulWidget {
  const BloodTypeDetailedReportScreen({super.key});

  @override
  State<BloodTypeDetailedReportScreen> createState() =>
      _BloodTypeDetailedReportScreenState();
}

class _BloodTypeDetailedReportScreenState
    extends State<BloodTypeDetailedReportScreen> {
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<DashboardProvider>().loadDashboardData();
      context.read<DonorProvider>().loadDonors();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 تقرير فصائل الدم'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DashboardProvider>().refreshDashboard();
              context.read<DonorProvider>().loadDonors();
            },
          ),
        ],
      ),
      body: Consumer2<DashboardProvider, DonorProvider>(
        builder: (context, dashboardProvider, donorProvider, _) {
          if (dashboardProvider.isLoading || donorProvider.isLoading) {
            return const LoadingWidget(message: 'جاري تحميل التقرير...');
          }

          if (dashboardProvider.hasError) {
            return EmptyState(
              icon: Icons.error_outline,
              title: 'حدث خطأ',
              message: dashboardProvider.errorMessage ?? 'فشل تحميل التقرير',
              actionLabel: 'إعادة المحاولة',
              onAction: () {
                dashboardProvider.loadDashboardData();
                donorProvider.loadDonors();
              },
            );
          }

          final stats = dashboardProvider.statistics;
          if (stats == null) {
            return const EmptyState(
              icon: Icons.dashboard,
              title: 'لا توجد بيانات',
              message: 'لا توجد بيانات لعرضها',
            );
          }

          return _buildReportContent(stats, donorProvider.donors);
        },
      ),
    );
  }

  Widget _buildReportContent(stats, List<DonorModel> donors) {
    // طباعة للتأكد من تحميل البيانات
    print('📊 عدد المتبرعين المحملين: ${donors.length}');
    
    // حساب توزيع فصائل الدم من البيانات الفعلية
    final bloodTypeDistribution = <String, Map<String, int>>{};
    
    // تهيئة جميع الفصائل بأصفار
    final bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
    
    for (var type in bloodTypes) {
      bloodTypeDistribution[type] = {
        'total': 0,
        'available': 0,
        'suspended': 0,
      };
    }

    // حساب البيانات الفعلية من قائمة المتبرعين
    for (var donor in donors) {
      final bloodType = donor.bloodType;
      
      if (bloodTypeDistribution.containsKey(bloodType)) {
        // زيادة العدد الإجمالي
        bloodTypeDistribution[bloodType]!['total'] = 
            (bloodTypeDistribution[bloodType]!['total'] ?? 0) + 1;
        
        // زيادة عدد المتاحين أو الموقوفين
        if (donor.isSuspended) {
          bloodTypeDistribution[bloodType]!['suspended'] = 
              (bloodTypeDistribution[bloodType]!['suspended'] ?? 0) + 1;
        } else if (donor.isAvailable) {
          bloodTypeDistribution[bloodType]!['available'] = 
              (bloodTypeDistribution[bloodType]!['available'] ?? 0) + 1;
        }
      }
    }
    
    // طباعة النتائج للتأكد
    print('📊 توزيع فصائل الدم:');
    bloodTypeDistribution.forEach((type, counts) {
      if (counts['total']! > 0) {
        print('  $type: ${counts['total']} (متاح: ${counts['available']}, موقوف: ${counts['suspended']})');
      }
    });
    
    final totalDonors = stats.totalDonors;
    final availableDonors = stats.availableDonors;
    final suspendedDonors = stats.suspendedDonors;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ملخص عام
              _buildSummaryCard(totalDonors, availableDonors, suspendedDonors),

              const SizedBox(height: 20),

              // جدول فصائل الدم
              _buildBloodTypeTable(bloodTypeDistribution),

              const SizedBox(height: 20),

              // أزرار التصدير
              _buildExportButtons(bloodTypeDistribution, stats, donors),

              const SizedBox(height: 20),
            ],
          ),
        ),
        
        // مؤشر التصدير
        if (_isExporting)
          Container(
            color: Colors.black54,
            child: const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'جاري التصدير...',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryCard(int total, int available, int suspended) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.bloodtype,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            Text(
              'ملخص التقرير',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('الإجمالي', total, AppColors.primary),
                _buildStatItem('متاحين', available, AppColors.success),
                _buildStatItem('موقوفين', suspended, AppColors.warning),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildBloodTypeTable(Map<String, Map<String, int>> distribution) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'توزيع فصائل الدم',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Table(
              border: TableBorder.all(color: AppColors.divider),
              children: [
                // الرأس
                TableRow(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                  ),
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'الفصيلة',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'الإجمالي',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'متاحين',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'موقوفين',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                // البيانات
                ...distribution.entries.map(
                  (entry) => TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getBloodTypeColor(entry.key),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          '${entry.value['total']}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          '${entry.value['available']}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.success),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          '${entry.value['suspended']}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.warning),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportButtons(
    Map<String, Map<String, int>> distribution,
    stats,
    List<DonorModel> donors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'تصدير التقرير',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _exportToPdf(distribution, stats, donors),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('تصدير PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _exportToExcel(distribution, stats, donors),
                icon: const Icon(Icons.table_chart),
                label: const Text('تصدير Excel'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _exportToPdf(
    Map<String, Map<String, int>> distribution,
    stats,
    List<DonorModel> donors,
  ) async {
    setState(() => _isExporting = true);

    try {
      final headers = [
        ['الفصيلة', 'الإجمالي', 'متاحين', 'موقوفين']
      ];

      final data = distribution.entries
          .map((entry) => [
                entry.key,
                '${entry.value['total']}',
                '${entry.value['available']}',
                '${entry.value['suspended']}',
              ])
          .toList();

      final summary = {
        'إجمالي المتبرعين': '${stats.totalDonors}',
        'متاحين للتبرع': '${stats.availableDonors}',
        'موقوفين': '${stats.suspendedDonors}',
      };

      final success = await ReportExportUtils.exportToPdf(
        title: 'تقرير فصائل الدم',
        headers: headers,
        data: data,
        summary: summary,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'تم التصدير بنجاح! ✅' : 'فشل التصدير ❌',
            ),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _exportToExcel(
    Map<String, Map<String, int>> distribution,
    stats,
    List<DonorModel> donors,
  ) async {
    setState(() => _isExporting = true);

    try {
      final headers = ['الفصيلة', 'الإجمالي', 'متاحين', 'موقوفين'];

      final data = distribution.entries
          .map((entry) => [
                entry.key,
                entry.value['total'],
                entry.value['available'],
                entry.value['suspended'],
              ])
          .toList();

      final summary = {
        'إجمالي المتبرعين': '${stats.totalDonors}',
        'متاحين للتبرع': '${stats.availableDonors}',
        'موقوفين': '${stats.suspendedDonors}',
      };

      final success = await ReportExportUtils.exportToExcel(
        title: 'تقرير فصائل الدم',
        sheetName: 'فصائل الدم',
        headers: headers,
        data: data,
        summary: summary,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'تم التصدير بنجاح! ✅' : 'فشل التصدير ❌',
            ),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Color _getBloodTypeColor(String bloodType) {
    if (bloodType.contains('A') && !bloodType.contains('AB')) {
      return AppColors.bloodTypeA;
    }
    if (bloodType.contains('B') && !bloodType.contains('AB')) {
      return AppColors.bloodTypeB;
    }
    if (bloodType.contains('AB')) return AppColors.bloodTypeAB;
    if (bloodType.contains('O')) return AppColors.bloodTypeO;
    return AppColors.primary;
  }
}

