-- ============================================
-- إصلاح شامل: سياسات RLS لجميع المستخدمين
-- (المستخدمين العاديين + المستشفيات + الأدمن)
-- ============================================

-- ============================================
-- 1. حذف جميع السياسات القديمة
-- ============================================

DROP POLICY IF EXISTS "public_select_available_donors" ON donors;
DROP POLICY IF EXISTS "public_insert_donors" ON donors;
DROP POLICY IF EXISTS "hospitals_select_donors" ON donors;
DROP POLICY IF EXISTS "hospitals_insert_donors" ON donors;
DROP POLICY IF EXISTS "hospitals_update_donors" ON donors;
DROP POLICY IF EXISTS "hospitals_delete_donors" ON donors;
DROP POLICY IF EXISTS "admins_select_all_donors" ON donors;
DROP POLICY IF EXISTS "admins_insert_donors" ON donors;
DROP POLICY IF EXISTS "admins_update_donors" ON donors;
DROP POLICY IF EXISTS "admins_delete_donors" ON donors;
DROP POLICY IF EXISTS "hospitals_full_access_donors" ON donors;
DROP POLICY IF EXISTS "admins_full_access_donors" ON donors;
DROP POLICY IF EXISTS "donors_can_read_themselves" ON donors;
DROP POLICY IF EXISTS "donors_can_update_themselves" ON donors;
DROP POLICY IF EXISTS "hospitals_can_update_donors" ON donors;
DROP POLICY IF EXISTS "hospitals_can_read_donors" ON donors;
DROP POLICY IF EXISTS "hospitals_can_insert_donors" ON donors;
DROP POLICY IF EXISTS "hospitals_can_delete_donors" ON donors;

-- تفعيل RLS
ALTER TABLE donors ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 2. سياسات للمستخدمين العاديين (Public)
-- ============================================

-- القراءة للمتبرعين المتاحين فقط
CREATE POLICY "public_select_available_donors"
ON donors
FOR SELECT
TO anon, authenticated
USING (
    is_available = true 
    AND is_active = true
);

-- الإضافة (أي شخص يمكنه إضافة نفسه كمتبرع)
CREATE POLICY "public_insert_donors"
ON donors
FOR INSERT
TO anon, authenticated
WITH CHECK (true);

-- ============================================
-- 3. سياسات للمستشفيات (جميع الصلاحيات)
-- ============================================

-- القراءة
CREATE POLICY "hospitals_select_donors"
ON donors
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM hospitals
        WHERE hospitals.id = auth.uid()
        AND hospitals.is_active = true
    )
);

-- الإضافة
CREATE POLICY "hospitals_insert_donors"
ON donors
FOR INSERT
TO authenticated
WITH CHECK (
    EXISTS (
        SELECT 1 FROM hospitals
        WHERE hospitals.id = auth.uid()
        AND hospitals.is_active = true
    )
);

-- التحديث
CREATE POLICY "hospitals_update_donors"
ON donors
FOR UPDATE
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM hospitals
        WHERE hospitals.id = auth.uid()
        AND hospitals.is_active = true
    )
)
WITH CHECK (true);

-- الحذف
CREATE POLICY "hospitals_delete_donors"
ON donors
FOR DELETE
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM hospitals
        WHERE hospitals.id = auth.uid()
        AND hospitals.is_active = true
    )
);

-- ============================================
-- 4. سياسات للأدمن (جميع الصلاحيات)
-- ============================================

-- القراءة
CREATE POLICY "admins_select_all_donors"
ON donors
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM admins
        WHERE admins.id = auth.uid()
        AND admins.is_active = true
    )
);

-- الإضافة
CREATE POLICY "admins_insert_donors"
ON donors
FOR INSERT
TO authenticated
WITH CHECK (
    EXISTS (
        SELECT 1 FROM admins
        WHERE admins.id = auth.uid()
        AND admins.is_active = true
    )
);

-- التحديث
CREATE POLICY "admins_update_donors"
ON donors
FOR UPDATE
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM admins
        WHERE admins.id = auth.uid()
        AND admins.is_active = true
    )
)
WITH CHECK (true);

-- الحذف
CREATE POLICY "admins_delete_donors"
ON donors
FOR DELETE
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM admins
        WHERE admins.id = auth.uid()
        AND admins.is_active = true
    )
);

-- ============================================
-- 5. منح الصلاحيات
-- ============================================

GRANT SELECT, INSERT, UPDATE, DELETE ON donors TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON donors TO anon;
GRANT SELECT ON hospitals TO authenticated;
GRANT SELECT ON admins TO authenticated;

-- ============================================
-- 6. عرض النتائج
-- ============================================

SELECT 
    schemaname,
    tablename,
    policyname,
    cmd as operation,
    roles
FROM pg_policies 
WHERE tablename = 'donors'
ORDER BY policyname;

-- ============================================
-- ملاحظات
-- ============================================

/*
✅ السياسات الجديدة:

1. المستخدمين العاديين (Public):
   - القراءة: المتبرعين المتاحين فقط
   - الإضافة: يمكن لأي شخص إضافة نفسه كمتبرع

2. المستشفيات:
   - جميع الصلاحيات (قراءة، إضافة، تحديث، حذف)

3. الأدمن:
   - جميع الصلاحيات (قراءة، إضافة، تحديث، حذف)

✅ بعد التنفيذ:
- يمكن للجميع رؤية وإضافة المتبرعين
- المستشفيات والأدمن لديهم تحكم كامل
*/
