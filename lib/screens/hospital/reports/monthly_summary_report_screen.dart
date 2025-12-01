import 'package:flutter/material.dart';
import '../../../widgets/empty_state.dart';

/// تقرير النشاط الشهري
class MonthlySummaryReportScreen extends StatelessWidget {
  const MonthlySummaryReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📅 تقرير النشاط الشهري'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: const EmptyState(
        icon: Icons.calendar_month,
        title: 'قريباً',
        message: 'سيتم إضافة تقرير النشاط الشهري قريباً',
      ),
    );
  }
}

