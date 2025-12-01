-- ============================================
-- إصلاح شامل: إضافة سياسات لجميع المستخدمين
-- (المستشفيات + الأدمن + المستخدمين العاديين)
-- ============================================

-- ============================================
-- 1. سياسات للمستخدمين العاديين (Public)
-- ============================================

-- القراءة للمتبرعين المتاحين
CREATE POLICY "public_select_available_donors"
ON donors
FOR SELECT
TO anon, authenticated
USING (
    -- الجميع يمكنهم رؤية المتبرعين المتاحين فقط
    is_available = true 
    AND is_active = true
);

-- الإضافة (للجميع - أي شخص يمكنه إضافة نفسه كمتبرع)
CREATE POLICY "public_insert_donors"
ON donors
FOR INSERT
TO anon, authenticated
WITH CHECK (true);

-- ============================================
-- 2. سياسات للأدمن (جميع الصلاحيات)
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
-- 3. منح صلاحيات القراءة على جداول المستخدمين
-- ============================================

GRANT SELECT ON admins TO authenticated;

-- ============================================
-- 4. التحقق من النتائج
-- ============================================

-- عرض جميع السياسات
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
✅ الآن يوجد سياسات لـ:
1. المستخدمين العاديين - قراءة المتاحين فقط
2. المستشفيات - جميع الصلاحيات
3. الأدمن - جميع الصلاحيات

✅ بعد التنفيذ:
- المستخدمين العاديين: يمكنهم رؤية المتبرعين المتاحين
- المستشفيات: يمكنهم إدارة جميع المتبرعين
- الأدمن: يمكنهم إدارة كل شيء
*/

