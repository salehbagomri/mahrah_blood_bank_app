import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/donor_model.dart';
import '../../providers/donor_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state.dart';
import '../../utils/helpers.dart';

/// شاشة البحث المتقدم للمستشفى
class AdvancedSearchScreen extends StatefulWidget {
  const AdvancedSearchScreen({super.key});

  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen> {
  String? _selectedBloodType;
  String? _selectedDistrict;
  String? _selectedGender;
  bool _includeAvailable = true;
  bool _includeSuspended = false;
  
  List<DonorModel> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.advancedSearch),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          // الفلاتر
          _buildFilters(),
          
          // النتائج
          Expanded(child: _buildResults()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _performSearch,
        icon: const Icon(Icons.search),
        label: const Text('بحث'),
      ),
    );
  }

  Widget _buildFilters() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الفلاتر',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          
          // فصيلة الدم
          DropdownButtonFormField<String>(
            value: _selectedBloodType,
            decoration: const InputDecoration(
              labelText: 'فصيلة الدم',
              prefixIcon: Icon(Icons.bloodtype),
            ),
            items: const ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _selectedBloodType = value),
          ),
          
          const SizedBox(height: 12),
          
          // المديرية
          DropdownButtonFormField<String>(
            value: _selectedDistrict,
            decoration: const InputDecoration(
              labelText: 'المديرية',
              prefixIcon: Icon(Icons.location_city),
            ),
            items: AppStrings.districts
                .map((district) => DropdownMenuItem(
                      value: district,
                      child: Text(district),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _selectedDistrict = value),
          ),
          
          const SizedBox(height: 12),
          
          // الجنس
          DropdownButtonFormField<String>(
            value: _selectedGender,
            decoration: const InputDecoration(
              labelText: 'الجنس',
              prefixIcon: Icon(Icons.person),
            ),
            items: const [
              DropdownMenuItem(value: 'male', child: Text('ذكر')),
              DropdownMenuItem(value: 'female', child: Text('أنثى')),
            ],
            onChanged: (value) => setState(() => _selectedGender = value),
          ),
          
          const SizedBox(height: 16),
          
          // الحالة
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  title: const Text('المتاحين'),
                  value: _includeAvailable,
                  onChanged: (value) => setState(() => _includeAvailable = value ?? true),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              Expanded(
                child: CheckboxListTile(
                  title: const Text('الموقوفين'),
                  value: _includeSuspended,
                  onChanged: (value) => setState(() => _includeSuspended = value ?? false),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (!_hasSearched) {
      return EmptyState(
        icon: Icons.search,
        title: 'ابدأ البحث',
        message: 'اختر الفلاتر واضغط على زر البحث',
      );
    }

    if (_isSearching) {
      return const LoadingWidget(message: 'جاري البحث...');
    }

    if (_searchResults.isEmpty) {
      return EmptyState(
        icon: Icons.search_off,
        title: 'لا توجد نتائج',
        message: 'لم يتم العثور على متبرعين بهذه المواصفات',
        actionLabel: 'مسح الفلاتر',
        onAction: _clearFilters,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final donor = _searchResults[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
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
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${donor.district} - ${Helpers.genderToArabic(donor.gender)}'),
                Text(
                  donor.phoneNumber,
                  style: const TextStyle(color: AppColors.info),
                ),
                if (donor.isSuspended)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'موقوف حتى ${Helpers.formatDate(donor.suspendedUntil!)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.warning,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showDonorDetails(donor),
            ),
          ),
        );
      },
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedBloodType = null;
      _selectedDistrict = null;
      _selectedGender = null;
      _includeAvailable = true;
      _includeSuspended = false;
      _searchResults = [];
      _hasSearched = false;
    });
  }

  Future<void> _performSearch() async {
    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    try {
      final provider = context.read<DonorProvider>();
      await provider.loadDonors();
      
      var results = provider.donors;

      // تطبيق الفلاتر
      if (_selectedBloodType != null) {
        results = results.where((d) => d.bloodType == _selectedBloodType).toList();
      }

      if (_selectedDistrict != null) {
        results = results.where((d) => d.district == _selectedDistrict).toList();
      }

      if (_selectedGender != null) {
        results = results.where((d) => d.gender == _selectedGender).toList();
      }

      // فلتر الحالة
      results = results.where((d) {
        if (_includeAvailable && !d.isSuspended) return true;
        if (_includeSuspended && d.isSuspended) return true;
        return false;
      }).toList();

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل البحث: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showDonorDetails(DonorModel donor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: _getBloodTypeColor(donor.bloodType),
                    child: Text(
                      donor.bloodType,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          donor.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          donor.phoneNumber,
                          style: const TextStyle(
                            color: AppColors.info,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              _buildDetailRow('العمر', '${donor.age} سنة'),
              _buildDetailRow('الجنس', Helpers.genderToArabic(donor.gender)),
              _buildDetailRow('المديرية', donor.district),
              if (donor.notes != null && donor.notes!.isNotEmpty)
                _buildDetailRow('ملاحظات', donor.notes!),
              if (donor.lastDonationDate != null)
                _buildDetailRow(
                  'آخر تبرع',
                  Helpers.formatDate(donor.lastDonationDate!),
                ),
              if (donor.isSuspended)
                _buildDetailRow(
                  'موقوف حتى',
                  Helpers.formatDate(donor.suspendedUntil!),
                  valueColor: AppColors.warning,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontWeight: valueColor != null ? FontWeight.bold : null,
              ),
            ),
          ),
        ],
      ),
    );
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

