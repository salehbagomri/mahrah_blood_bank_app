-- ============================================
-- فحص الأدمن الموجودين
-- ============================================

-- عرض جميع الأدمن
SELECT 
    id,
    name,
    email,
    is_active,
    created_at
FROM public.admins
ORDER BY created_at DESC;

-- ============================================
-- عرض جميع المستخدمين في Auth
-- ============================================

SELECT 
    id,
    email,
    created_at,
    email_confirmed_at
FROM auth.users
ORDER BY created_at DESC
LIMIT 10;

-- ============================================
-- مقارنة: من في Auth لكن ليس Admin؟
-- ============================================

SELECT 
    u.id,
    u.email,
    u.created_at,
    CASE 
        WHEN EXISTS (SELECT 1 FROM public.admins WHERE id = u.id) 
        THEN '✅ Admin'
        WHEN EXISTS (SELECT 1 FROM public.hospitals WHERE id = u.id) 
        THEN '🏥 Hospital'
        ELSE '❌ Not assigned'
    END as "النوع"
FROM auth.users u
ORDER BY u.created_at DESC;

