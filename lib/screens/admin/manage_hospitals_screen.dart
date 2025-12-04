import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/hospital_model.dart';
import '../../services/hospital_service.dart';
import '../../utils/error_handler.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state.dart';
import 'add_hospital_screen.dart';

/// شاشة إدارة المستشفيات (للأدمن)
class ManageHospitalsScreen extends StatefulWidget {
  const ManageHospitalsScreen({super.key});

  @override
  State<ManageHospitalsScreen> createState() => _ManageHospitalsScreenState();
}

class _ManageHospitalsScreenState extends State<ManageHospitalsScreen> {
  final _hospitalService = HospitalService();
  List<HospitalModel> _hospitals = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHospitals();
  }

  Future<void> _loadHospitals() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final hospitals = await _hospitalService.getAllHospitals();
      setState(() {
        _hospitals = hospitals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = ErrorHandler.getArabicMessage(e);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.manageHospitals),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHospitals,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddHospitalScreen(),
            ),
          ).then((result) {
            if (result == true) {
              _loadHospitals();
            }
          });
        },
        icon: const Icon(Icons.add),
        label: const Text('إضافة مستشفى'),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget(message: 'جاري تحميل المستشفيات...');
    }

    if (_errorMessage != null) {
      return EmptyState(
        icon: Icons.error_outline,
        title: 'حدث خطأ',
        message: _errorMessage!,
        actionLabel: 'إعادة المحاولة',
        onAction: _loadHospitals,
      );
    }

    if (_hospitals.isEmpty) {
      return EmptyState(
        icon: Icons.local_hospital,
        title: 'لا توجد مستشفيات',
        message: 'لم يتم إضافة أي مستشفى بعد',
        actionLabel: 'إضافة مستشفى',
        onAction: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddHospitalScreen(),
            ),
          ).then((result) {
            if (result == true) {
              _loadHospitals();
            }
          });
        },
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHospitals,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _hospitals.length,
        itemBuilder: (context, index) {
          final hospital = _hospitals[index];
          return _HospitalCard(
            hospital: hospital,
            onToggleStatus: () => _toggleHospitalStatus(hospital),
            onEdit: () => _showEditHospitalDialog(hospital),
            onDelete: () => _deleteHospital(hospital),
          );
        },
      ),
    );
  }

  Future<void> _toggleHospitalStatus(HospitalModel hospital) async {
    try {
      await _hospitalService.toggleHospitalStatus(
        hospital.id,
        !hospital.isActive,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              hospital.isActive ? 'تم تعطيل المستشفى' : 'تم تفعيل المستشفى',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        _loadHospitals();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تحديث حالة المستشفى: ${ErrorHandler.getArabicMessage(e)}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteHospital(HospitalModel hospital) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف ${hospital.name}؟\n\nهذا الإجراء لا يمكن التراجع عنه.'),
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

    if (confirmed == true) {
      try {
        await _hospitalService.deleteHospital(hospital.id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف المستشفى بنجاح'),
              backgroundColor: AppColors.success,
            ),
          );
          _loadHospitals();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل حذف المستشفى: ${ErrorHandler.getArabicMessage(e)}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }


  void _showEditHospitalDialog(HospitalModel hospital) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل المستشفى'),
        content: Text('تعديل ${hospital.name}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
        ],
      ),
    );
  }
}

/// بطاقة المستشفى
class _HospitalCard extends StatelessWidget {
  final HospitalModel hospital;
  final VoidCallback onToggleStatus;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _HospitalCard({
    required this.hospital,
    required this.onToggleStatus,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hospital.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hospital.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: hospital.isActive
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    hospital.isActive ? 'نشط' : 'معطل',
                    style: TextStyle(
                      color: hospital.isActive ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  hospital.district,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (hospital.phoneNumber != null) ...[
                  const SizedBox(width: 16),
                  Icon(
                    Icons.phone,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    hospital.phoneNumber!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onToggleStatus,
                  icon: Icon(
                    hospital.isActive ? Icons.block : Icons.check_circle,
                    size: 18,
                  ),
                  label: Text(hospital.isActive ? 'تعطيل' : 'تفعيل'),
                ),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text(AppStrings.delete),
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

