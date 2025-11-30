-- ============================================
-- تأمين سياسات جدول reports
-- بعد التأكد من عمل الإضافة
-- ============================================

-- حذف السياسات المفتوحة
DROP POLICY IF EXISTS "reports_allow_insert" ON public.reports;
DROP POLICY IF EXISTS "reports_allow_select" ON public.reports;

-- ============================================
-- السياسات الآمنة
-- ============================================

-- 1. سياسة الإضافة: الجميع (anon و authenticated)
--    لأن المستخدمين العاديين يبلغون بدون تسجيل دخول
CREATE POLICY "reports_public_insert"
ON public.reports
FOR INSERT
WITH CHECK (true);

-- 2. سياسة القراءة: الأدمن فقط
CREATE POLICY "reports_admin_select"
ON public.reports
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.admins 
    WHERE id = auth.uid() 
      AND is_active = true
  )
);

-- 3. سياسة التحديث: الأدمن فقط
CREATE POLICY "reports_admin_update"
ON public.reports
FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.admins 
    WHERE id = auth.uid() 
      AND is_active = true
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.admins 
    WHERE id = auth.uid() 
      AND is_active = true
  )
);

-- 4. سياسة الحذف: الأدمن فقط
CREATE POLICY "reports_admin_delete"
ON public.reports
FOR DELETE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.admins 
    WHERE id = auth.uid() 
      AND is_active = true
  )
);

-- ============================================
-- عرض السياسات النهائية
-- ============================================

SELECT 
    '✅ السياسات الآمنة تم تطبيقها' as status;

SELECT 
    policyname as "اسم السياسة",
    cmd as "العملية",
    roles as "الأدوار"
FROM pg_policies
WHERE tablename = 'reports'
ORDER BY cmd;

-- ============================================
-- ملاحظات
-- ============================================

/*
✅ الآن:
- الجميع يمكنهم الإبلاغ (INSERT) ✅
- الأدمن فقط يمكنه قراءة البلاغات ✅
- الأدمن فقط يمكنه تحديث البلاغات ✅
- الأدمن فقط يمكنه حذف البلاغات ✅

🔒 آمن ومحمي!
*/

