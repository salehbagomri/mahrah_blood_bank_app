-- ============================================
-- الحل القوي - إصلاح إجباري لسياسات hospitals
-- ============================================

-- ⚠️ هذا السكريبت يحذف ويعيد إنشاء جميع السياسات بطريقة صحيحة

-- ============================================
-- الخطوة 1: التأكد من وجود الدوال
-- ============================================

-- دالة is_admin مع SECURITY DEFINER
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 
    FROM public.admins 
    WHERE id = auth.uid() 
      AND is_active = true
  );
END;
$$;

-- دالة is_hospital مع SECURITY DEFINER
CREATE OR REPLACE FUNCTION public.is_hospital()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 
    FROM public.hospitals 
    WHERE id = auth.uid() 
      AND is_active = true
  );
END;
$$;

-- ============================================
-- الخطوة 2: تعطيل RLS مؤقتاً (للحذف الآمن)
-- ============================================

ALTER TABLE public.hospitals DISABLE ROW LEVEL SECURITY;

-- ============================================
-- الخطوة 3: حذف جميع السياسات القديمة
-- ============================================

DROP POLICY IF EXISTS "Enable read access for all users" ON public.hospitals;
DROP POLICY IF EXISTS "Enable insert for admins only" ON public.hospitals;
DROP POLICY IF EXISTS "Enable update for admins and own hospital" ON public.hospitals;
DROP POLICY IF EXISTS "Enable delete for admins only" ON public.hospitals;
DROP POLICY IF EXISTS "Hospitals select policy" ON public.hospitals;
DROP POLICY IF EXISTS "Hospitals insert policy" ON public.hospitals;
DROP POLICY IF EXISTS "Hospitals update policy" ON public.hospitals;
DROP POLICY IF EXISTS "Hospitals delete policy" ON public.hospitals;

-- ============================================
-- الخطوة 4: إعادة تفعيل RLS
-- ============================================

ALTER TABLE public.hospitals ENABLE ROW LEVEL SECURITY;

-- ============================================
-- الخطوة 5: إنشاء سياسات جديدة بطريقة صحيحة
-- ============================================

-- سياسة القراءة: الجميع (authenticated)
CREATE POLICY "hospitals_select_policy"
ON public.hospitals
FOR SELECT
TO authenticated
USING (true);

-- سياسة الإضافة: الأدمن فقط
CREATE POLICY "hospitals_insert_policy"
ON public.hospitals
FOR INSERT
TO authenticated
WITH CHECK (
  public.is_admin() = true
);

-- سياسة التحديث: الأدمن أو المستشفى نفسه
CREATE POLICY "hospitals_update_policy"
ON public.hospitals
FOR UPDATE
TO authenticated
USING (
  public.is_admin() = true 
  OR 
  auth.uid() = id
)
WITH CHECK (
  public.is_admin() = true 
  OR 
  auth.uid() = id
);

-- سياسة الحذف: الأدمن فقط
CREATE POLICY "hospitals_delete_policy"
ON public.hospitals
FOR DELETE
TO authenticated
USING (
  public.is_admin() = true
);

-- ============================================
-- الخطوة 6: التحقق من النتيجة
-- ============================================

-- عرض السياسات الجديدة
SELECT 
    '✅ السياسات الجديدة' as "الحالة",
    policyname as "اسم السياسة",
    cmd as "العملية",
    roles as "الأدوار"
FROM pg_policies
WHERE schemaname = 'public' 
  AND tablename = 'hospitals'
ORDER BY cmd;

-- اختبار الدوال
SELECT 
    '🧪 اختبار الدوال' as "الاختبار",
    public.is_admin() as "is_admin",
    public.is_hospital() as "is_hospital",
    auth.uid() as "user_id";

-- ============================================
-- ملاحظات
-- ============================================

-- ✅ بعد تنفيذ هذا السكريبت:
--    1. جميع السياسات القديمة تم حذفها
--    2. سياسات جديدة تم إنشاؤها بأسماء مختلفة
--    3. الدوال تتحقق أيضاً من is_active
--    4. يجب أن يعمل الأدمن الآن بنجاح!

-- ⚠️ إذا استمرت المشكلة:
--    نفّذ DIAGNOSE_ADMIN.sql لمعرفة السبب الدقيق

-- ============================================

