-- ============================================
-- إصلاح سياسة تحديث المتبرعين
-- السماح للمستشفيات بتحديث بيانات المتبرعين
-- ============================================

-- 1. حذف جميع السياسات القديمة المتعلقة بالتحديث
DROP POLICY IF EXISTS "hospitals_can_update_donors" ON donors;
DROP POLICY IF EXISTS "Enable update for hospitals" ON donors;
DROP POLICY IF EXISTS "Allow update for hospitals" ON donors;

-- 2. إنشاء سياسة جديدة بسيطة وواضحة
CREATE POLICY "hospitals_can_update_donors"
ON donors
FOR UPDATE
TO authenticated
USING (
  -- يمكن للمستشفيات النشطة تحديث أي متبرع
  EXISTS (
    SELECT 1 FROM hospitals
    WHERE hospitals.id = auth.uid()
    AND hospitals.is_active = true
  )
)
WITH CHECK (
  -- السماح بتحديث أي بيانات
  EXISTS (
    SELECT 1 FROM hospitals
    WHERE hospitals.id = auth.uid()
    AND hospitals.is_active = true
  )
);

-- 3. التأكد من منح الصلاحيات
GRANT UPDATE ON donors TO authenticated;
GRANT SELECT ON hospitals TO authenticated;

-- 4. عرض السياسات الحالية للتأكد
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd
FROM pg_policies 
WHERE tablename = 'donors'
ORDER BY policyname;

-- ============================================
-- التحقق من المستخدم الحالي
-- ============================================

-- تشغيل هذا للتأكد من أنك مسجل دخول كمستشفى
SELECT 
  id,
  name,
  email,
  is_active,
  'أنت مسجل دخول كمستشفى ✓' as status
FROM hospitals 
WHERE id = auth.uid();

-- إذا لم تظهر نتائج، معناها أنت لست مسجل دخول كمستشفى
-- تأكد من تسجيل الدخول بحساب مستشفى في التطبيق

-- ============================================
-- ملاحظات مهمة
-- ============================================

/*
✅ بعد تشغيل هذا السكريبت:
1. تأكد من أن السياسة ظهرت في pg_policies
2. تأكد من أنك مسجل دخول كمستشفى
3. جرّب تحديث متبرع في التطبيق

❌ إذا استمر الخطأ:
1. تحقق من أن is_active = true للمستشفى
2. جرّب تسجيل خروج ودخول مرة أخرى
3. تحقق من auth.uid() في Supabase
*/

