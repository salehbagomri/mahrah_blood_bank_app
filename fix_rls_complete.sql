-- ============================================
-- حل شامل ونهائي لمشكلة RLS
-- ============================================

-- الخطوة 1: تعطيل RLS مؤقتاً للتأكد من عدم وجود مشاكل أخرى
-- (فقط للاختبار - سنعيد تفعيله بعد ثوان)
ALTER TABLE donors DISABLE ROW LEVEL SECURITY;

-- الخطوة 2: حذف جميع السياسات القديمة
DO $$ 
DECLARE 
    r RECORD;
BEGIN
    FOR r IN (SELECT policyname FROM pg_policies WHERE tablename = 'donors') 
    LOOP
        EXECUTE 'DROP POLICY IF EXISTS "' || r.policyname || '" ON donors';
    END LOOP;
END $$;

-- الخطوة 3: إعادة تفعيل RLS
ALTER TABLE donors ENABLE ROW LEVEL SECURITY;

-- الخطوة 4: إنشاء سياسات بسيطة وواضحة للمستشفيات

-- سياسة SELECT (القراءة)
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

-- سياسة INSERT (الإضافة)
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

-- سياسة UPDATE (التحديث) - الأهم
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
WITH CHECK (
    -- السماح بتحديث أي بيانات بدون قيود
    true
);

-- سياسة DELETE (الحذف)
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

-- الخطوة 5: منح الصلاحيات اللازمة
GRANT ALL ON donors TO authenticated;
GRANT SELECT ON hospitals TO authenticated;

-- ============================================
-- التحقق من النتائج
-- ============================================

-- 1. عرض جميع السياسات
SELECT 
    schemaname,
    tablename,
    policyname,
    cmd as operation,
    CASE 
        WHEN permissive = 'PERMISSIVE' THEN '✓ مسموح'
        ELSE '✗ محظور'
    END as type
FROM pg_policies 
WHERE tablename = 'donors'
ORDER BY policyname;

-- 2. التحقق من المستخدم الحالي
SELECT 
    id,
    name,
    email,
    district,
    is_active,
    CASE 
        WHEN is_active THEN '✓ نشط'
        ELSE '✗ غير نشط'
    END as status
FROM hospitals 
WHERE id = auth.uid();

-- 3. اختبار التحديث (اختياري)
-- SELECT 'إذا ظهرت هذه الرسالة، معناها أنك مسجل دخول بنجاح' as message;

-- ============================================
-- ملاحظات مهمة
-- ============================================

/*
✅ ما تم عمله:
1. حذف جميع السياسات القديمة
2. إنشاء سياسات جديدة بسيطة وواضحة
3. WITH CHECK = true للسماح بأي تحديث
4. منح جميع الصلاحيات

✅ بعد التنفيذ:
1. سجّل خروج من التطبيق
2. سجّل دخول مرة أخرى
3. جرّب تحديث آخر تبرع
4. يجب أن يعمل!

❌ إذا استمر الخطأ:
- شارك معي نتائج الـ SELECT أعلاه
- تحقق من أن is_active = true
*/

