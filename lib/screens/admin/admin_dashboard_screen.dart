import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/statistics_provider.dart';
import '../../services/report_service.dart';
import '../../services/hospital_service.dart';
import '../../services/donor_service.dart';
import 'manage_hospitals_screen.dart';
import 'review_reports_screen.dart';
import 'manage_donors_screen.dart';
import 'system_overview_screen.dart';

/// لوحة إدارة الأدمن
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _reportService = ReportService();
  final _hospitalService = HospitalService();
  final _donorService = DonorService();
  
  int _pendingReportsCount = 0;
  int _totalDonors = 0;
  int _totalHospitals = 0;
  int _suspendedDonors = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // تأجيل التحميل لما بعد بناء الواجهة
    Future.microtask(() => _loadDashboardData());
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // تحميل جميع البيانات بالتوازي
      final results = await Future.wait([
        _reportService.getPendingReportsCount(),
        _hospitalService.getHospitalsCount(),
        _donorService.getAllDonors(),
        _donorService.getSuspendedDonors(),
        context.read<StatisticsProvider>().loadStatistics(),
      ]);

      if (mounted) {
        setState(() {
          _pendingReportsCount = results[0] as int;
          _totalHospitals = results[1] as int;
          _totalDonors = (results[2] as List).length;
          _suspendedDonors = (results[3] as List).length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'فشل تحميل البيانات: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.adminDashboard),
        actions: [
          // زر تحديث
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadDashboardData,
          ),
          // زر تسجيل الخروج
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: _errorMessage != null
          ? _buildErrorView()
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // معلومات المستخدم
            _AdminInfoCard(),
            
            const SizedBox(height: 20),
            
            // البلاغات المعلقة
            if (_pendingReportsCount > 0)
              Card(
                color: AppColors.warning.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.warning,
                        size: 30,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'لديك $_pendingReportsCount بلاغ معلق',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'يرجى مراجعة البلاغات',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ReviewReportsScreen(),
                            ),
                          ).then((_) => _loadDashboardData());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.warning,
                        ),
                        child: const Text('مراجعة'),
                      ),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 20),
            
            // الأقسام الرئيسية
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _AdminCard(
                  icon: Icons.local_hospital,
                  title: AppStrings.manageHospitals,
                  color: AppColors.primary,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ManageHospitalsScreen(),
                      ),
                    );
                  },
                ),
                _AdminCard(
                  icon: Icons.report,
                  title: AppStrings.reviewReports,
                  color: AppColors.warning,
                  badge: _pendingReportsCount > 0 ? '$_pendingReportsCount' : null,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ReviewReportsScreen(),
                      ),
                    );
                  },
                ),
                _AdminCard(
                  icon: Icons.people,
                  title: AppStrings.manageDonors,
                  color: AppColors.success,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ManageDonorsScreen(),
                      ),
                    );
                  },
                ),
                _AdminCard(
                  icon: Icons.analytics,
                  title: AppStrings.systemOverview,
                  color: AppColors.info,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SystemOverviewScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // إحصائيات سريعة
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.bar_chart,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'إحصائيات سريعة',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else ...[
                      _QuickStat(
                        icon: Icons.people,
                        label: 'إجمالي المتبرعين',
                        value: '$_totalDonors',
                        color: AppColors.success,
                      ),
                      const Divider(),
                      _QuickStat(
                        icon: Icons.local_hospital,
                        label: 'عدد المستشفيات',
                        value: '$_totalHospitals',
                        color: AppColors.info,
                      ),
                      const Divider(),
                      _QuickStat(
                        icon: Icons.pause_circle,
                        label: 'متبرعين موقوفين',
                        value: '$_suspendedDonors',
                        color: AppColors.warning,
                      ),
                      const Divider(),
                      _QuickStat(
                        icon: Icons.report,
                        label: 'البلاغات المعلقة',
                        value: '$_pendingReportsCount',
                        color: _pendingReportsCount > 0 ? AppColors.error : AppColors.success,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
            ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'حدث خطأ',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'خطأ غير متوقع',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadDashboardData,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

/// بطاقة معلومات الأدمن
class _AdminInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary,
                  child: const Icon(
                    Icons.admin_panel_settings,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مرحباً',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        authProvider.currentUser?.email ?? 'المدير',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'مدير النظام',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// بطاقة لوحة الأدمن
class _AdminCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final String? badge;
  final VoidCallback onTap;

  const _AdminCard({
    required this.icon,
    required this.title,
    required this.color,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 35,
                    ),
                  ),
                  if (badge != null)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          badge!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// إحصائية سريعة
class _QuickStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _QuickStat({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color ?? AppColors.primary,
                ),
          ),
        ],
      ),
    );
  }
}

