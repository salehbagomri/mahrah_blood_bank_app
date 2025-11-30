-- ============================================
-- اصلاح سياسات RLS لجدول reports
-- ============================================

-- حذف السياسات القديمة
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON public.reports;
DROP POLICY IF EXISTS "Enable read for admins" ON public.reports;
DROP POLICY IF EXISTS "reports_insert_policy" ON public.reports;
DROP POLICY IF EXISTS "reports_select_policy" ON public.reports;

-- سياسة القراءة: الادمن فقط
CREATE POLICY "reports_select_policy"
ON public.reports
FOR SELECT
TO authenticated
USING (
  EXISTS (SELECT 1 FROM public.admins WHERE id = auth.uid())
);

-- سياسة الاضافة: الجميع (المستخدمون العاديون يمكنهم الابلاغ)
CREATE POLICY "reports_insert_policy"
ON public.reports
FOR INSERT
TO authenticated
WITH CHECK (true);  -- السماح للجميع بالابلاغ

-- سياسة التحديث: الادمن فقط
CREATE POLICY "reports_update_policy"
ON public.reports
FOR UPDATE
TO authenticated
USING (
  EXISTS (SELECT 1 FROM public.admins WHERE id = auth.uid())
)
WITH CHECK (
  EXISTS (SELECT 1 FROM public.admins WHERE id = auth.uid())
);

-- سياسة الحذف: الادمن فقط
CREATE POLICY "reports_delete_policy"
ON public.reports
FOR DELETE
TO authenticated
USING (
  EXISTS (SELECT 1 FROM public.admins WHERE id = auth.uid())
);

-- عرض السياسات
SELECT 
    policyname,
    cmd
FROM pg_policies
WHERE tablename = 'reports'
ORDER BY cmd;

