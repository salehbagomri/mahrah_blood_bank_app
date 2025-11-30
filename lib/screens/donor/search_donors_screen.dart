import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../providers/donor_provider.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/donor_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state.dart';

/// صفحة البحث عن المتبرعين
class SearchDonorsScreen extends StatefulWidget {
  const SearchDonorsScreen({super.key});

  @override
  State<SearchDonorsScreen> createState() => _SearchDonorsScreenState();
}

class _SearchDonorsScreenState extends State<SearchDonorsScreen> {
  String? selectedBloodType;
  String? selectedDistrict;
  bool hasSearched = false;

  // فصائل الدم
  final List<String> bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.searchForDonors),
      ),
      body: Column(
        children: [
          // قسم البحث
          Container(
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // اختيار فصيلة الدم
                CustomDropdown(
                  value: selectedBloodType,
                  items: bloodTypes,
                  hint: AppStrings.selectBloodType,
                  label: AppStrings.bloodType,
                  icon: Icons.bloodtype,
                  onChanged: (value) {
                    setState(() {
                      selectedBloodType = value;
                    });
                  },
                ),
                
                const SizedBox(height: 16),
                
                // اختيار المديرية
                CustomDropdown(
                  value: selectedDistrict,
                  items: AppStrings.districts,
                  hint: AppStrings.selectDistrict,
                  label: AppStrings.district,
                  icon: Icons.location_on,
                  onChanged: (value) {
                    setState(() {
                      selectedDistrict = value;
                    });
                  },
                ),
                
                const SizedBox(height: 16),
                
                // زر البحث
                ElevatedButton.icon(
                  onPressed: _performSearch,
                  icon: const Icon(Icons.search),
                  label: const Text(AppStrings.search),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
            ),
          ),
          
          // النتائج
          Expanded(
            child: Consumer<DonorProvider>(
              builder: (context, provider, _) {
                // حالة التحميل
                if (provider.isLoading) {
                  return const LoadingWidget(
                    message: 'جاري البحث عن المتبرعين...',
                  );
                }
                
                // حالة الخطأ
                if (provider.hasError) {
                  return EmptyState(
                    icon: Icons.error_outline,
                    title: 'حدث خطأ',
                    message: provider.errorMessage ?? 'حدث خطأ غير متوقع',
                    actionLabel: 'إعادة المحاولة',
                    onAction: _performSearch,
                  );
                }
                
                // إذا لم يتم البحث بعد
                if (!hasSearched) {
                  return EmptyState(
                    icon: Icons.search,
                    title: 'ابحث عن متبرعين',
                    message: 'اختر فصيلة الدم والمديرية للبحث عن المتبرعين المتاحين',
                  );
                }
                
                // إذا كانت النتائج فارغة
                if (provider.searchResults.isEmpty) {
                  return EmptyState(
                    icon: Icons.search_off,
                    title: AppStrings.noDonorsFound,
                    message: AppStrings.noDonorsMessage,
                    actionLabel: 'بحث جديد',
                    onAction: _clearSearch,
                  );
                }
                
                // عرض النتائج
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // عدد النتائج
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: AppColors.background,
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'تم العثور على ${provider.searchResults.length} متبرع',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                    
                    // قائمة النتائج
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: provider.searchResults.length,
                        itemBuilder: (context, index) {
                          final donor = provider.searchResults[index];
                          return DonorCard(
                            donor: donor,
                            showActions: true,
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// تنفيذ البحث
  void _performSearch() {
    // التحقق من اختيار فصيلة الدم على الأقل
    if (selectedBloodType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار فصيلة الدم للبحث'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      hasSearched = true;
    });

    // البحث
    context.read<DonorProvider>().searchDonors(
          bloodType: selectedBloodType,
          district: selectedDistrict,
          availableOnly: true,
        );
  }

  /// مسح البحث
  void _clearSearch() {
    setState(() {
      selectedBloodType = null;
      selectedDistrict = null;
      hasSearched = false;
    });
    context.read<DonorProvider>().clearSearchResults();
  }
}

