import 'package:flutter/material.dart';
import '../../../models/statistics_model.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../utils/helpers.dart';

/// قسم الإحصائيات في الصفحة الرئيسية
class StatisticsSection extends StatelessWidget {
  final StatisticsModel statistics;

  const StatisticsSection({
    super.key,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                AppStrings.statistics,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // صف الإحصائيات
          Row(
            children: [
              // إجمالي المتبرعين
              Expanded(
                child: _StatCard(
                  icon: Icons.people,
                  title: AppStrings.totalDonors,
                  value: '${statistics.totalDonors}',
                ),
              ),
              
              const SizedBox(width: 12),
              
              // أكثر فصيلة
              Expanded(
                child: _StatCard(
                  icon: Icons.bloodtype,
                  title: AppStrings.mostCommonBloodType,
                  value: statistics.mostCommonBloodType ?? '-',
                  subtitle: '${statistics.mostCommonBloodTypeCount} متبرع',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              // أكثر مديرية
              Expanded(
                child: _StatCard(
                  icon: Icons.location_city,
                  title: AppStrings.mostActiveDistrict,
                  value: statistics.mostActiveDistrict ?? '-',
                  subtitle: '${statistics.mostActiveDistrictCount} متبرع',
                ),
              ),
              
              const SizedBox(width: 12),
              
              // أحدث متبرع
              Expanded(
                child: _StatCard(
                  icon: Icons.access_time,
                  title: AppStrings.latestDonor,
                  value: statistics.latestDonorName ?? '-',
                  subtitle: statistics.latestDonorDate != null
                      ? Helpers.formatDate(statistics.latestDonorDate!)
                      : null,
                ),
              ),
            ],
          ),
          
          // وقت آخر تحديث
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.update,
                color: Colors.white70,
                size: 12,
              ),
              const SizedBox(width: 4),
              Text(
                'آخر تحديث: ${Helpers.formatDateTime(statistics.lastUpdated)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// بطاقة إحصائية
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? subtitle;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                  fontSize: 11,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white60,
                    fontSize: 10,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

