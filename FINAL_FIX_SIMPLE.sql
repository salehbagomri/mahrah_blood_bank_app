-- ============================================
-- الحل النهائي البسيط - نفّذه الآن!
-- ============================================

-- حذف جميع سياسات INSERT القديمة
DROP POLICY IF EXISTS "Enable insert for admins only" ON public.hospitals;
DROP POLICY IF EXISTS "hospitals_insert_policy" ON public.hospitals;
DROP POLICY IF EXISTS "hospitals_insert_admin" ON public.hospitals;
DROP POLICY IF EXISTS "hospitals_insert_policy_temp" ON public.hospitals;

-- إنشاء سياسة جديدة بسيطة وصحيحة
CREATE POLICY "admin_can_insert_hospitals"
ON public.hospitals
FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 
    FROM public.admins 
    WHERE id = auth.uid() 
      AND is_active = true
  )
);

-- التحقق
SELECT 
    '✅ السياسة الجديدة' as "الحالة",
    policyname,
    cmd
FROM pg_policies
WHERE tablename = 'hospitals' AND cmd = 'INSERT';

-- ============================================
-- ملاحظة مهمة جداً:
-- ============================================
-- بعد تنفيذ هذا السكريبت:
-- 1. أغلق التطبيق تماماً
-- 2. افتحه من جديد
-- 3. سجل دخول بـ s.bagomri@gmail.com.com
-- 4. جرب إضافة مستشفى
-- ============================================

