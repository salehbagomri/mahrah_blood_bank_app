-- إصلاح سياسات RLS لتجنب Infinite Recursion
-- قم بتنفيذ هذا في Supabase SQL Editor

-- ========================================
-- 1. حذف السياسات القديمة التي تسبب المشكلة
-- ========================================

-- حذف السياسات القديمة لجدول admins
DROP POLICY IF EXISTS "Only admins can view admins" ON admins;
DROP POLICY IF EXISTS "Only admins can insert admins" ON admins;
DROP POLICY IF EXISTS "Only admins can update admins" ON admins;

-- حذف السياسات القديمة لجدول hospitals
DROP POLICY IF EXISTS "Only admins can view hospitals" ON hospitals;
DROP POLICY IF EXISTS "Only admins can insert hospitals" ON hospitals;
DROP POLICY IF EXISTS "Only admins can update hospitals" ON hospitals;
DROP POLICY IF EXISTS "Only admins can delete hospitals" ON hospitals;

-- حذف السياسات القديمة لجدول donors
DROP POLICY IF EXISTS "Hospitals can update donors" ON donors;
DROP POLICY IF EXISTS "Only admins can delete donors" ON donors;

-- حذف السياسات القديمة لجدول reports
DROP POLICY IF EXISTS "Only admins can view reports" ON reports;
DROP POLICY IF EXISTS "Only admins can update reports" ON reports;

-- حذف السياسات القديمة لجدول logs
DROP POLICY IF EXISTS "Only admins can view logs" ON logs;

-- ========================================
-- 2. إنشاء سياسات جديدة بدون Recursion
-- ========================================

-- سياسات جدول admins - بدون recursion
CREATE POLICY "Admins can view all admins"
    ON admins FOR SELECT
    USING (auth.uid() = id OR EXISTS (
        SELECT 1 FROM admins WHERE id = auth.uid() AND is_active = TRUE
    ));

CREATE POLICY "Admins can insert new admins"
    ON admins FOR INSERT
    WITH CHECK (EXISTS (
        SELECT 1 FROM admins WHERE id = auth.uid() AND is_active = TRUE
    ));

CREATE POLICY "Admins can update admins"
    ON admins FOR UPDATE
    USING (EXISTS (
        SELECT 1 FROM admins WHERE id = auth.uid() AND is_active = TRUE
    ));

-- سياسات جدول hospitals
CREATE POLICY "Authenticated users can view their own hospital"
    ON hospitals FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Admins can view all hospitals"
    ON hospitals FOR SELECT
    USING (EXISTS (
        SELECT 1 FROM admins WHERE id = auth.uid() AND is_active = TRUE
    ));

CREATE POLICY "Admins can insert hospitals"
    ON hospitals FOR INSERT
    WITH CHECK (EXISTS (
        SELECT 1 FROM admins WHERE id = auth.uid() AND is_active = TRUE
    ));

CREATE POLICY "Admins can update hospitals"
    ON hospitals FOR UPDATE
    USING (EXISTS (
        SELECT 1 FROM admins WHERE id = auth.uid() AND is_active = TRUE
    ));

CREATE POLICY "Admins can delete hospitals"
    ON hospitals FOR DELETE
    USING (EXISTS (
        SELECT 1 FROM admins WHERE id = auth.uid() AND is_active = TRUE
    ));

-- سياسات جدول donors - تحديث
CREATE POLICY "Hospitals and admins can update donors"
    ON donors FOR UPDATE
    USING (
        auth.uid() IN (SELECT id FROM hospitals WHERE is_active = TRUE)
        OR EXISTS (SELECT 1 FROM admins WHERE id = auth.uid() AND is_active = TRUE)
    );

CREATE POLICY "Admins can delete donors"
    ON donors FOR DELETE
    USING (EXISTS (
        SELECT 1 FROM admins WHERE id = auth.uid() AND is_active = TRUE
    ));

-- سياسات جدول reports
CREATE POLICY "Admins can view all reports"
    ON reports FOR SELECT
    USING (EXISTS (
        SELECT 1 FROM admins WHERE id = auth.uid() AND is_active = TRUE
    ));

CREATE POLICY "Admins can update reports"
    ON reports FOR UPDATE
    USING (EXISTS (
        SELECT 1 FROM admins WHERE id = auth.uid() AND is_active = TRUE
    ));

-- سياسات جدول logs
CREATE POLICY "Admins can view all logs"
    ON logs FOR SELECT
    USING (EXISTS (
        SELECT 1 FROM admins WHERE id = auth.uid() AND is_active = TRUE
    ));

-- ========================================
-- 3. الحل البديل الأفضل: استخدام دالة مساعدة
-- ========================================

-- إنشاء دالة للتحقق من أن المستخدم هو admin
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM admins 
        WHERE id = auth.uid() AND is_active = TRUE
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- إنشاء دالة للتحقق من أن المستخدم هو مستشفى
CREATE OR REPLACE FUNCTION is_hospital()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM hospitals 
        WHERE id = auth.uid() AND is_active = TRUE
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ========================================
-- 4. إعادة إنشاء السياسات باستخدام الدوال (الطريقة الأفضل)
-- ========================================

-- حذف السياسات الحالية
DROP POLICY IF EXISTS "Admins can view all admins" ON admins;
DROP POLICY IF EXISTS "Admins can insert new admins" ON admins;
DROP POLICY IF EXISTS "Admins can update admins" ON admins;
DROP POLICY IF EXISTS "Authenticated users can view their own hospital" ON hospitals;
DROP POLICY IF EXISTS "Admins can view all hospitals" ON hospitals;
DROP POLICY IF EXISTS "Admins can insert hospitals" ON hospitals;
DROP POLICY IF EXISTS "Admins can update hospitals" ON hospitals;
DROP POLICY IF EXISTS "Admins can delete hospitals" ON hospitals;
DROP POLICY IF EXISTS "Hospitals and admins can update donors" ON donors;
DROP POLICY IF EXISTS "Admins can delete donors" ON donors;
DROP POLICY IF EXISTS "Admins can view all reports" ON reports;
DROP POLICY IF EXISTS "Admins can update reports" ON reports;
DROP POLICY IF EXISTS "Admins can view all logs" ON logs;

-- سياسات admins مع الدوال
CREATE POLICY "Admin can view own record or all if admin"
    ON admins FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Admin can insert if already admin"
    ON admins FOR INSERT
    WITH CHECK (is_admin());

CREATE POLICY "Admin can update if already admin"
    ON admins FOR UPDATE
    USING (is_admin());

-- سياسات hospitals مع الدوال
CREATE POLICY "Hospital can view own record"
    ON hospitals FOR SELECT
    USING (auth.uid() = id OR is_admin());

CREATE POLICY "Admin can insert hospitals"
    ON hospitals FOR INSERT
    WITH CHECK (is_admin());

CREATE POLICY "Admin can update hospitals"
    ON hospitals FOR UPDATE
    USING (is_admin());

CREATE POLICY "Admin can delete hospitals"
    ON hospitals FOR DELETE
    USING (is_admin());

-- سياسات donors مع الدوال
CREATE POLICY "Hospital or admin can update donors"
    ON donors FOR UPDATE
    USING (is_hospital() OR is_admin());

CREATE POLICY "Admin can delete donors"
    ON donors FOR DELETE
    USING (is_admin());

-- سياسات reports مع الدوال
CREATE POLICY "Admin can view reports"
    ON reports FOR SELECT
    USING (is_admin());

CREATE POLICY "Admin can update reports"
    ON reports FOR UPDATE
    USING (is_admin());

-- سياسات logs مع الدوال
CREATE POLICY "Admin can view logs"
    ON logs FOR SELECT
    USING (is_admin());

-- ========================================
-- 5. تحديث خدمة getUserType
-- ========================================

-- الآن يجب أن يعمل getUserType بشكل صحيح
-- لأن الدوال لها SECURITY DEFINER وتتجاوز RLS

-- اختبار:
-- SELECT is_admin();  -- يجب أن يرجع true إذا كنت admin
-- SELECT is_hospital();  -- يجب أن يرجع true إذا كنت hospital

-- ========================================
-- تم الانتهاء!
-- ========================================

