-- ============================================
-- إصلاح صلاحيات إضافة المستشفيات
-- ============================================

-- المشكلة: خطأ 42501 عند محاولة الأدمن إضافة مستشفى
-- السبب: سياسة RLS لا تسمح للأدمن بإضافة سجلات في جدول hospitals

-- ============================================
-- الحل 1: تحديث سياسة INSERT للأدمن
-- ============================================

-- حذف السياسة القديمة إن وجدت
DROP POLICY IF EXISTS "Enable insert for admins only" ON public.hospitals;

-- إنشاء سياسة جديدة تسمح للأدمن بالإضافة
CREATE POLICY "Enable insert for admins only"
ON public.hospitals
FOR INSERT
TO authenticated
WITH CHECK (
  -- السماح للأدمن بإضافة سجلات
  public.is_admin()
);

-- ============================================
-- الحل 2: تحديث سياسة UPDATE للأدمن
-- ============================================

-- حذف السياسة القديمة إن وجدت
DROP POLICY IF EXISTS "Enable update for admins and own hospital" ON public.hospitals;

-- إنشاء سياسة جديدة
CREATE POLICY "Enable update for admins and own hospital"
ON public.hospitals
FOR UPDATE
TO authenticated
USING (
  -- السماح للأدمن أو المستشفى نفسه
  public.is_admin() OR auth.uid() = id
)
WITH CHECK (
  -- نفس الشرط
  public.is_admin() OR auth.uid() = id
);

-- ============================================
-- الحل 3: تحديث سياسة DELETE للأدمن فقط
-- ============================================

-- حذف السياسة القديمة إن وجدت
DROP POLICY IF EXISTS "Enable delete for admins only" ON public.hospitals;

-- إنشاء سياسة جديدة
CREATE POLICY "Enable delete for admins only"
ON public.hospitals
FOR DELETE
TO authenticated
USING (
  -- السماح للأدمن فقط
  public.is_admin()
);

-- ============================================
-- التحقق من السياسات الجديدة
-- ============================================

SELECT 
    policyname,
    cmd as operation,
    roles,
    CASE 
        WHEN qual IS NOT NULL THEN 'Has USING clause'
        ELSE 'No USING clause'
    END as using_check,
    CASE 
        WHEN with_check IS NOT NULL THEN 'Has WITH CHECK clause'
        ELSE 'No WITH CHECK clause'
    END as with_check_status
FROM pg_policies
WHERE schemaname = 'public' 
  AND tablename = 'hospitals'
ORDER BY cmd;

-- ============================================
-- ملاحظات:
-- ============================================

-- 1. تأكد من وجود دالة is_admin() قبل تنفيذ هذا السكريبت
--    إذا لم تكن موجودة، شغّل fix_rls_policies.sql أولاً

-- 2. هذا السكريبت يصلح:
--    ✅ مشكلة عدم قدرة الأدمن على إضافة مستشفيات
--    ✅ مشكلة عدم قدرة الأدمن على تعديل المستشفيات
--    ✅ مشكلة عدم قدرة الأدمن على حذف المستشفيات

-- 3. بعد تنفيذ السكريبت:
--    - أعد تشغيل التطبيق
--    - جرب إضافة مستشفى مرة أخرى
--    - يجب أن يعمل بنجاح!

-- ============================================

