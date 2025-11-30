/// إعدادات Supabase
/// 
/// ملاحظة مهمة: لا تقم برفع هذا الملف إلى Git مع المفاتيح الحقيقية
/// استخدم ملف .env أو environment variables في الإنتاج
class SupabaseConfig {
  // ضع هنا URL و ANON KEY من مشروعك في Supabase
  // يمكنك الحصول عليهما من: Supabase Dashboard > Settings > API
  
  /// عنوان مشروع Supabase
  /// مثال: https://abcdefghijklmnop.supabase.co
  static const String supabaseUrl = 'https://mgeshfxrcdilwjohoniv.supabase.co';
  
  /// المفتاح العام (Anon Key)
  /// يمكن استخدامه في التطبيق بشكل آمن
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1nZXNoZnhyY2RpbHdqb2hvbml2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ0NDU5MDEsImV4cCI6MjA4MDAyMTkwMX0.7Ypc4eQWJRU1hfb1TLzG-qhSMQ8rIsE9OOAxATQvaAA';
  
  /// ملاحظات:
  /// 1. لا تستخدم service_role key في التطبيق أبداً
  /// 2. المفتاح العام (anon key) آمن للاستخدام في التطبيق
  /// 3. الحماية تتم عبر Row Level Security (RLS) في Supabase
  /// 4. في الإنتاج، استخدم environment variables بدلاً من hardcoding
  
  /// التحقق من صحة الإعدادات
  static bool get isConfigured {
    return supabaseUrl != 'YOUR_SUPABASE_URL' &&
           supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY';
  }
}

