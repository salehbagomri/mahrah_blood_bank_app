-- ============================================
-- فحص بسيط وسريع للمستخدمين
-- ============================================

-- 1️⃣ عرض جميع المستخدمين في Auth
SELECT 
    '1️⃣ Auth Users' as "الجدول",
    id as "المعرف",
    email as "البريد الإلكتروني",
    created_at as "تاريخ الإنشاء",
    email_confirmed_at as "تاريخ تأكيد البريد"
FROM auth.users
ORDER BY created_at DESC
LIMIT 10;

-- ============================================

-- 2️⃣ عرض جميع المستشفيات
SELECT 
    '2️⃣ Hospitals' as "الجدول",
    id as "المعرف",
    name as "الاسم",
    email as "البريد",
    district as "المديرية",
    is_active as "نشط؟",
    created_at as "تاريخ الإنشاء"
FROM public.hospitals
ORDER BY created_at DESC;

-- ============================================

-- 3️⃣ عرض جميع الأدمن
SELECT 
    '3️⃣ Admins' as "الجدول",
    id as "المعرف",
    name as "الاسم",
    email as "البريد",
    is_active as "نشط؟",
    created_at as "تاريخ الإنشاء"
FROM public.admins
ORDER BY created_at DESC;

-- ============================================

-- 4️⃣ المستخدمين "اليتامى" (في Auth لكن ليس في hospitals أو admins)
SELECT 
    '4️⃣ Orphaned Users' as "النوع",
    u.id as "المعرف",
    u.email as "البريد",
    u.created_at as "تاريخ الإنشاء",
    '❌ غير مسجل في أي جدول' as "الحالة"
FROM auth.users u
WHERE NOT EXISTS (SELECT 1 FROM public.admins WHERE id = u.id)
  AND NOT EXISTS (SELECT 1 FROM public.hospitals WHERE id = u.id)
ORDER BY u.created_at DESC;

-- ============================================

-- 5️⃣ إحصائيات سريعة
SELECT 
    'Total Auth Users' as "النوع",
    COUNT(*) as "العدد"
FROM auth.users

UNION ALL

SELECT 
    'Admins' as "النوع",
    COUNT(*) as "العدد"
FROM public.admins

UNION ALL

SELECT 
    'Hospitals' as "النوع",
    COUNT(*) as "العدد"
FROM public.hospitals

UNION ALL

SELECT 
    'Orphaned Users' as "النوع",
    COUNT(*) as "العدد"
FROM auth.users u
WHERE NOT EXISTS (SELECT 1 FROM public.admins WHERE id = u.id)
  AND NOT EXISTS (SELECT 1 FROM public.hospitals WHERE id = u.id);

