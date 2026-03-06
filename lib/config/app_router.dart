import 'package:flutter/material.dart';

import '../models/donor_model.dart';
import '../models/report_model.dart';
import '../models/hospital_model.dart';

import '../screens/auth/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/donor/add_donor_screen.dart';
import '../screens/donor/search_donors_screen.dart';

import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/manage_donors_screen.dart';
import '../screens/admin/manage_hospitals_screen.dart';
import '../screens/admin/add_hospital_screen.dart';
import '../screens/admin/edit_hospital_screen.dart';
import '../screens/admin/edit_donor_screen.dart';
import '../screens/admin/report_detail_screen.dart';
import '../screens/admin/review_reports_screen.dart';
import '../screens/admin/system_overview_screen.dart';

import '../screens/hospital/hospital_dashboard_screen.dart';
import '../screens/hospital/manage_donors_hospital_screen.dart';
import '../screens/hospital/suspended_donors_screen.dart';
import '../screens/hospital/advanced_search_screen.dart';
import '../screens/hospital/reports_hub_screen.dart';
import '../screens/hospital/reports/comprehensive_report_screen.dart';
import '../screens/hospital/reports/district_report_screen.dart';
import '../screens/hospital/reports/blood_type_detailed_report_screen.dart';
import '../screens/hospital/reports/availability_report_screen.dart';
import '../screens/hospital/reports/monthly_summary_report_screen.dart';
import '../screens/hospital/blood_type_report_screen.dart';
import '../screens/hospital/export_reports_screen.dart';

import '../screens/info/about_screen.dart';
import '../screens/info/contact_screen.dart';
import '../screens/awareness/awareness_screen.dart';
import '../screens/reports/report_donor_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String login = '/login';

  static const String addDonor = '/donor/add';
  static const String searchDonors = '/donor/search';

  static const String adminDashboard = '/admin/dashboard';
  static const String adminManageDonors = '/admin/manage_donors';
  static const String adminManageHospitals = '/admin/manage_hospitals';
  static const String adminAddHospital = '/admin/add_hospital';
  static const String adminEditHospital = '/admin/edit_hospital';
  static const String adminEditDonor = '/admin/edit_donor';
  static const String adminReportDetail = '/admin/report_detail';
  static const String adminReviewReports = '/admin/review_reports';
  static const String adminSystemOverview = '/admin/system_overview';

  static const String hospitalDashboard = '/hospital/dashboard';
  static const String hospitalManageDonors = '/hospital/manage_donors';
  static const String hospitalSuspendedDonors = '/hospital/suspended_donors';
  static const String hospitalAdvancedSearch = '/hospital/advanced_search';
  static const String hospitalReportsHub = '/hospital/reports_hub';
  static const String hospitalReportComprehensive =
      '/hospital/report/comprehensive';
  static const String hospitalReportDistrict = '/hospital/report/district';
  static const String hospitalReportBloodTypeDetailed =
      '/hospital/report/blood_type_detailed';
  static const String hospitalReportAvailability =
      '/hospital/report/availability';
  static const String hospitalReportMonthlySummary =
      '/hospital/report/monthly_summary';
  static const String hospitalReportBloodType = '/hospital/report/blood_type';
  static const String hospitalExportReports = '/hospital/export_reports';

  static const String infoAbout = '/info/about';
  static const String infoContact = '/info/contact';
  static const String awareness = '/awareness';
  static const String reportDonor = '/report_donor';

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case addDonor:
        return MaterialPageRoute(builder: (_) => const AddDonorScreen());
      case searchDonors:
        return MaterialPageRoute(builder: (_) => const SearchDonorsScreen());

      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      case adminManageDonors:
        return MaterialPageRoute(builder: (_) => const ManageDonorsScreen());
      case adminManageHospitals:
        return MaterialPageRoute(builder: (_) => const ManageHospitalsScreen());
      case adminAddHospital:
        return MaterialPageRoute(builder: (_) => const AddHospitalScreen());
      case adminEditHospital:
        if (settings.arguments is HospitalModel) {
          final hospital = settings.arguments as HospitalModel;
          return MaterialPageRoute(
            builder: (_) => EditHospitalScreen(hospital: hospital),
          );
        }
        return _errorRoute();
      case adminEditDonor:
        if (settings.arguments is DonorModel) {
          final donor = settings.arguments as DonorModel;
          return MaterialPageRoute(
            builder: (_) => EditDonorScreen(donor: donor),
          );
        }
        return _errorRoute();
      case adminReportDetail:
        if (settings.arguments is ReportModel) {
          final report = settings.arguments as ReportModel;
          return MaterialPageRoute(
            builder: (_) => ReportDetailScreen(report: report),
          );
        }
        return _errorRoute();
      case adminReviewReports:
        return MaterialPageRoute(builder: (_) => const ReviewReportsScreen());
      case adminSystemOverview:
        return MaterialPageRoute(builder: (_) => const SystemOverviewScreen());

      case hospitalDashboard:
        return MaterialPageRoute(
          builder: (_) => const HospitalDashboardScreen(),
        );
      case hospitalManageDonors:
        return MaterialPageRoute(
          builder: (_) => const ManageDonorsHospitalScreen(),
        );
      case hospitalSuspendedDonors:
        return MaterialPageRoute(builder: (_) => const SuspendedDonorsScreen());
      case hospitalAdvancedSearch:
        return MaterialPageRoute(builder: (_) => const AdvancedSearchScreen());
      case hospitalReportsHub:
        return MaterialPageRoute(builder: (_) => const ReportsHubScreen());
      case hospitalReportComprehensive:
        return MaterialPageRoute(
          builder: (_) => const ComprehensiveReportScreen(),
        );
      case hospitalReportDistrict:
        return MaterialPageRoute(builder: (_) => const DistrictReportScreen());
      case hospitalReportBloodTypeDetailed:
        return MaterialPageRoute(
          builder: (_) => const BloodTypeDetailedReportScreen(),
        );
      case hospitalReportAvailability:
        return MaterialPageRoute(
          builder: (_) => const AvailabilityReportScreen(),
        );
      case hospitalReportMonthlySummary:
        return MaterialPageRoute(
          builder: (_) => const MonthlySummaryReportScreen(),
        );
      case hospitalReportBloodType:
        return MaterialPageRoute(builder: (_) => const BloodTypeReportScreen());
      case hospitalExportReports:
        return MaterialPageRoute(builder: (_) => const ExportReportsScreen());

      case infoAbout:
        return MaterialPageRoute(builder: (_) => const AboutScreen());
      case infoContact:
        return MaterialPageRoute(builder: (_) => const ContactScreen());
      case awareness:
        return MaterialPageRoute(builder: (_) => const AwarenessScreen());
      case reportDonor:
        return MaterialPageRoute(builder: (_) => const ReportDonorScreen());

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('خطأ في التنقل')),
        body: const Center(
          child: Text('عذراً، لم يتم العثور على الشاشة المطلوبة'),
        ),
      ),
    );
  }
}
