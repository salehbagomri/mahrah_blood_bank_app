-- ============================================
-- فحص واصلاح سياسات جدول reports
-- ============================================

-- 1. عرض جميع السياسات الحالية
SELECT 
    '=== السياسات الحالية ===' as info;

SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual as using_expression,
    with_check as with_check_expression
FROM pg_policies
WHERE tablename = 'reports';

-- ============================================

-- 2. التحقق من RLS
SELECT 
    '=== حالة RLS ===' as info;

SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables
WHERE tablename = 'reports';

-- ============================================

-- 3. حذف جميع السياسات (بالقوة)
SELECT '=== حذف جميع السياسات ===' as info;

DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN (
        SELECT policyname 
        FROM pg_policies 
        WHERE schemaname = 'public' 
          AND tablename = 'reports'
    ) LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.reports', r.policyname);
        RAISE NOTICE 'Dropped policy: %', r.policyname;
    END LOOP;
END $$;

-- ============================================

-- 4. تعطيل RLS مؤقتاً
ALTER TABLE public.reports DISABLE ROW LEVEL SECURITY;

-- ============================================

-- 5. إعادة تفعيل RLS
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;

-- ============================================

-- 6. إنشاء سياسة بسيطة جداً للإدخال
CREATE POLICY "allow_all_insert"
ON public.reports
FOR INSERT
TO authenticated, anon
WITH CHECK (true);

-- ============================================

-- 7. إنشاء سياسة للقراءة (الأدمن فقط)
CREATE POLICY "admin_select"
ON public.reports
FOR SELECT
TO authenticated
USING (
  EXISTS (SELECT 1 FROM public.admins WHERE id = auth.uid())
);

-- ============================================

-- 8. إنشاء سياسة للتحديث (الأدمن فقط)
CREATE POLICY "admin_update"
ON public.reports
FOR UPDATE
TO authenticated
USING (
  EXISTS (SELECT 1 FROM public.admins WHERE id = auth.uid())
)
WITH CHECK (
  EXISTS (SELECT 1 FROM public.admins WHERE id = auth.uid())
);

-- ============================================

-- 9. إنشاء سياسة للحذف (الأدمن فقط)
CREATE POLICY "admin_delete"
ON public.reports
FOR DELETE
TO authenticated
USING (
  EXISTS (SELECT 1 FROM public.admins WHERE id = auth.uid())
);

-- ============================================

-- 10. عرض السياسات الجديدة
SELECT 
    '=== السياسات الجديدة ===' as info;

SELECT 
    policyname,
    cmd,
    roles
FROM pg_policies
WHERE tablename = 'reports'
ORDER BY cmd;

-- ============================================

SELECT '=== تم الاصلاح بنجاح! ===' as result;

