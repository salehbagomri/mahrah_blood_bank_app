import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/donor_provider.dart';
import '../../widgets/loading_widget.dart';
import 'manage_donors_hospital_screen.dart';
import 'suspended_donors_screen.dart';

/// لوحة إدارة المستشفى
class HospitalDashboardScreen extends StatefulWidget {
  const HospitalDashboardScreen({super.key});

  @override
  State<HospitalDashboardScreen> createState() => _HospitalDashboardScreenState();
}

class _HospitalDashboardScreenState extends State<HospitalDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // تحميل جميع المتبرعين
    Future.microtask(() {
      context.read<DonorProvider>().loadDonors();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.hospitalDashboard),
        actions: [
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // معلومات المستخدم
            _UserInfoCard(),
            
            const SizedBox(height: 20),
            
            // الأقسام الرئيسية
            Row(
              children: [
                Expanded(
                  child: _DashboardCard(
                    icon: Icons.people,
                    title: AppStrings.manageDonors,
                    color: AppColors.primary,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ManageDonorsHospitalScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DashboardCard(
                    icon: Icons.search,
                    title: AppStrings.advancedSearch,
                    color: AppColors.info,
                    onTap: () {
                      // TODO: Navigate to advanced search screen
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _DashboardCard(
                    icon: Icons.pause_circle,
                    title: AppStrings.suspendedDonors,
                    color: AppColors.warning,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SuspendedDonorsScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DashboardCard(
                    icon: Icons.bar_chart,
                    title: AppStrings.bloodTypeReport,
                    color: AppColors.success,
                    onTap: () {
                      // TODO: Navigate to blood type report screen
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // قائمة المتبرعين
            Consumer<DonorProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const LoadingWidget(message: 'جاري تحميل المتبرعين...');
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'جميع المتبرعين (${provider.donors.length})',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    if (provider.donors.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text('لا يوجد متبرعين حالياً'),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.donors.take(10).length,
                        itemBuilder: (context, index) {
                          final donor = provider.donors[index];
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary,
                                child: Text(
                                  donor.bloodType,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(donor.name),
                              subtitle: Text('${donor.district} - ${donor.phoneNumber}'),
                              trailing: PopupMenuButton(
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Text('تعديل'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'suspend',
                                    child: Text('إيقاف 6 أشهر'),
                                  ),
                                ],
                                onSelected: (value) {
                                  if (value == 'suspend') {
                                    _suspendDonor(donor.id);
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// إيقاف متبرع لمدة 6 أشهر
  Future<void> _suspendDonor(String donorId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الإيقاف'),
        content: const Text('هل تريد إيقاف هذا المتبرع لمدة 6 أشهر؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(AppStrings.confirm),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<DonorProvider>().suspendDonorFor6Months(donorId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'تم إيقاف المتبرع لمدة 6 أشهر' : 'فشل إيقاف المتبرع',
            ),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }
}

/// بطاقة معلومات المستخدم
class _UserInfoCard extends StatelessWidget {
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
                    Icons.local_hospital,
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
                        authProvider.currentUser?.email ?? 'المستشفى',
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
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'مستشفى',
                    style: TextStyle(
                      color: AppColors.success,
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

/// بطاقة لوحة التحكم
class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.color,
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
                  size: 30,
                ),
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

