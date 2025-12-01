-- إصلاح سياسة تحديث المتبرعين
-- السماح للمستشفيات بتحديث بيانات المتبرعين

-- 1. حذف السياسة القديمة إن وجدت
DROP POLICY IF EXISTS "hospitals_can_update_donors" ON donors;

-- 2. إنشاء سياسة جديدة تسمح للمستشفيات بتحديث المتبرعين
CREATE POLICY "hospitals_can_update_donors"
ON donors
FOR UPDATE
TO authenticated
USING (
  -- يمكن للمستشفيات تحديث أي متبرع
  EXISTS (
    SELECT 1 FROM users
    WHERE users.id = auth.uid()
    AND users.role = 'hospital'
    AND users.is_active = true
  )
)
WITH CHECK (
  -- التأكد من أن المستشفى نشط
  EXISTS (
    SELECT 1 FROM users
    WHERE users.id = auth.uid()
    AND users.role = 'hospital'
    AND users.is_active = true
  )
);

-- 3. التأكد من أن المتبرعين يمكن تحديثهم
GRANT UPDATE ON donors TO authenticated;

-- 4. عرض السياسات الحالية للتأكد
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies 
WHERE tablename = 'donors'
ORDER BY policyname;

