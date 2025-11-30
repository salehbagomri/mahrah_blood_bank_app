-- ============================================
-- الحل النهائي المضمون - نفّذه الآن!
-- ============================================

-- حذف جميع سياسات INSERT القديمة (كلها!)
DO $$ 
DECLARE
    pol RECORD;
BEGIN
    FOR pol IN (
        SELECT policyname 
        FROM pg_policies 
        WHERE schemaname = 'public' 
          AND tablename = 'hospitals'
          AND cmd = 'INSERT'
    ) LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.hospitals', pol.policyname);
        RAISE NOTICE 'Dropped policy: %', pol.policyname;
    END LOOP;
END $$;

-- إنشاء سياسة INSERT جديدة وصحيحة
CREATE POLICY "hospitals_insert_for_admins"
ON public.hospitals
FOR INSERT
TO authenticated
WITH CHECK (
  -- التحقق بطريقتين لضمان العمل:
  EXISTS (
    SELECT 1 
    FROM public.admins 
    WHERE admins.id = auth.uid() 
      AND admins.is_active = true
  )
  OR
  -- بديل: التحقق المباشر
  (SELECT is_active FROM public.admins WHERE id = auth.uid()) = true
);

-- ============================================
-- التحقق من النجاح
-- ============================================

SELECT 
    '✅ تم إنشاء السياسة الجديدة:' as status;

SELECT 
    policyname as "اسم السياسة",
    cmd as "العملية",
    CASE 
        WHEN with_check IS NOT NULL THEN '✅ لديها WITH CHECK'
        ELSE '❌ بدون WITH CHECK'
    END as "الحالة"
FROM pg_policies
WHERE schemaname = 'public' 
  AND tablename = 'hospitals'
  AND cmd = 'INSERT';

-- ============================================
-- اختبار السياسة (محاكاة)
-- ============================================

SELECT 
    '🧪 اختبار: هل الأدمن موجود؟' as test,
    EXISTS (
        SELECT 1 
        FROM public.admins 
        WHERE id = '0e47c51e-417f-43a7-b53f-24e6187a1864'
          AND is_active = true
    ) as result;

-- يجب أن يُرجع: true ✅

-- ============================================
-- ملاحظات مهمة
-- ============================================

/*
✅ بعد تنفيذ هذا السكريبت:

1. لا تحتاج لإعادة تشغيل Supabase
2. السياسة ستعمل فوراً
3. ارجع للتطبيق مباشرة
4. جرب إضافة مستشفى
5. يجب أن يعمل! ✅

⚠️ إذا لم يعمل:
- تأكد من إغلاق التطبيق تماماً (Stop)
- افتحه من جديد
- سجل خروج ودخول
- جرب مرة أخرى

🔍 إذا استمر الخطأ:
أرسل لي نتيجة هذا الاستعلام:

SELECT * FROM pg_policies 
WHERE tablename = 'hospitals' AND cmd = 'INSERT';
*/

