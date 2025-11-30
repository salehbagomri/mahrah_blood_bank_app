-- ═══════════════════════════════════════════════════════════════
-- سكربت تحديث بيانات الأدمن
-- تحديث من: s.bagomri@gmail.com → admin@test.com
-- ═══════════════════════════════════════════════════════════════

-- الخطوة 1: الحصول على معرف المستخدم الحالي
DO $$
DECLARE
  admin_user_id UUID;
BEGIN
  -- البحث عن المستخدم بالإيميل القديم
  SELECT id INTO admin_user_id
  FROM auth.users
  WHERE email = 's.bagomri@gmail.com'
  LIMIT 1;

  IF admin_user_id IS NULL THEN
    RAISE EXCEPTION 'لم يتم العثور على المستخدم بالإيميل: s.bagomri@gmail.com';
  END IF;

  RAISE NOTICE 'تم العثور على المستخدم: %', admin_user_id;

  -- الخطوة 2: تحديث الإيميل في auth.users
  UPDATE auth.users
  SET 
    email = 'admin@test.com',
    raw_user_meta_data = jsonb_set(
      COALESCE(raw_user_meta_data, '{}'::jsonb),
      '{email}',
      '"admin@test.com"'::jsonb
    ),
    updated_at = NOW()
  WHERE id = admin_user_id;

  RAISE NOTICE 'تم تحديث الإيميل في auth.users';

  -- الخطوة 3: تحديث الإيميل في public.admins
  UPDATE public.admins
  SET 
    email = 'admin@test.com',
    updated_at = NOW()
  WHERE id = admin_user_id;

  RAISE NOTICE 'تم تحديث الإيميل في public.admins';

  -- الخطوة 4: تحديث كلمة المرور
  -- ملاحظة: يجب استخدام Supabase Auth API لتحديث كلمة المرور بشكل آمن
  -- هذا السكربت يقوم بإنشاء hash لكلمة المرور الجديدة
  
  UPDATE auth.users
  SET 
    encrypted_password = crypt('test123456', gen_salt('bf')),
    updated_at = NOW()
  WHERE id = admin_user_id;

  RAISE NOTICE 'تم تحديث كلمة المرور';

  RAISE NOTICE '════════════════════════════════════════';
  RAISE NOTICE 'تم التحديث بنجاح! ✅';
  RAISE NOTICE '════════════════════════════════════════';
  RAISE NOTICE 'الإيميل الجديد: admin@test.com';
  RAISE NOTICE 'كلمة المرور الجديدة: test123456';
  RAISE NOTICE '════════════════════════════════════════';
  
END $$;

-- ═══════════════════════════════════════════════════════════════
-- التحقق من التحديث
-- ═══════════════════════════════════════════════════════════════

-- عرض بيانات المستخدم الجديدة
SELECT 
  u.id,
  u.email,
  u.created_at,
  u.updated_at,
  a.name AS admin_name,
  a.is_active
FROM auth.users u
LEFT JOIN public.admins a ON a.id = u.id
WHERE u.email = 'admin@test.com';

-- ═══════════════════════════════════════════════════════════════
-- ملاحظات مهمة:
-- ═══════════════════════════════════════════════════════════════
-- 1. تأكد من تنفيذ هذا السكربت في Supabase SQL Editor
-- 2. يجب أن يكون لديك صلاحيات كافية لتعديل جدول auth.users
-- 3. بعد التنفيذ، يمكنك تسجيل الدخول بـ:
--    Email: admin@test.com
--    Password: test123456
-- 4. يُنصح بتغيير كلمة المرور بعد أول تسجيل دخول
-- ═══════════════════════════════════════════════════════════════

