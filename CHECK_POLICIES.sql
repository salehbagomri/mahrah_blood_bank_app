-- ============================================
-- فحص جميع السياسات الحالية
-- ============================================

SELECT 
    tablename as "الجدول",
    policyname as "اسم السياسة",
    cmd as "العملية",
    qual as "شرط USING",
    with_check as "شرط WITH CHECK"
FROM pg_policies
WHERE schemaname = 'public' 
  AND tablename = 'hospitals'
ORDER BY cmd;

-- ============================================
-- فحص الدوال
-- ============================================

SELECT 
    proname as "اسم الدالة",
    prosecdef as "SECURITY DEFINER؟"
FROM pg_proc
WHERE proname IN ('is_admin', 'is_hospital')
  AND pronamespace = 'public'::regnamespace;

