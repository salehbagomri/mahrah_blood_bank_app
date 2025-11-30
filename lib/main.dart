import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'config/supabase_config.dart';
import 'constants/app_theme.dart';
import 'constants/app_strings.dart';
import 'services/supabase_service.dart';
import 'providers/auth_provider.dart';
import 'providers/donor_provider.dart';
import 'providers/statistics_provider.dart';
import 'screens/home/home_screen.dart';

void main() async {
  // تأكد من تهيئة Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // تثبيت اتجاه الشاشة (عمودي فقط)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // تهيئة Supabase
  if (SupabaseConfig.isConfigured) {
    await SupabaseService.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
  } else {
    debugPrint('⚠️ تحذير: لم يتم تكوين Supabase بعد!');
    debugPrint('يرجى تحديث lib/config/supabase_config.dart بمفاتيح مشروعك');
  }

  runApp(const MahrahBloodBankApp());
}

class MahrahBloodBankApp extends StatelessWidget {
  const MahrahBloodBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DonorProvider()),
        ChangeNotifierProvider(create: (_) => StatisticsProvider()),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        
        // السمة
        theme: AppTheme.lightTheme,
        
        // اللغة والاتجاه
        locale: const Locale('ar'),
        supportedLocales: const [
          Locale('ar'),
          Locale('en'),
        ],
        
        // Localization delegates
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        
        // اتجاه النص (من اليمين لليسار)
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          );
        },
        
        // الصفحة الرئيسية
        home: const SplashScreen(),
      ),
    );
  }
}

/// شاشة البداية (Splash Screen)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // انتظار قليلاً لعرض شاشة البداية
    await Future.delayed(const Duration(seconds: 2));

    // التحقق من تكوين Supabase
    if (!SupabaseConfig.isConfigured) {
      if (mounted) {
        _showConfigurationError();
      }
      return;
    }

    // الانتقال إلى الصفحة الرئيسية
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  void _showConfigurationError() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('خطأ في الإعدادات'),
        content: const Text(
          'لم يتم تكوين Supabase بعد!\n\n'
          'يرجى تحديث ملف:\n'
          'lib/config/supabase_config.dart\n\n'
          'بمفاتيح مشروعك من Supabase Dashboard',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // أيقونة التطبيق
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.bloodtype_rounded,
                  size: 70,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              
              const SizedBox(height: 30),
              
              // اسم التطبيق
              Text(
                AppStrings.appName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 10),
              
              Text(
                AppStrings.appNameEnglish,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              
              const SizedBox(height: 50),
              
              // مؤشر التحميل
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
