import 'package:flutter/material.dart';
import '../../../widgets/empty_state.dart';

/// تقرير التوفر والإيقاف
class AvailabilityReportScreen extends StatelessWidget {
  const AvailabilityReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('✅ تقرير التوفر والإيقاف'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.greenAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: const EmptyState(
        icon: Icons.check_circle,
        title: 'قريباً',
        message: 'سيتم إضافة تقرير التوفر والإيقاف قريباً',
      ),
    );
  }
}

