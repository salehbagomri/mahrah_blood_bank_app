import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

/// Provider لإدارة حالة المصادقة
class AuthProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  User? _currentUser;
  String? _userType; // 'admin' or 'hospital' or null
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get currentUser => _currentUser;
  String? get userType => _userType;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _userType == 'admin';
  bool get isHospital => _userType == 'hospital';

  AuthProvider() {
    _initializeAuth();
  }

  /// تهيئة المصادقة
  void _initializeAuth() {
    _currentUser = _supabaseService.currentUser;
    if (_currentUser != null) {
      _loadUserType();
    }

    // الاستماع لتغييرات حالة المصادقة
    _supabaseService.authStateChanges.listen((authState) {
      _currentUser = authState.session?.user;
      if (_currentUser != null) {
        _loadUserType();
      } else {
        _userType = null;
      }
      notifyListeners();
    });
  }

  /// تحميل نوع المستخدم
  Future<void> _loadUserType() async {
    try {
      _userType = await _supabaseService.getUserType();
      notifyListeners();
    } catch (e) {
      debugPrint('خطأ في تحميل نوع المستخدم: $e');
    }
  }

  /// تسجيل الدخول
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabaseService.signIn(
        email: email,
        password: password,
      );

      _currentUser = response.user;
      if (_currentUser != null) {
        await _loadUserType();
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = _getArabicErrorMessage(e.message);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'حدث خطأ غير متوقع: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _supabaseService.signOut();
      _currentUser = null;
      _userType = null;
    } catch (e) {
      _errorMessage = 'فشل تسجيل الخروج: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ترجمة رسائل الخطأ إلى العربية
  String _getArabicErrorMessage(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
    } else if (message.contains('Email not confirmed')) {
      return 'يرجى تأكيد البريد الإلكتروني أولاً';
    } else if (message.contains('User not found')) {
      return 'المستخدم غير موجود';
    } else if (message.contains('Network')) {
      return 'يرجى التحقق من الاتصال بالإنترنت';
    }
    return message;
  }

  /// مسح رسالة الخطأ
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

