-- ============================================
-- التحقق وإصلاح RLS لجدول البلاغات
-- ============================================

-- 1. عرض السياسات الحالية
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
WHERE tablename = 'reports';

-- 2. تعطيل RLS مؤقتاً
ALTER TABLE reports DISABLE ROW LEVEL SECURITY;

-- 3. حذف جميع السياسات
DO $$ 
DECLARE 
    r RECORD;
BEGIN
    FOR r IN (SELECT policyname FROM pg_policies WHERE tablename = 'reports') 
    LOOP
        EXECUTE 'DROP POLICY IF EXISTS ' || quote_ident(r.policyname) || ' ON reports';
    END LOOP;
END $$;

-- 4. إعادة تفعيل RLS
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;

-- 5. إنشاء سياسة بسيطة جداً للإضافة (الجميع)
CREATE POLICY "allow_insert_reports"
ON reports
FOR INSERT
WITH CHECK (true);

-- 6. سياسة القراءة للأدمن فقط
CREATE POLICY "allow_select_reports"
ON reports
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM admins WHERE admins.id = auth.uid()
    )
);

-- 7. سياسة التحديث للأدمن فقط
CREATE POLICY "allow_update_reports"
ON reports
FOR UPDATE
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM admins WHERE admins.id = auth.uid()
    )
)
WITH CHECK (true);

-- 8. سياسة الحذف للأدمن فقط
CREATE POLICY "allow_delete_reports"
ON reports
FOR DELETE
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM admins WHERE admins.id = auth.uid()
    )
);

-- 9. منح الصلاحيات بشكل واضح
GRANT ALL ON reports TO anon;
GRANT ALL ON reports TO authenticated;
GRANT ALL ON reports TO service_role;

-- 10. عرض النتيجة النهائية
SELECT 
    policyname,
    cmd as operation,
    roles
FROM pg_policies 
WHERE tablename = 'reports'
ORDER BY cmd;

-- 11. عرض حالة RLS
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE tablename = 'reports';

