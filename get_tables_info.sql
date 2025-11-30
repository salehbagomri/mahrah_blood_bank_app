-- ============================================
-- سكريبت جلب معلومات جداول المستخدمين
-- ============================================

-- 1. معلومات جدول auth.users
SELECT 
    'auth.users' as table_name,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'auth' 
  AND table_name = 'users'
ORDER BY ordinal_position;

-- ============================================

-- 2. معلومات جدول public.hospitals
SELECT 
    'public.hospitals' as table_name,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'hospitals'
ORDER BY ordinal_position;

-- ============================================

-- 3. معلومات جدول public.admins
SELECT 
    'public.admins' as table_name,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'admins'
ORDER BY ordinal_position;

-- ============================================

-- 4. عرض سياسات RLS على جدول hospitals
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
WHERE schemaname = 'public' 
  AND tablename = 'hospitals';

-- ============================================

-- 5. التحقق من تفعيل RLS
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('hospitals', 'admins', 'donors');

