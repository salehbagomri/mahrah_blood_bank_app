import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../providers/donor_provider.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/expandable_donor_card.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/empty_state.dart';

/// صفحة البحث المحسّنة عن المتبرعين
class SearchDonorsScreen extends StatefulWidget {
  const SearchDonorsScreen({super.key});

  @override
  State<SearchDonorsScreen> createState() => _SearchDonorsScreenState();
}

class _SearchDonorsScreenState extends State<SearchDonorsScreen>
    with SingleTickerProviderStateMixin {
  // حالة البحث
  String? _selectedBloodType;
  String? _selectedDistrict;
  String? _selectedGender;
  String _sortBy = 'name'; // name | district | blood_type
  bool _availableOnly = true;
  bool _hasSearched = false;

  // بحث نصي
  final TextEditingController _textController = TextEditingController();
  Timer? _debounce;
  bool _isTextSearch = false; // هل البحث الحالي نصي أم متقدم؟

  // فصائل الدم الـ 8
  static const List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  // ألوان فصائل الدم
  static const Map<String, Color> _bloodTypeColors = {
    'A+': Color(0xFFE53935),
    'A-': Color(0xFFEF5350),
    'B+': Color(0xFF1E88E5),
    'B-': Color(0xFF42A5F5),
    'AB+': Color(0xFF8E24AA),
    'AB-': Color(0xFFAB47BC),
    'O+': Color(0xFF43A047),
    'O-': Color(0xFF66BB6A),
  };

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _textController.dispose();
    _debounce?.cancel();
    _animController.dispose();
    super.dispose();
  }

  // ==================== منطق البحث ====================

  /// البحث النصي (مع Debounce 600ms)
  void _onTextChanged(String query) {
    _debounce?.cancel();
    if (query.isEmpty) {
      setState(() {
        _isTextSearch = false;
        _hasSearched = false;
      });
      context.read<DonorProvider>().clearSearchResults();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _isTextSearch = true;
        _hasSearched = true;
        _selectedBloodType = null; // مسح الفصيلة عند البحث النصي
      });
      context.read<DonorProvider>().searchByNameOrPhone(query);
      _animController
        ..reset()
        ..forward();
    });
  }

  /// البحث بالفصيلة (اضغطة واحدة)
  void _onBloodTypeChipTap(String bloodType) {
    final newType = _selectedBloodType == bloodType ? null : bloodType;
    setState(() {
      _selectedBloodType = newType;
      _isTextSearch = false;
      _textController.clear();
    });
    if (newType != null) {
      _performAdvancedSearch();
    } else {
      setState(() => _hasSearched = false);
      context.read<DonorProvider>().clearSearchResults();
    }
  }

  /// البحث المتقدم (فصيلة + مديرية + جنس + ترتيب)
  void _performAdvancedSearch() {
    if (_selectedBloodType == null && _selectedDistrict == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('اختر فصيلة الدم أو المديرية للبحث'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    setState(() {
      _hasSearched = true;
      _isTextSearch = false;
    });
    context.read<DonorProvider>().searchDonors(
      bloodType: _selectedBloodType,
      district: _selectedDistrict,
      availableOnly: _availableOnly,
    );
    _animController
      ..reset()
      ..forward();
  }

  /// مسح كل شيء
  void _clearAll() {
    setState(() {
      _selectedBloodType = null;
      _selectedDistrict = null;
      _selectedGender = null;
      _hasSearched = false;
      _isTextSearch = false;
    });
    _textController.clear();
    _debounce?.cancel();
    context.read<DonorProvider>().clearSearchResults();
  }

  // ==================== الفلترة المحلية للنتائج ====================

  List _filteredResults(List donors) {
    var list = List.from(donors);
    if (_selectedGender != null) {
      list = list.where((d) => d.gender == _selectedGender).toList();
    }
    switch (_sortBy) {
      case 'district':
        list.sort((a, b) => a.district.compareTo(b.district));
        break;
      case 'blood_type':
        list.sort((a, b) => a.bloodType.compareTo(b.bloodType));
        break;
      default:
        list.sort((a, b) => a.name.compareTo(b.name));
    }
    return list;
  }

  // ==================== UI ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.searchForDonors),
        elevation: 0,
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
      body: Column(
        children: [
          // ==================== قسم البحث ====================
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---- شريط البحث النصي ----
                TextField(
                  controller: _textController,
                  onChanged: _onTextChanged,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    hintText: 'ابحث بالاسم أو رقم الهاتف...',
                    hintTextDirection: TextDirection.rtl,
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.primary,
                    ),
                    suffixIcon: _textController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _textController.clear();
                              _onTextChanged('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                  ),
                ),

                const SizedBox(height: 14),

                // ---- عنوان: فصيلة الدم بضغطة واحدة ----
                Row(
                  children: [
                    const Icon(
                      Icons.bloodtype,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'فصيلة الدم',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                    if (_selectedBloodType != null) ...[
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _onBloodTypeChipTap(_selectedBloodType!),
                        child: Text(
                          'مسح',
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),

                // ---- الـ 8 Chips لفصائل الدم ----
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: _bloodTypes.map((bt) {
                    final isSelected = _selectedBloodType == bt;
                    final color = _bloodTypeColors[bt] ?? AppColors.primary;
                    return GestureDetector(
                      onTap: () => _onBloodTypeChipTap(bt),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? color : color.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? color : color.withOpacity(0.3),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withOpacity(0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          bt,
                          style: TextStyle(
                            color: isSelected ? Colors.white : color,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 12),

                // ---- فلاتر إضافية (قابلة للطي) ----
                _buildAdvancedFilters(),
              ],
            ),
          ),

          // ==================== النتائج ====================
          Expanded(
            child: Consumer<DonorProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const DonorListShimmer(count: 5);
                }

                if (provider.hasError && _hasSearched) {
                  return EmptyState(
                    icon: Icons.error_outline,
                    title: 'حدث خطأ',
                    message: provider.errorMessage ?? 'حدث خطأ غير متوقع',
                    actionLabel: 'إعادة المحاولة',
                    onAction: _performAdvancedSearch,
                  );
                }

                if (!_hasSearched) {
                  return _buildInitialHint();
                }

                final raw = provider.searchResults;
                final results = _filteredResults(raw);

                if (results.isEmpty) {
                  return EmptyState(
                    icon: Icons.search_off,
                    title: AppStrings.noDonorsFound,
                    message: AppStrings.noDonorsMessage,
                    actionLabel: 'مسح البحث',
                    onAction: _clearAll,
                  );
                }

                return FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(
                    children: [
                      _buildResultsHeader(results.length),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: results.length,
                          itemBuilder: (context, index) => ExpandableDonorCard(
                            donor: results[index],
                            showManagementActions: false,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Widgets مساعدة ====================

  /// فلاتر إضافية قابلة للطي
  Widget _buildAdvancedFilters() {
    return ExpansionTile(
      key: const Key('advanced_filters'),
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 8),
      title: Row(
        children: [
          Icon(Icons.tune, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            'فلاتر إضافية',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (_selectedDistrict != null || _selectedGender != null) ...[
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
      children: [
        const SizedBox(height: 4),

        // مديرية
        CustomDropdown(
          value: _selectedDistrict,
          items: AppStrings.districts,
          hint: AppStrings.selectDistrict,
          label: AppStrings.district,
          icon: Icons.location_on,
          onChanged: (v) {
            setState(() => _selectedDistrict = v);
            if (_hasSearched) _performAdvancedSearch();
          },
        ),

        const SizedBox(height: 10),

        // جنس + ترتيب في صف واحد
        Row(
          children: [
            // فلتر الجنس
            Expanded(
              child: _buildSegmentedControl(
                label: 'الجنس',
                icon: Icons.wc,
                options: const {'الكل': null, 'ذكر': 'male', 'أنثى': 'female'},
                selected: _selectedGender,
                onSelect: (v) {
                  setState(() => _selectedGender = v);
                },
              ),
            ),
            const SizedBox(width: 12),
            // ترتيب النتائج
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.sort,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'الترتيب',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _sortBy,
                    isDense: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'name', child: Text('الاسم')),
                      DropdownMenuItem(
                        value: 'district',
                        child: Text('المديرية'),
                      ),
                      DropdownMenuItem(
                        value: 'blood_type',
                        child: Text('الفصيلة'),
                      ),
                    ],
                    onChanged: (v) => setState(() => _sortBy = v!),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // متاح للتبرع + زر بحث
        Row(
          children: [
            // سويتش "متاح فقط"
            Expanded(
              child: Row(
                children: [
                  Switch.adaptive(
                    value: _availableOnly,
                    activeColor: AppColors.success,
                    onChanged: (v) {
                      setState(() => _availableOnly = v);
                      if (_hasSearched && !_isTextSearch) {
                        _performAdvancedSearch();
                      }
                    },
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'متاحون فقط',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // زر بحث
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _performAdvancedSearch,
                icon: const Icon(Icons.search, size: 18),
                label: const Text('بحث'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 11,
                    horizontal: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),

        if (_hasSearched)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _clearAll,
              icon: const Icon(Icons.clear_all, size: 16),
              label: const Text('مسح الكل'),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
            ),
          ),
      ],
    );
  }

  /// Segmented control بسيط للجنس
  Widget _buildSegmentedControl({
    required String label,
    required IconData icon,
    required Map<String, String?> options,
    required String? selected,
    required Function(String?) onSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: options.entries.map((e) {
              final isActive = e.value == selected;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onSelect(isActive ? null : e.value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(
                      e.key,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isActive
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// رأس النتائج مع عدادها وخيار الترتيب
  Widget _buildResultsHeader(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 16),
                const SizedBox(width: 5),
                Text(
                  '$count متبرع',
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // مؤشر الأوفلاين
          Consumer<DonorProvider>(
            builder: (_, p, __) => p.isOffline
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.wifi_off,
                          size: 12,
                          color: Colors.orange.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'بيانات محفوظة',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// الشاشة الأولية (قبل أي بحث)
  Widget _buildInitialHint() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Icon(
            Icons.manage_search,
            size: 72,
            color: AppColors.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'ابحث عن متبرع',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اكتب الاسم أو الرقم في الأعلى\nأو اضغط على فصيلة الدم مباشرةً',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              height: 1.6,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          // نصائح سريعة
          _buildTip(Icons.touch_app, 'اضغط فصيلة الدم للبحث الفوري'),
          const SizedBox(height: 10),
          _buildTip(Icons.search, 'ابحث بالاسم أو رقم الهاتف نصياً'),
          const SizedBox(height: 10),
          _buildTip(Icons.tune, 'استخدم الفلاتر للتضييق أكثر'),
          const SizedBox(height: 10),
          _buildTip(Icons.wifi_off, 'يعمل بدون إنترنت بالبيانات المحفوظة'),
        ],
      ),
    );
  }

  Widget _buildTip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
