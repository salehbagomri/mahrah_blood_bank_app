import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/app_colors.dart';

/// شاشة حول التطبيق
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حول التطبيق'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header مع شعار التطبيق
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  // شعار التطبيق
                  SvgPicture.asset(
                    'assets/icons/logo-m.svg',
                    width: 120,
                    height: 120,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'بنك دم المهرة',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Mahrah Blood Bank',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'الإصدار 2.0.0',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // نبذة عن التطبيق
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('📱 عن التطبيق'),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    '''بنك دم المهرة هو تطبيق مجاني يهدف إلى ربط المتبرعين بالدم مع المحتاجين في محافظة المهرة، اليمن.

التطبيق يساعد على:
• البحث السريع عن متبرعين حسب فصيلة الدم والمديرية
• التسجيل كمتبرع وإدارة معلوماتك
• نشر الوعي حول أهمية التبرع بالدم
• توفير الوقت في حالات الطوارئ
• ربط المجتمع في عمل إنساني نبيل''',
                  ),

                  const SizedBox(height: 24),

                  // المطور
                  _buildSectionTitle('👨‍💻 المطور'),
                  const SizedBox(height: 12),
                  _buildDeveloperCard(),

                  const SizedBox(height: 24),

                  // الميزات
                  _buildSectionTitle('✨ الميزات'),
                  const SizedBox(height: 12),
                  _buildFeaturesCard(),

                  const SizedBox(height: 24),

                  // التقنيات المستخدمة
                  _buildSectionTitle('🛠️ التقنيات المستخدمة'),
                  const SizedBox(height: 12),
                  _buildTechnologiesCard(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildInfoCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          height: 1.6,
          color: AppColors.textSecondary,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildDeveloperCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF8F9FE), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primary,
            child: Icon(
              Icons.person,
              size: 45,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'صالح باقمري',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Saleh Bagomri',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          _buildContactItem(Icons.email, 's.bagomri@gmail.com'),
          const SizedBox(height: 8),
          _buildContactItem(Icons.language, 'www.bagomri.com'),
          const SizedBox(height: 8),
          _buildContactItem(Icons.location_on, 'حضرموت، اليمن'),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFeatureItem('🔍', 'بحث متقدم عن المتبرعين'),
          _buildFeatureItem('📝', 'تسجيل سهل وسريع'),
          _buildFeatureItem('📊', 'لوحة تحكم شاملة للإدارة'),
          _buildFeatureItem('📱', 'تصميم عصري ومريح'),
          _buildFeatureItem('🔒', 'حماية وخصوصية البيانات'),
          _buildFeatureItem('💙', 'خدمة مجانية 100%'),
          _buildFeatureItem('🌙', 'دعم الوضع الليلي (قريباً)'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnologiesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTechItem('Flutter', 'إطار تطوير التطبيقات'),
          _buildTechItem('Supabase', 'قاعدة البيانات السحابية'),
          _buildTechItem('Firebase Crashlytics', 'تتبع الأخطاء'),
          _buildTechItem('Provider', 'إدارة الحالة'),
        ],
      ),
    );
  }

  Widget _buildTechItem(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
