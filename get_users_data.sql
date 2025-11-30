-- ============================================
-- سكريبت جلب بيانات المستخدمين
-- ============================================

-- 1. جلب جميع المستخدمين من auth.users
-- ملاحظة: قد تحتاج صلاحيات أعلى لقراءة auth.users
SELECT 
    id,
    email,
    created_at,
    email_confirmed_at,
    confirmed_at,
    raw_user_meta_data,
    raw_app_meta_data
FROM auth.users
ORDER BY created_at DESC;

-- ============================================

-- 2. جلب جميع المستشفيات من public.hospitals
SELECT 
    h.id,
    h.name,
    h.email,
    h.district,
    h.phone_number,
    h.address,
    h.is_active,
    h.created_at,
    h.updated_at,
    -- التحقق من وجود مستخدم auth
    CASE 
        WHEN EXISTS (SELECT 1 FROM auth.users WHERE id = h.id) 
        THEN '✅ موجود' 
        ELSE '❌ غير موجود' 
    END as auth_user_exists
FROM public.hospitals h
ORDER BY h.created_at DESC;

-- ============================================

-- 3. جلب جميع الأدمن من public.admins
SELECT 
    a.id,
    a.name,
    a.email,
    a.is_active,
    a.created_at,
    a.updated_at,
    -- التحقق من وجود مستخدم auth
    CASE 
        WHEN EXISTS (SELECT 1 FROM auth.users WHERE id = a.id) 
        THEN '✅ موجود' 
        ELSE '❌ غير موجود' 
    END as auth_user_exists
FROM public.admins a
ORDER BY a.created_at DESC;

-- ============================================

-- 4. المستخدمين في Auth بدون سجل في hospitals أو admins
-- (يوزرات يتيمة - تم إنشاؤها لكن لم تضاف للجداول)
SELECT 
    u.id,
    u.email,
    u.created_at,
    u.email_confirmed_at,
    CASE 
        WHEN EXISTS (SELECT 1 FROM public.admins WHERE id = u.id) 
        THEN 'Admin' 
        WHEN EXISTS (SELECT 1 FROM public.hospitals WHERE id = u.id) 
        THEN 'Hospital'
        ELSE '❌ غير مسجل' 
    END as user_type
FROM auth.users u
WHERE NOT EXISTS (SELECT 1 FROM public.admins WHERE id = u.id)
  AND NOT EXISTS (SELECT 1 FROM public.hospitals WHERE id = u.id)
ORDER BY u.created_at DESC;

-- ============================================

-- 5. عدد المستخدمين حسب النوع
SELECT 
    'Total Auth Users' as category,
    COUNT(*) as count
FROM auth.users

UNION ALL

SELECT 
    'Admins' as category,
    COUNT(*) as count
FROM public.admins

UNION ALL

SELECT 
    'Hospitals' as category,
    COUNT(*) as count
FROM public.hospitals

UNION ALL

SELECT 
    'Orphaned Users' as category,
    COUNT(*) as count
FROM auth.users u
WHERE NOT EXISTS (SELECT 1 FROM public.admins WHERE id = u.id)
  AND NOT EXISTS (SELECT 1 FROM public.hospitals WHERE id = u.id);

