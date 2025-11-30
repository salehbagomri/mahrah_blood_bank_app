-- ============================================
-- الحل الكامل لمشكلة إضافة المستشفيات
-- نفّذ هذا السكريبت مرة واحدة في Supabase SQL Editor
-- ============================================

-- ============================================
-- الجزء 1: التأكد من وجود دوال المساعدة
-- ============================================

-- دالة التحقق من الأدمن (مع SECURITY DEFINER لتجاوز RLS)
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.admins 
    WHERE id = auth.uid()
  );
END;
$$;

-- دالة التحقق من المستشفى (مع SECURITY DEFINER لتجاوز RLS)
CREATE OR REPLACE FUNCTION public.is_hospital()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.hospitals 
    WHERE id = auth.uid()
  );
END;
$$;

-- ============================================
-- الجزء 2: إصلاح سياسات RLS لجدول hospitals
-- ============================================

-- حذف جميع السياسات القديمة
DROP POLICY IF EXISTS "Enable read access for all users" ON public.hospitals;
DROP POLICY IF EXISTS "Enable insert for admins only" ON public.hospitals;
DROP POLICY IF EXISTS "Enable update for admins and own hospital" ON public.hospitals;
DROP POLICY IF EXISTS "Enable delete for admins only" ON public.hospitals;

-- سياسة القراءة: الجميع يمكنهم القراءة
CREATE POLICY "Enable read access for all users"
ON public.hospitals
FOR SELECT
TO authenticated
USING (true);

-- سياسة الإضافة: الأدمن فقط
CREATE POLICY "Enable insert for admins only"
ON public.hospitals
FOR INSERT
TO authenticated
WITH CHECK (
  public.is_admin()
);

-- سياسة التحديث: الأدمن أو المستشفى نفسه
CREATE POLICY "Enable update for admins and own hospital"
ON public.hospitals
FOR UPDATE
TO authenticated
USING (
  public.is_admin() OR auth.uid() = id
)
WITH CHECK (
  public.is_admin() OR auth.uid() = id
);

-- سياسة الحذف: الأدمن فقط
CREATE POLICY "Enable delete for admins only"
ON public.hospitals
FOR DELETE
TO authenticated
USING (
  public.is_admin()
);

-- ============================================
-- الجزء 3: التحقق من صحة الإعدادات
-- ============================================

-- عرض السياسات المطبقة
SELECT 
    '✅ السياسات المطبقة على جدول hospitals:' as message,
    policyname as "اسم السياسة",
    cmd as "نوع العملية",
    roles as "الأدوار"
FROM pg_policies
WHERE schemaname = 'public' 
  AND tablename = 'hospitals'
ORDER BY cmd;

-- ============================================
-- الجزء 4: اختبار الإعدادات
-- ============================================

-- تحقق من أنك أدمن (يجب أن يعيد true)
SELECT 
    public.is_admin() as "هل أنت أدمن؟",
    auth.uid() as "معرف المستخدم الحالي";

-- ============================================
-- ملاحظات مهمة:
-- ============================================

-- ✅ بعد تنفيذ هذا السكريبت:
--    1. السياسات ستسمح للأدمن بإضافة/تعديل/حذف المستشفيات
--    2. المستشفى يمكنه تعديل بياناته الخاصة فقط
--    3. الجميع يمكنهم قراءة معلومات المستشفيات

-- ⚠️ إذا استمرت المشكلة:
--    تأكد من أنك مسجل دخول كأدمن في التطبيق
--    تحقق من جدول admins أن معرفك موجود:
--    SELECT * FROM public.admins WHERE id = auth.uid();

-- ============================================

