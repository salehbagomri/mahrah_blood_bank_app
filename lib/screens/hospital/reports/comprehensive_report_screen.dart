import 'package:flutter/material.dart';
import '../../../widgets/empty_state.dart';

/// التقرير الشامل
class ComprehensiveReportScreen extends StatelessWidget {
  const ComprehensiveReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📋 التقرير الشامل'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange, Colors.deepOrange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: const EmptyState(
        icon: Icons.description,
        title: 'قريباً',
        message: 'سيتم إضافة التقرير الشامل قريباً',
      ),
    );
  }
}

