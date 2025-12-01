import 'package:flutter/material.dart';
import '../../../widgets/empty_state.dart';

/// تقرير المناطق الجغرافية
class DistrictReportScreen extends StatelessWidget {
  const DistrictReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📍 تقرير المناطق الجغرافية'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: const EmptyState(
        icon: Icons.location_on,
        title: 'قريباً',
        message: 'سيتم إضافة تقرير المناطق الجغرافية قريباً',
      ),
    );
  }
}

