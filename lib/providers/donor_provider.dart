import 'package:flutter/foundation.dart';
import '../models/donor_model.dart';
import '../services/donor_service.dart';

/// Provider لإدارة حالة المتبرعين
class DonorProvider with ChangeNotifier {
  final DonorService _donorService = DonorService();

  List<DonorModel> _donors = [];
  List<DonorModel> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<DonorModel> get donors => _donors;
  List<DonorModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  /// البحث عن متبرعين
  Future<void> searchDonors({
    String? bloodType,
    String? district,
    bool availableOnly = true,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _searchResults = await _donorService.searchDonors(
        bloodType: bloodType,
        district: district,
        availableOnly: availableOnly,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// إضافة متبرع جديد
  Future<bool> addDonor(DonorModel donor) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newDonor = await _donorService.addDonor(donor);
      _donors.insert(0, newDonor);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// تحديث بيانات متبرع
  Future<bool> updateDonor(DonorModel donor) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedDonor = await _donorService.updateDonor(donor);
      
      // تحديث في القائمة الرئيسية
      final index = _donors.indexWhere((d) => d.id == updatedDonor.id);
      if (index != -1) {
        _donors[index] = updatedDonor;
      }
      
      // تحديث في نتائج البحث
      final searchIndex = _searchResults.indexWhere((d) => d.id == updatedDonor.id);
      if (searchIndex != -1) {
        _searchResults[searchIndex] = updatedDonor;
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// حذف متبرع
  Future<bool> deleteDonor(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _donorService.deleteDonor(id);
      _donors.removeWhere((d) => d.id == id);
      _searchResults.removeWhere((d) => d.id == id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// إيقاف متبرع لمدة 6 أشهر
  Future<bool> suspendDonorFor6Months(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedDonor = await _donorService.suspendDonorFor6Months(id);
      
      final index = _donors.indexWhere((d) => d.id == updatedDonor.id);
      if (index != -1) {
        _donors[index] = updatedDonor;
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// الحصول على جميع المتبرعين
  Future<void> loadDonors() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _donors = await _donorService.getAllDonors();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// البحث بالاسم أو رقم الهاتف
  Future<void> searchByNameOrPhone(String query) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _searchResults = await _donorService.searchByNameOrPhone(query);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// مسح نتائج البحث
  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }

  /// مسح رسالة الخطأ
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

