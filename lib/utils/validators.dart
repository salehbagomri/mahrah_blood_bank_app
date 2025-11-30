/// مجموعة من الدوال للتحقق من صحة المدخلات
class Validators {
  /// التحقق من صحة الاسم
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الاسم مطلوب';
    }
    if (value.trim().length < 3) {
      return 'الاسم يجب أن يكون 3 أحرف على الأقل';
    }
    return null;
  }

  /// التحقق من صحة رقم الهاتف اليمني
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'رقم الهاتف مطلوب';
    }
    
    // إزالة المسافات والرموز
    final cleanNumber = value.replaceAll(RegExp(r'[^\d]'), '');
    
    // التحقق من طول الرقم (يمني: 9 أرقام بعد 00967 أو 9 أرقام تبدأ بـ 7)
    if (cleanNumber.length == 9 && cleanNumber.startsWith('7')) {
      return null; // رقم صحيح
    }
    
    if (cleanNumber.length == 12 && cleanNumber.startsWith('967')) {
      return null; // رقم صحيح
    }
    
    if (cleanNumber.length == 14 && cleanNumber.startsWith('00967')) {
      return null; // رقم صحيح
    }
    
    return 'رقم الهاتف غير صالح. يجب أن يبدأ بـ 7';
  }

  /// التحقق من صحة العمر
  static String? validateAge(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'العمر مطلوب';
    }
    
    final age = int.tryParse(value);
    if (age == null) {
      return 'العمر يجب أن يكون رقماً';
    }
    
    if (age < 18) {
      return 'العمر يجب أن يكون 18 سنة على الأقل';
    }
    
    if (age > 65) {
      return 'العمر يجب أن يكون 65 سنة أو أقل';
    }
    
    return null;
  }

  /// التحقق من صحة البريد الإلكتروني
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'البريد الإلكتروني غير صالح';
    }
    
    return null;
  }

  /// التحقق من صحة كلمة المرور
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    
    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    
    return null;
  }

  /// التحقق من أن الحقل غير فارغ
  static String? validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName مطلوب';
    }
    return null;
  }

  /// التحقق من أن القيمة من ضمن قائمة محددة
  static String? validateInList(
    String? value,
    List<String> options,
    String fieldName,
  ) {
    if (value == null || value.isEmpty) {
      return '$fieldName مطلوب';
    }
    
    if (!options.contains(value)) {
      return '$fieldName غير صالح';
    }
    
    return null;
  }
}

