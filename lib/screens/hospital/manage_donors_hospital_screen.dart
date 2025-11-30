import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/donor_model.dart';
import '../../providers/donor_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state.dart';
import '../../utils/helpers.dart';
import '../donor/add_donor_screen.dart';

/// شاشة إدارة المتبرعين (للمستشفى)
class ManageDonorsHospitalScreen extends StatefulWidget {
  const ManageDonorsHospitalScreen({super.key});

  @override
  State<ManageDonorsHospitalScreen> createState() => _ManageDonorsHospitalScreenState();
}

class _ManageDonorsHospitalScreenState extends State<ManageDonorsHospitalScreen> {
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
          _buildSearchBar(),
          Expanded(child: _buildDonorsList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddDonorScreen(),
            ),
          ).then((_) => context.read<DonorProvider>().loadDonors());
        },
        icon: const Icon(Icons.person_add),
        label: const Text('إضافة متبرع'),
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
              return _HospitalDonorCard(donor: donor);
            },
          ),
        );
      },
    );
  }
}

/// بطاقة المتبرع للمستشفى
class _HospitalDonorCard extends StatelessWidget {
  final DonorModel donor;

  const _HospitalDonorCard({required this.donor});

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
            if (donor.isSuspended)
              Container(
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
            const SizedBox(width: 4),
            const Icon(Icons.expand_more),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfo(context),
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

  Widget _buildInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.cake, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text('العمر: ${donor.age} سنة'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              donor.gender == 'male' ? Icons.male : Icons.female,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text('الجنس: ${Helpers.genderToArabic(donor.gender)}'),
          ],
        ),
        if (donor.notes != null && donor.notes!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.notes, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Expanded(child: Text('ملاحظات: ${donor.notes}')),
            ],
          ),
        ],
        if (donor.lastDonationDate != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.history, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text('آخر تبرع: ${Helpers.formatDate(donor.lastDonationDate!)}'),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (!donor.isSuspended)
          ElevatedButton.icon(
            onPressed: () => _suspendDonor(context),
            icon: const Icon(Icons.pause, size: 16),
            label: const Text(AppStrings.suspendFor6Months),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ElevatedButton.icon(
          onPressed: () => _updateLastDonation(context),
          icon: const Icon(Icons.update, size: 16),
          label: const Text(AppStrings.updateLastDonation),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.info,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Future<void> _suspendDonor(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إيقاف المتبرع'),
        content: Text(
          'هل تريد إيقاف ${donor.name} لمدة 6 أشهر؟\n\n'
          'سيتم تسجيل هذا كآخر تبرع.',
        ),
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

  Future<void> _updateLastDonation(BuildContext context) async {
    final updatedDonor = donor.copyWith(
      lastDonationDate: DateTime.now(),
    );
    
    final success = await context.read<DonorProvider>().updateDonor(updatedDonor);
    
    if (context.mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحديث تاريخ آخر تبرع'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Color _getBloodTypeColor(String bloodType) {
    if (bloodType.contains('A') && !bloodType.contains('AB')) return AppColors.bloodTypeA;
    if (bloodType.contains('B') && !bloodType.contains('AB')) return AppColors.bloodTypeB;
    if (bloodType.contains('AB')) return AppColors.bloodTypeAB;
    if (bloodType.contains('O')) return AppColors.bloodTypeO;
    return AppColors.primary;
  }
}

