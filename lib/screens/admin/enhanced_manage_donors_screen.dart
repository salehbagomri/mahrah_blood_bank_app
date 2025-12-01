import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/donor_model.dart';
import '../../providers/donor_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/expandable_donor_card.dart';
import '../donor/add_donor_screen.dart';

/// شاشة إدارة المتبرعين المحسّنة للأدمن
class EnhancedManageDonorsScreen extends StatefulWidget {
  const EnhancedManageDonorsScreen({super.key});

  @override
  State<EnhancedManageDonorsScreen> createState() =>
      _EnhancedManageDonorsScreenState();
}

class _EnhancedManageDonorsScreenState
    extends State<EnhancedManageDonorsScreen> {
  final _searchController = TextEditingController();

  // الفلاتر
  String? _selectedBloodType;
  String? _selectedDistrict;
  String? _selectedGender;
  String _selectedStatus = 'all'; // 'all', 'available', 'suspended'
  String _sortBy = 'date'; // 'name', 'date', 'bloodType'

  bool _showFilters = false;

  // قوائم الخيارات
  final List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  final List<String> _districts = [
    'الغيضة',
    'حصوين',
    'حات',
    'المسيلة',
    'شحن',
    'قشن',
    'منعر',
    'سيحوت',
    'حوف',
  ];

  final List<String> _genders = ['ذكر', 'أنثى'];

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

  bool _hasActiveFilters() {
    return _selectedBloodType != null ||
        _selectedDistrict != null ||
        _selectedGender != null ||
        _selectedStatus != 'all';
  }

  List<DonorModel> _applyFilters(List<DonorModel> donors) {
    var filtered = donors;

    // فلتر نوع الدم
    if (_selectedBloodType != null) {
      filtered =
          filtered.where((d) => d.bloodType == _selectedBloodType).toList();
    }

    // فلتر المديرية
    if (_selectedDistrict != null) {
      filtered =
          filtered.where((d) => d.district == _selectedDistrict).toList();
    }

    // فلتر الجنس
    if (_selectedGender != null) {
      filtered = filtered.where((d) => d.gender == _selectedGender).toList();
    }

    // فلتر الحالة
    if (_selectedStatus == 'available') {
      filtered = filtered.where((d) => d.isAvailable).toList();
    } else if (_selectedStatus == 'suspended') {
      filtered = filtered.where((d) => !d.isAvailable).toList();
    }

    // الترتيب
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'name':
          return a.name.compareTo(b.name);
        case 'date':
          return b.createdAt.compareTo(a.createdAt);
        case 'bloodType':
          return a.bloodType.compareTo(b.bloodType);
        default:
          return 0;
      }
    });

    return filtered;
  }

  void _clearAllFilters() {
    setState(() {
      _selectedBloodType = null;
      _selectedDistrict = null;
      _selectedGender = null;
      _selectedStatus = 'all';
      _searchController.clear();
    });
    context.read<DonorProvider>().clearSearchResults();
    context.read<DonorProvider>().loadDonors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // شريط البحث
          _buildSearchBar(),

          // الفلاتر (قابلة للطي)
          if (_showFilters) _buildFilters(),

          // الإحصائيات السريعة
          _buildQuickStats(),

          // القائمة
          Expanded(child: _buildDonorsList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (_) => const AddDonorScreen(),
                ),
              )
              .then((_) => context.read<DonorProvider>().loadDonors());
        },
        icon: const Icon(Icons.person_add),
        label: const Text('إضافة متبرع'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('إدارة المتبرعين'),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      actions: [
        // زر الفلاتر
        IconButton(
          icon: Icon(
            _showFilters ? Icons.filter_list_off : Icons.filter_list,
          ),
          onPressed: () {
            setState(() {
              _showFilters = !_showFilters;
            });
          },
          tooltip: _showFilters ? 'إخفاء الفلاتر' : 'إظهار الفلاتر',
        ),
        // زر مسح الفلاتر
        if (_hasActiveFilters())
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearAllFilters,
            tooltip: 'مسح جميع الفلاتر',
          ),
      ],
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
                    setState(() {});
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: AppColors.background,
        ),
        onChanged: (query) {
          setState(() {});
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

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.filter_alt, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'الفلاتر',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // صف الفلاتر الأول
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  'فصيلة الدم',
                  _selectedBloodType,
                  _bloodTypes,
                  (value) => setState(() => _selectedBloodType = value),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterDropdown(
                  'المديرية',
                  _selectedDistrict,
                  _districts,
                  (value) => setState(() => _selectedDistrict = value),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // صف الفلاتر الثاني
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  'الجنس',
                  _selectedGender,
                  _genders,
                  (value) => setState(() => _selectedGender = value),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterDropdown(
                  'الحالة',
                  _selectedStatus,
                  ['all', 'available', 'suspended'],
                  (value) => setState(() => _selectedStatus = value ?? 'all'),
                  displayNames: {
                    'all': 'الكل',
                    'available': 'متاح',
                    'suspended': 'موقوف',
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // الترتيب
          DropdownButtonFormField<String>(
            value: _sortBy,
            decoration: InputDecoration(
              labelText: 'الترتيب حسب',
              prefixIcon: const Icon(Icons.sort, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: const [
              DropdownMenuItem(value: 'name', child: Text('الاسم')),
              DropdownMenuItem(value: 'date', child: Text('الأحدث')),
              DropdownMenuItem(value: 'bloodType', child: Text('فصيلة الدم')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _sortBy = value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged, {
    Map<String, String>? displayNames,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      hint: Text('الكل'),
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(displayNames?[item] ?? item),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildQuickStats() {
    return Consumer<DonorProvider>(
      builder: (context, provider, _) {
        final allDonors = _searchController.text.isNotEmpty
            ? provider.searchResults
            : provider.donors;

        final filteredDonors = _applyFilters(allDonors);
        final availableCount =
            filteredDonors.where((d) => d.isAvailable).length;
        final suspendedCount = filteredDonors.length - availableCount;

        // إحصائيات فصائل الدم
        final bloodTypeStats = <String, int>{};
        for (var donor in filteredDonors) {
          bloodTypeStats[donor.bloodType] =
              (bloodTypeStats[donor.bloodType] ?? 0) + 1;
        }
        final mostCommonBloodType = bloodTypeStats.isNotEmpty
            ? bloodTypeStats.entries
                .reduce((a, b) => a.value > b.value ? a : b)
                .key
            : '-';

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.primaryDark.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _buildStatItem(
                    'الإجمالي',
                    '${filteredDonors.length}',
                    Icons.people,
                    AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  _buildStatItem(
                    'متاح',
                    '$availableCount',
                    Icons.favorite,
                    AppColors.success,
                  ),
                  const SizedBox(width: 12),
                  _buildStatItem(
                    'موقوف',
                    '$suspendedCount',
                    Icons.block,
                    AppColors.warning,
                  ),
                ],
              ),
              if (filteredDonors.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.analytics,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'أكثر فصيلة: $mostCommonBloodType (${bloodTypeStats[mostCommonBloodType] ?? 0})',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
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

        final allDonors = _searchController.text.isNotEmpty
            ? provider.searchResults
            : provider.donors;

        final filteredDonors = _applyFilters(allDonors);

        if (filteredDonors.isEmpty) {
          return EmptyState(
            icon: Icons.search_off,
            title: 'لا توجد نتائج',
            message: _searchController.text.isNotEmpty || _hasActiveFilters()
                ? 'لم يتم العثور على متبرعين تطابق البحث'
                : 'لم يتم إضافة أي متبرع بعد',
            actionLabel: _hasActiveFilters() ? 'مسح الفلاتر' : null,
            onAction: _hasActiveFilters() ? _clearAllFilters : null,
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadDonors(),
          child: Column(
            children: [
              // عدد النتائج
              if (filteredDonors.length != allDonors.length)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: AppColors.info.withOpacity(0.1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.filter_list, size: 16, color: AppColors.info),
                      const SizedBox(width: 8),
                      Text(
                        'عرض ${filteredDonors.length} من ${allDonors.length} متبرع',
                        style: TextStyle(
                          color: AppColors.info,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

              // القائمة
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: filteredDonors.length,
                  itemBuilder: (context, index) {
                    final donor = filteredDonors[index];
                    return ExpandableDonorCard(donor: donor);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

