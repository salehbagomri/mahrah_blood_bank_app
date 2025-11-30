import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/donor_model.dart';
import '../../providers/donor_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state.dart';
import '../donor/add_donor_screen.dart';

/// شاشة إدارة المتبرعين (للمستشفى) - محسّنة
class ManageDonorsHospitalScreen extends StatefulWidget {
  const ManageDonorsHospitalScreen({super.key});

  @override
  State<ManageDonorsHospitalScreen> createState() => _ManageDonorsHospitalScreenState();
}

class _ManageDonorsHospitalScreenState extends State<ManageDonorsHospitalScreen> {
  final _searchController = TextEditingController();
  
  // الفلاتر
  String? _selectedBloodType;
  String? _selectedDistrict;
  String? _selectedGender;
  String? _selectedStatus; // 'all', 'available', 'suspended'
  String _sortBy = 'name'; // 'name', 'date', 'bloodType'
  
  bool _showFilters = false;
  
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
          // زر الفلاتر
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
              color: _hasActiveFilters() ? AppColors.primary : null,
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
          // زر التحديث
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

  /// شريط البحث المحسّن
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
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'بحث بالاسم أو رقم الهاتف...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (query) {
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  /// قسم الفلاتر
  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الفلاتر',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (_hasActiveFilters())
                TextButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('مسح الكل'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // فصيلة الدم
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip(
                label: 'الكل',
                isSelected: _selectedBloodType == null,
                onTap: () => setState(() => _selectedBloodType = null),
              ),
              ...['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'].map(
                (type) => _buildFilterChip(
                  label: type,
                  isSelected: _selectedBloodType == type,
                  color: _getBloodTypeColor(type),
                  onTap: () => setState(() => _selectedBloodType = type),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // المديرية والجنس والحالة
          Row(
            children: [
              // المديرية
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedDistrict,
                  decoration: InputDecoration(
                    labelText: 'المديرية',
                    prefixIcon: const Icon(Icons.location_city, size: 18),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('الكل')),
                    ...AppStrings.districts.map(
                      (d) => DropdownMenuItem(value: d, child: Text(d)),
                    ),
                  ],
                  onChanged: (value) => setState(() => _selectedDistrict = value),
                ),
              ),
              const SizedBox(width: 8),
              
              // الجنس
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: InputDecoration(
                    labelText: 'الجنس',
                    prefixIcon: const Icon(Icons.person, size: 18),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('الكل')),
                    DropdownMenuItem(value: 'male', child: Text('ذكر')),
                    DropdownMenuItem(value: 'female', child: Text('أنثى')),
                  ],
                  onChanged: (value) => setState(() => _selectedGender = value),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // الحالة والترتيب
          Row(
            children: [
              // الحالة
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus ?? 'all',
                  decoration: InputDecoration(
                    labelText: 'الحالة',
                    prefixIcon: const Icon(Icons.check_circle, size: 18),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('الكل')),
                    DropdownMenuItem(value: 'available', child: Text('متاح')),
                    DropdownMenuItem(value: 'suspended', child: Text('موقوف')),
                  ],
                  onChanged: (value) => setState(() => _selectedStatus = value),
                ),
              ),
              const SizedBox(width: 8),
              
              // الترتيب
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _sortBy,
                  decoration: InputDecoration(
                    labelText: 'ترتيب حسب',
                    prefixIcon: const Icon(Icons.sort, size: 18),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'name', child: Text('الاسم')),
                    DropdownMenuItem(value: 'date', child: Text('التاريخ')),
                    DropdownMenuItem(value: 'bloodType', child: Text('الفصيلة')),
                  ],
                  onChanged: (value) => setState(() => _sortBy = value ?? 'name'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// إحصائيات سريعة
  Widget _buildQuickStats() {
    return Consumer<DonorProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) return const SizedBox.shrink();
        
        final filteredDonors = _applyFilters(provider.donors);
        final availableCount = filteredDonors.where((d) => !d.isSuspended).length;
        final suspendedCount = filteredDonors.where((d) => d.isSuspended).length;
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary.withOpacity(0.1), Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border(
              bottom: BorderSide(color: AppColors.divider, width: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.people,
                label: 'الإجمالي',
                value: '${filteredDonors.length}',
                color: AppColors.primary,
              ),
              Container(width: 1, height: 30, color: AppColors.divider),
              _buildStatItem(
                icon: Icons.check_circle,
                label: 'متاح',
                value: '$availableCount',
                color: AppColors.success,
              ),
              Container(width: 1, height: 30, color: AppColors.divider),
              _buildStatItem(
                icon: Icons.pause_circle,
                label: 'موقوف',
                value: '$suspendedCount',
                color: AppColors.warning,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// قائمة المتبرعين
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

        final filteredDonors = _applyFilters(provider.donors);

        if (filteredDonors.isEmpty) {
          return EmptyState(
            icon: Icons.search_off,
            title: 'لا توجد نتائج',
            message: _hasActiveFilters() || _searchController.text.isNotEmpty
                ? 'لم يتم العثور على متبرعين بهذه المواصفات'
                : 'لم يتم إضافة أي متبرع بعد',
            actionLabel: _hasActiveFilters() ? 'مسح الفلاتر' : null,
            onAction: _hasActiveFilters() ? _clearFilters : null,
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadDonors(),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: filteredDonors.length,
            itemBuilder: (context, index) {
              final donor = filteredDonors[index];
              return _ExpandableDonorCard(donor: donor);
            },
          ),
        );
      },
    );
  }

  /// chip الفلتر
  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    Color? color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? AppColors.primary)
              : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (color ?? AppColors.primary)
                : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  /// تطبيق الفلاتر
  List<DonorModel> _applyFilters(List<DonorModel> donors) {
    var filtered = donors;

    // البحث النصي
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((d) =>
        d.name.toLowerCase().contains(query) ||
        d.phoneNumber.contains(query) ||
        (d.phoneNumber2?.contains(query) ?? false) ||
        (d.phoneNumber3?.contains(query) ?? false)
      ).toList();
    }

    // فصيلة الدم
    if (_selectedBloodType != null) {
      filtered = filtered.where((d) => d.bloodType == _selectedBloodType).toList();
    }

    // المديرية
    if (_selectedDistrict != null) {
      filtered = filtered.where((d) => d.district == _selectedDistrict).toList();
    }

    // الجنس
    if (_selectedGender != null) {
      filtered = filtered.where((d) => d.gender == _selectedGender).toList();
    }

    // الحالة
    if (_selectedStatus != null && _selectedStatus != 'all') {
      if (_selectedStatus == 'available') {
        filtered = filtered.where((d) => !d.isSuspended).toList();
      } else if (_selectedStatus == 'suspended') {
        filtered = filtered.where((d) => d.isSuspended).toList();
      }
    }

    // الترتيب
    switch (_sortBy) {
      case 'name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'date':
        filtered.sort((a, b) {
          final dateA = a.lastDonationDate ?? DateTime(2000);
          final dateB = b.lastDonationDate ?? DateTime(2000);
          return dateB.compareTo(dateA);
        });
        break;
      case 'bloodType':
        filtered.sort((a, b) => a.bloodType.compareTo(b.bloodType));
        break;
    }

    return filtered;
  }

  /// التحقق من وجود فلاتر نشطة
  bool _hasActiveFilters() {
    return _selectedBloodType != null ||
        _selectedDistrict != null ||
        _selectedGender != null ||
        (_selectedStatus != null && _selectedStatus != 'all');
  }

  /// مسح جميع الفلاتر
  void _clearFilters() {
    setState(() {
      _selectedBloodType = null;
      _selectedDistrict = null;
      _selectedGender = null;
      _selectedStatus = 'all';
      _searchController.clear();
    });
  }

  /// لون فصيلة الدم
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

/// كارد المتبرع القابل للطي
class _ExpandableDonorCard extends StatefulWidget {
  final DonorModel donor;

  const _ExpandableDonorCard({required this.donor});

  @override
  State<_ExpandableDonorCard> createState() => _ExpandableDonorCardState();
}

class _ExpandableDonorCardState extends State<_ExpandableDonorCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الجزء المرئي دائماً (مطوي)
              _buildCollapsedContent(),
              
              // الجزء القابل للتوسع
              if (_isExpanded) ...[
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                _buildExpandedContent(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// المحتوى المطوي (يظهر دائماً)
  Widget _buildCollapsedContent() {
    return Row(
      children: [
        // فصيلة الدم
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getBloodTypeColor(widget.donor.bloodType),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              widget.donor.bloodType,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // المعلومات الأساسية
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الاسم
              Text(
                widget.donor.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              
              const SizedBox(height: 6),
              
              // العمر والجنس والمديرية
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  _buildInfoChip(
                    Icons.cake_outlined,
                    '${widget.donor.age} سنة',
                  ),
                  _buildInfoChip(
                    widget.donor.gender == 'male' ? Icons.male : Icons.female,
                    widget.donor.gender == 'male' ? 'ذكر' : 'أنثى',
                  ),
                  _buildInfoChip(
                    Icons.location_on_outlined,
                    widget.donor.district,
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // سهم التوسع ومؤشر الحالة
        Column(
          children: [
            // مؤشر الحالة
            if (widget.donor.isSuspended)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'موقوف',
                  style: TextStyle(
                    color: AppColors.warning,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'متاح',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            
            const SizedBox(height: 8),
            
            // سهم التوسع
            Icon(
              _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: AppColors.primary,
              size: 28,
            ),
          ],
        ),
      ],
    );
  }

  /// المحتوى الموسع (يظهر عند الفتح)
  Widget _buildExpandedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // رقم الهاتف الأساسي
        _buildDetailRow(
          Icons.phone,
          'رقم الهاتف',
          widget.donor.phoneNumber,
        ),
        
        // الأرقام الإضافية
        if (widget.donor.phoneNumber2 != null) ...[
          const SizedBox(height: 8),
          _buildDetailRow(
            Icons.phone,
            'رقم إضافي 2',
            widget.donor.phoneNumber2!,
          ),
        ],
        
        if (widget.donor.phoneNumber3 != null) ...[
          const SizedBox(height: 8),
          _buildDetailRow(
            Icons.phone,
            'رقم إضافي 3',
            widget.donor.phoneNumber3!,
          ),
        ],
        
        // آخر تبرع
        if (widget.donor.lastDonationDate != null) ...[
          const SizedBox(height: 8),
          _buildDetailRow(
            Icons.history,
            'آخر تبرع',
            _formatDate(widget.donor.lastDonationDate!),
          ),
        ],
        
        // تاريخ الإيقاف
        if (widget.donor.isSuspended && widget.donor.suspendedUntil != null) ...[
          const SizedBox(height: 8),
          _buildDetailRow(
            Icons.pause_circle,
            'موقوف حتى',
            _formatDate(widget.donor.suspendedUntil!),
            valueColor: AppColors.warning,
          ),
        ],
        
        // الملاحظات
        if (widget.donor.notes != null && widget.donor.notes!.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildDetailRow(
            Icons.notes,
            'ملاحظات',
            widget.donor.notes!,
          ),
        ],
        
        const SizedBox(height: 16),
        
        // الأزرار
        _buildActions(),
      ],
    );
  }

  /// معلومة صغيرة (chip)
  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// صف معلومات مفصل
  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// أزرار الإجراءات
  Widget _buildActions() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // زر الاتصال
        ElevatedButton.icon(
          onPressed: () => _makePhoneCall(widget.donor.phoneNumber),
          icon: const Icon(Icons.phone, size: 16),
          label: const Text('اتصال'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
        
        // زر واتساب
        ElevatedButton.icon(
          onPressed: () => _openWhatsApp(widget.donor.phoneNumber, widget.donor.name),
          icon: const Icon(Icons.chat, size: 16),
          label: const Text('واتساب'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF25D366),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
        
        // زر إيقاف/تحديث
        if (!widget.donor.isSuspended)
          ElevatedButton.icon(
            onPressed: () => _suspendDonor(context),
            icon: const Icon(Icons.pause, size: 16),
            label: const Text('إيقاف 6 أشهر'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        
        // زر تحديث آخر تبرع
        ElevatedButton.icon(
          onPressed: () => _updateLastDonation(context),
          icon: const Icon(Icons.update, size: 16),
          label: const Text('تحديث التبرع'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.info,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
      ],
    );
  }

  /// فتح تطبيق الهاتف
  void _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  /// فتح واتساب
  void _openWhatsApp(String phoneNumber, String name) async {
    String formattedNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (!formattedNumber.startsWith('+')) {
      formattedNumber = '+967$formattedNumber';
    }
    
    final message = Uri.encodeComponent(
      'السلام عليكم ورحمة الله وبركاته\n'
      'نأمل منكم التبرع بالدم لإنقاذ حياة إنسان\n'
      'جزاكم الله خيراً'
    );
    
    final Uri whatsappUri = Uri.parse('https://wa.me/$formattedNumber?text=$message');
    
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    }
  }

  /// إيقاف المتبرع
  Future<void> _suspendDonor(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إيقاف المتبرع'),
        content: Text(
          'هل تريد إيقاف ${widget.donor.name} لمدة 6 أشهر؟\n\n'
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
          .suspendDonorFor6Months(widget.donor.id);
      
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

  /// تحديث آخر تبرع
  Future<void> _updateLastDonation(BuildContext context) async {
    final updatedDonor = widget.donor.copyWith(
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

  /// تنسيق التاريخ
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// لون فصيلة الدم
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
