-- ============================================
-- إصلاح كامل لجميع سياسات hospitals
-- نفّذ هذا السكريبت كاملاً مرة واحدة
-- ============================================

-- ============================================
-- 1. حذف جميع السياسات القديمة
-- ============================================

DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN (
        SELECT policyname 
        FROM pg_policies 
        WHERE schemaname = 'public' 
          AND tablename = 'hospitals'
    ) LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.hospitals', r.policyname);
    END LOOP;
END $$;

-- ============================================
-- 2. إنشاء سياسات جديدة صحيحة 100%
-- ============================================

-- سياسة القراءة (SELECT) - الجميع
CREATE POLICY "hospitals_select"
ON public.hospitals
FOR SELECT
TO authenticated
USING (true);

-- سياسة الإضافة (INSERT) - الأدمن فقط
CREATE POLICY "hospitals_insert"
ON public.hospitals
FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 
    FROM public.admins 
    WHERE admins.id = auth.uid() 
      AND admins.is_active = true
  )
);

-- سياسة التحديث (UPDATE) - الأدمن أو المستشفى نفسه
CREATE POLICY "hospitals_update"
ON public.hospitals
FOR UPDATE
TO authenticated
USING (
  EXISTS (SELECT 1 FROM public.admins WHERE admins.id = auth.uid())
  OR 
  hospitals.id = auth.uid()
)
WITH CHECK (
  EXISTS (SELECT 1 FROM public.admins WHERE admins.id = auth.uid())
  OR 
  hospitals.id = auth.uid()
);

-- سياسة الحذف (DELETE) - الأدمن فقط
CREATE POLICY "hospitals_delete"
ON public.hospitals
FOR DELETE
TO authenticated
USING (
  EXISTS (
    SELECT 1 
    FROM public.admins 
    WHERE admins.id = auth.uid()
  )
);

-- ============================================
-- 3. التحقق من النتيجة
-- ============================================

SELECT 
    '✅ تم إنشاء السياسات التالية:' as "النتيجة";

SELECT 
    policyname as "اسم السياسة",
    cmd as "العملية"
FROM pg_policies
WHERE schemaname = 'public' 
  AND tablename = 'hospitals'
ORDER BY 
    CASE cmd
        WHEN 'SELECT' THEN 1
        WHEN 'INSERT' THEN 2
        WHEN 'UPDATE' THEN 3
        WHEN 'DELETE' THEN 4
    END;

-- ============================================
-- 4. اختبار بسيط
-- ============================================

SELECT 
    '🧪 معلومات الاختبار:' as "المعلومة";

SELECT 
    'معرف الأدمن' as "البيان",
    id as "القيمة"
FROM public.admins
WHERE email = 's.bagomri@gmail.com.com';

-- ============================================
-- تعليمات مهمة
-- ============================================

SELECT 
    '⚠️ خطوات بعد تنفيذ هذا السكريبت:' as "مهم",
    '1. أغلق التطبيق تماماً (Kill App)' as "الخطوة 1",
    '2. شغّل التطبيق من جديد' as "الخطوة 2",
    '3. سجل دخول بـ s.bagomri@gmail.com.com' as "الخطوة 3",
    '4. جرب إضافة مستشفى' as "الخطوة 4",
    '5. يجب أن يعمل! ✅' as "النتيجة";

