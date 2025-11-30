import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../providers/statistics_provider.dart';
import '../../widgets/loading_widget.dart';
import '../donor/search_donors_screen.dart';
import '../donor/add_donor_screen.dart';
import '../awareness/awareness_screen.dart';
import '../reports/report_donor_screen.dart';
import '../auth/login_screen.dart';
import 'widgets/statistics_section.dart';

/// الصفحة الرئيسية للتطبيق
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // تحميل الإحصائيات عند فتح التطبيق
    Future.microtask(() {
      context.read<StatisticsProvider>().loadStatistics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        centerTitle: true,
        elevation: 0,
        actions: [
          // زر تسجيل الدخول للمستشفيات والأدمن
          IconButton(
            icon: const Icon(Icons.login),
            tooltip: 'تسجيل الدخول',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<StatisticsProvider>().refreshStatistics();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // شريط علوي بالألوان
              Container(
                height: 8,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primaryDark,
                    ],
                  ),
                ),
              ),
              
              // قسم الإحصائيات
              Consumer<StatisticsProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading && provider.statistics == null) {
                    return const Padding(
                      padding: EdgeInsets.all(32),
                      child: LoadingWidget(message: 'جاري تحميل الإحصائيات...'),
                    );
                  }
                  
                  if (provider.statistics != null) {
                    return StatisticsSection(statistics: provider.statistics!);
                  }
                  
                  return const SizedBox.shrink();
                },
              ),
              
              // الأزرار الرئيسية
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // زر البحث عن متبرعين
                    _MainActionButton(
                      icon: Icons.search,
                      title: AppStrings.searchForDonors,
                      subtitle: 'ابحث عن متبرعين حسب الفصيلة والمديرية',
                      color: AppColors.primary,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SearchDonorsScreen(),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // زر إضافة متبرع
                    _MainActionButton(
                      icon: Icons.person_add,
                      title: AppStrings.addDonor,
                      subtitle: 'أضف نفسك أو شخص آخر كمتبرع',
                      color: AppColors.success,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AddDonorScreen(),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // صف الأزرار الصغيرة
                    Row(
                      children: [
                        // زر التوعية
                        Expanded(
                          child: _SecondaryActionButton(
                            icon: Icons.school,
                            title: AppStrings.awareness,
                            color: AppColors.info,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const AwarenessScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // زر الإبلاغ
                        Expanded(
                          child: _SecondaryActionButton(
                            icon: Icons.report,
                            title: AppStrings.reportDonor,
                            color: AppColors.warning,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ReportDonorScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // معلومات إضافية
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.favorite,
                      color: AppColors.primary,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'التبرع بالدم ينقذ الأرواح',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'كن بطلاً وساهم في إنقاذ حياة إنسان',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// زر إجراء رئيسي
class _MainActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MainActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
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
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // الأيقونة
              Container(
                width: 60,
                height: 60,
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
              
              const SizedBox(width: 16),
              
              // النصوص
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              
              // سهم
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textHint,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// زر إجراء ثانوي
class _SecondaryActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _SecondaryActionButton({
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 25,
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

