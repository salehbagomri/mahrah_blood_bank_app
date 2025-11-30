import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/donor_model.dart';
import '../../providers/donor_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state.dart';
import '../../utils/helpers.dart';

/// شاشة إدارة جميع المتبرعين (للأدمن)
class ManageDonorsScreen extends StatefulWidget {
  const ManageDonorsScreen({super.key});

  @override
  State<ManageDonorsScreen> createState() => _ManageDonorsScreenState();
}

class _ManageDonorsScreenState extends State<ManageDonorsScreen> {
  final _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<DonorProvider>().loadDonors();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.manageDonors),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<DonorProvider>().loadDonors(),
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط البحث
          _buildSearchBar(),
          
          // قائمة المتبرعين
          Expanded(child: _buildDonorsList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'بحث بالاسم أو رقم الهاتف...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<DonorProvider>().clearSearchResults();
                    context.read<DonorProvider>().loadDonors();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onChanged: (query) {
          if (query.length >= 2) {
            context.read<DonorProvider>().searchByNameOrPhone(query);
          } else if (query.isEmpty) {
            context.read<DonorProvider>().clearSearchResults();
            context.read<DonorProvider>().loadDonors();
          }
        },
      ),
    );
  }

  Widget _buildDonorsList() {
    return Consumer<DonorProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.donors.isEmpty) {
          return const LoadingWidget(message: 'جاري تحميل المتبرعين...');
        }

        if (provider.hasError) {
          return EmptyState(
            icon: Icons.error_outline,
            title: 'حدث خطأ',
            message: provider.errorMessage ?? 'حدث خطأ غير متوقع',
            actionLabel: 'إعادة المحاولة',
            onAction: () => provider.loadDonors(),
          );
        }

        final donors = _searchController.text.isNotEmpty
            ? provider.searchResults
            : provider.donors;

        if (donors.isEmpty) {
          return EmptyState(
            icon: Icons.search_off,
            title: 'لا يوجد متبرعين',
            message: _searchController.text.isNotEmpty
                ? 'لم يتم العثور على نتائج'
                : 'لم يتم إضافة أي متبرع بعد',
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadDonors(),
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: donors.length,
            itemBuilder: (context, index) {
              final donor = donors[index];
              return _AdminDonorCard(donor: donor);
            },
          ),
        );
      },
    );
  }
}

/// بطاقة المتبرع للأدمن (مع خيارات إضافية)
class _AdminDonorCard extends StatelessWidget {
  final DonorModel donor;

  const _AdminDonorCard({required this.donor});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getBloodTypeColor(donor.bloodType),
          child: Text(
            donor.bloodType,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          donor.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${donor.district} - ${donor.phoneNumber}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!donor.isActive)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'معطل',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (donor.isSuspended)
              Container(
                margin: const EdgeInsets.only(left: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'موقوف',
                  style: TextStyle(
                    color: AppColors.warning,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const Icon(Icons.expand_more),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(Icons.cake, 'العمر', '${donor.age} سنة'),
                _buildInfoRow(
                  donor.gender == 'male' ? Icons.male : Icons.female,
                  'الجنس',
                  Helpers.genderToArabic(donor.gender),
                ),
                if (donor.notes != null && donor.notes!.isNotEmpty)
                  _buildInfoRow(Icons.notes, 'ملاحظات', donor.notes!),
                if (donor.lastDonationDate != null)
                  _buildInfoRow(
                    Icons.history,
                    'آخر تبرع',
                    Helpers.formatDate(donor.lastDonationDate!),
                  ),
                if (donor.isSuspended && donor.suspendedUntil != null)
                  _buildInfoRow(
                    Icons.pause_circle,
                    'موقوف حتى',
                    Helpers.formatDate(donor.suspendedUntil!),
                  ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                _buildActions(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (donor.isActive)
          ElevatedButton.icon(
            onPressed: () => _toggleActiveStatus(context, false),
            icon: const Icon(Icons.block, size: 16),
            label: const Text('تعطيل'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          )
        else
          ElevatedButton.icon(
            onPressed: () => _toggleActiveStatus(context, true),
            icon: const Icon(Icons.check_circle, size: 16),
            label: const Text('تفعيل'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        if (!donor.isSuspended && donor.isActive)
          ElevatedButton.icon(
            onPressed: () => _suspendDonor(context),
            icon: const Icon(Icons.pause, size: 16),
            label: const Text('إيقاف 6 أشهر'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        OutlinedButton.icon(
          onPressed: () => _deleteDonor(context),
          icon: const Icon(Icons.delete, size: 16),
          label: const Text(AppStrings.delete),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Future<void> _toggleActiveStatus(BuildContext context, bool newStatus) async {
    final updatedDonor = donor.copyWith(isActive: newStatus);
    final success = await context.read<DonorProvider>().updateDonor(updatedDonor);
    
    if (context.mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newStatus ? 'تم تفعيل المتبرع' : 'تم تعطيل المتبرع'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _suspendDonor(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إيقاف المتبرع'),
        content: Text('هل تريد إيقاف ${donor.name} لمدة 6 أشهر؟'),
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

    if (confirmed == true && context.mounted) {
      final success = await context.read<DonorProvider>()
          .suspendDonorFor6Months(donor.id);
      
      if (context.mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إيقاف المتبرع لمدة 6 أشهر'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _deleteDonor(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المتبرع'),
        content: Text(
          'هل تريد حذف ${donor.name}؟\n\n'
          'هذا الإجراء لا يمكن التراجع عنه!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await context.read<DonorProvider>().deleteDonor(donor.id);
      
      if (context.mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف المتبرع'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Color _getBloodTypeColor(String bloodType) {
    if (bloodType.contains('A')) return AppColors.bloodTypeA;
    if (bloodType.contains('B')) return AppColors.bloodTypeB;
    if (bloodType.contains('AB')) return AppColors.bloodTypeAB;
    if (bloodType.contains('O')) return AppColors.bloodTypeO;
    return AppColors.primary;
  }
}

