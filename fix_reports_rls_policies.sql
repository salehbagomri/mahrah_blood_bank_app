-- ============================================
-- إصلاح سياسات RLS لجدول البلاغات (reports)
-- ============================================

-- 1. حذف جميع السياسات القديمة
DROP POLICY IF EXISTS "reports_insert_policy" ON reports;
DROP POLICY IF EXISTS "reports_select_policy" ON reports;
DROP POLICY IF EXISTS "reports_update_policy" ON reports;
DROP POLICY IF EXISTS "reports_delete_policy" ON reports;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON reports;
DROP POLICY IF EXISTS "Enable read for admins" ON reports;

-- 2. تفعيل RLS
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;

-- 3. سياسة الإضافة: الجميع (anon + authenticated)
-- أي شخص يمكنه الإبلاغ عن رقم
CREATE POLICY "public_insert_reports"
ON reports
FOR INSERT
TO anon, authenticated
WITH CHECK (true);

-- 4. سياسة القراءة: الأدمن والمستشفيات فقط
CREATE POLICY "admins_hospitals_select_reports"
ON reports
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM admins WHERE admins.id = auth.uid()
    )
    OR
    EXISTS (
        SELECT 1 FROM hospitals WHERE hospitals.id = auth.uid()
    )
);

-- 5. سياسة التحديث: الأدمن والمستشفيات فقط
CREATE POLICY "admins_hospitals_update_reports"
ON reports
FOR UPDATE
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM admins WHERE admins.id = auth.uid()
    )
    OR
    EXISTS (
        SELECT 1 FROM hospitals WHERE hospitals.id = auth.uid()
    )
)
WITH CHECK (true);

-- 6. سياسة الحذف: الأدمن فقط
CREATE POLICY "admins_delete_reports"
ON reports
FOR DELETE
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM admins WHERE admins.id = auth.uid()
    )
);

-- 7. منح الصلاحيات
GRANT SELECT, INSERT ON reports TO authenticated;
GRANT INSERT ON reports TO anon;

-- 8. عرض النتائج
SELECT 
    policyname,
    cmd as operation,
    roles
FROM pg_policies 
WHERE tablename = 'reports'
ORDER BY cmd;

-- ============================================
-- ملاحظات
-- ============================================

/*
✅ السياسات الجديدة:

1. المستخدمون العاديون (anon + authenticated):
   - يمكنهم إضافة بلاغات فقط

2. المستشفيات والأدمن:
   - يمكنهم قراءة وتحديث البلاغات

3. الأدمن فقط:
   - يمكنهم حذف البلاغات

✅ بعد التنفيذ:
- أي شخص يمكنه الإبلاغ عن رقم
- المستشفيات والأدمن يديرون البلاغات
*/

