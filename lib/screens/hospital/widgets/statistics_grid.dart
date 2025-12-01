import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../models/dashboard_statistics_model.dart';
import 'stat_card.dart';

/// شبكة الإحصائيات
class StatisticsGrid extends StatelessWidget {
  final DashboardStatisticsModel statistics;

  const StatisticsGrid({super.key, required this.statistics});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الإحصائيات السريعة',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
          children: [
            // 1. إجمالي المتبرعين
            StatCard(
              icon: Icons.people,
              label: 'إجمالي المتبرعين',
              value: '${statistics.totalDonors}',
              color: AppColors.primary,
            ),

            // 2. المتاحين للتبرع
            StatCard(
              icon: Icons.check_circle,
              label: 'متاحين للتبرع',
              value: '${statistics.availableDonors}',
              color: AppColors.success,
            ),

            // 3. الموقوفين
            StatCard(
              icon: Icons.pause_circle,
              label: 'موقوفين',
              value: '${statistics.suspendedDonors}',
              color: AppColors.warning,
            ),
          ],
        ),
      ],
    );
  }
}
