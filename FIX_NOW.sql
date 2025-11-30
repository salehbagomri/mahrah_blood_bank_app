-- ============================================
-- الحل المباشر - بدون الحاجة لـ auth.uid()
-- نفّذ هذا مباشرة في Supabase SQL Editor
-- ============================================

-- ============================================
-- الخطوة 1: إنشاء/تحديث الدوال المساعدة
-- ============================================

-- دالة التحقق من الأدمن
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
  );
END;
$$;

-- دالة التحقق من المستشفى
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
  );
END;
$$;

-- ============================================
-- الخطوة 2: حذف جميع السياسات القديمة
-- ============================================

DROP POLICY IF EXISTS "Enable read access for all users" ON public.hospitals;
DROP POLICY IF EXISTS "Enable insert for admins only" ON public.hospitals;
DROP POLICY IF EXISTS "Enable update for admins and own hospital" ON public.hospitals;
DROP POLICY IF EXISTS "Enable delete for admins only" ON public.hospitals;
DROP POLICY IF EXISTS "hospitals_select_policy" ON public.hospitals;
DROP POLICY IF EXISTS "hospitals_insert_policy" ON public.hospitals;
DROP POLICY IF EXISTS "hospitals_update_policy" ON public.hospitals;
DROP POLICY IF EXISTS "hospitals_delete_policy" ON public.hospitals;
DROP POLICY IF EXISTS "hospitals_insert_policy_temp" ON public.hospitals;

-- ============================================
-- الخطوة 3: إنشاء السياسات الصحيحة
-- ============================================

-- سياسة القراءة: الجميع
CREATE POLICY "hospitals_read_all"
ON public.hospitals
FOR SELECT
TO authenticated
USING (true);

-- سياسة الإضافة: الأدمن فقط (هذه المهمة!)
CREATE POLICY "hospitals_insert_admin"
ON public.hospitals
FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 
    FROM public.admins 
    WHERE id = auth.uid()
  )
);

-- سياسة التحديث: الأدمن أو المستشفى نفسه
CREATE POLICY "hospitals_update_allowed"
ON public.hospitals
FOR UPDATE
TO authenticated
USING (
  EXISTS (SELECT 1 FROM public.admins WHERE id = auth.uid())
  OR 
  id = auth.uid()
)
WITH CHECK (
  EXISTS (SELECT 1 FROM public.admins WHERE id = auth.uid())
  OR 
  id = auth.uid()
);

-- سياسة الحذف: الأدمن فقط
CREATE POLICY "hospitals_delete_admin"
ON public.hospitals
FOR DELETE
TO authenticated
USING (
  EXISTS (
    SELECT 1 
    FROM public.admins 
    WHERE id = auth.uid()
  )
);

-- ============================================
-- الخطوة 4: التحقق من السياسات
-- ============================================

SELECT 
    '✅ السياسات المُنشأة' as "الحالة",
    policyname as "اسم السياسة",
    cmd as "العملية"
FROM pg_policies
WHERE schemaname = 'public' 
  AND tablename = 'hospitals'
ORDER BY cmd;

-- ============================================
-- الخطوة 5: عرض الأدمن المسجلين
-- ============================================

SELECT 
    '👥 الأدمن المسجلين' as "المعلومة",
    id as "المعرف",
    name as "الاسم",
    email as "البريد",
    is_active as "نشط؟"
FROM public.admins
ORDER BY created_at DESC;

-- ============================================
-- ملاحظات مهمة
-- ============================================

-- ✅ تم:
--    1. إنشاء دوال is_admin() و is_hospital()
--    2. حذف جميع السياسات القديمة
--    3. إنشاء سياسات جديدة صحيحة
--    4. سياسة INSERT تستخدم EXISTS مباشرة (أكثر أماناً)

-- 🎯 الآن:
--    1. ارجع للتطبيق
--    2. سجل دخول كأدمن
--    3. جرب إضافة مستشفى
--    4. يجب أن يعمل! ✅

-- ⚠️ إذا ظهر خطأ "أنت غير موجود في جدول admins":
--    تأكد من أن بريدك الإلكتروني موجود في جدول admins
--    نفّذ: SELECT * FROM public.admins;

-- ============================================

