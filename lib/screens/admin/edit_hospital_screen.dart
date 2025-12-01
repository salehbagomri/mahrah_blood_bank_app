import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/hospital_model.dart';
import '../../services/hospital_service.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/loading_widget.dart';

/// شاشة تعديل مستشفى
class EditHospitalScreen extends StatefulWidget {
  final HospitalModel hospital;

  const EditHospitalScreen({
    super.key,
    required this.hospital,
  });

  @override
  State<EditHospitalScreen> createState() => _EditHospitalScreenState();
}

class _EditHospitalScreenState extends State<EditHospitalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hospitalService = HospitalService();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  String? _selectedDistrict;

  bool _isLoading = false;

  // قائمة المديريات
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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.hospital.name);
    _emailController = TextEditingController(text: widget.hospital.email);
    _phoneController =
        TextEditingController(text: widget.hospital.phoneNumber);
    _selectedDistrict = widget.hospital.district;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _updateHospital() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDistrict == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار المديرية'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedHospital = widget.hospital.copyWith(
        name: _nameController.text.trim(),
        district: _selectedDistrict!,
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
      );

      await _hospitalService.updateHospital(updatedHospital);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث بيانات المستشفى بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تحديث البيانات: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل مستشفى'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // كارد معلومات المستشفى
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.primaryDark
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.local_hospital,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'تعديل بيانات المستشفى',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.hospital.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // اسم المستشفى
                  CustomTextField(
                    controller: _nameController,
                    label: 'اسم المستشفى',
                    hint: 'أدخل اسم المستشفى',
                    icon: Icons.local_hospital,
                    validator: Validators.validateName,
                  ),

                  const SizedBox(height: 16),

                  // البريد الإلكتروني (غير قابل للتعديل)
                  CustomTextField(
                    controller: _emailController,
                    label: 'البريد الإلكتروني (غير قابل للتعديل)',
                    hint: 'البريد الإلكتروني',
                    icon: Icons.email,
                    enabled: false,
                  ),

                  const SizedBox(height: 16),

                  // المديرية
                  CustomDropdown(
                    label: 'المديرية',
                    value: _selectedDistrict,
                    items: _districts,
                    onChanged: (value) {
                      setState(() {
                        _selectedDistrict = value;
                      });
                    },
                    icon: Icons.location_on,
                  ),

                  const SizedBox(height: 16),

                  // رقم الهاتف (اختياري)
                  CustomTextField(
                    controller: _phoneController,
                    label: '${AppStrings.phoneNumber} (${AppStrings.optional})',
                    hint: '777123456',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 32),

                  // زر التحديث
                  ElevatedButton(
                    onPressed: _isLoading ? null : _updateHospital,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'تحديث البيانات',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ملاحظة
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.info.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: AppColors.info,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'ملاحظة: لا يمكن تعديل البريد الإلكتروني. في حال الحاجة لتغييره، يرجى التواصل مع الدعم الفني.',
                            style: TextStyle(
                              color: AppColors.info,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: LoadingWidget(message: 'جاري تحديث البيانات...'),
              ),
            ),
        ],
      ),
    );
  }
}

