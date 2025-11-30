-- ============================================
-- دالة لإضافة مستشفى مع تجاوز RLS
-- ============================================

CREATE OR REPLACE FUNCTION public.add_hospital_bypassing_rls(
  p_hospital_id UUID,
  p_name TEXT,
  p_email TEXT,
  p_district TEXT,
  p_phone_number TEXT DEFAULT NULL,
  p_address TEXT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER  -- هذا يجعل الدالة تعمل بصلاحيات مالك الدالة (تتجاوز RLS)
SET search_path = public
AS $$
BEGIN
  -- التحقق من أن المستخدم الحالي هو أدمن
  IF NOT EXISTS (
    SELECT 1 FROM public.admins 
    WHERE id = auth.uid() 
      AND is_active = true
  ) THEN
    RAISE EXCEPTION 'فقط الأدمن يمكنه إضافة مستشفيات';
  END IF;

  -- إضافة المستشفى (RLS لن يتحقق بسبب SECURITY DEFINER)
  INSERT INTO public.hospitals (
    id,
    name,
    email,
    district,
    phone_number,
    address,
    is_active,
    created_at,
    updated_at
  )
  VALUES (
    p_hospital_id,
    p_name,
    p_email,
    p_district,
    p_phone_number,
    p_address,
    true,
    NOW(),
    NOW()
  );

  RAISE NOTICE 'تم إضافة المستشفى: %', p_name;
END;
$$;

-- ============================================
-- منح صلاحيات التنفيذ للمستخدمين المصادق عليهم
-- ============================================

GRANT EXECUTE ON FUNCTION public.add_hospital_bypassing_rls TO authenticated;

-- ============================================
-- اختبار الدالة
-- ============================================

-- يجب أن يعمل هذا فقط إذا كنت أدمن:
-- SELECT add_hospital_bypassing_rls(
--   gen_random_uuid(),
--   'مستشفى تجريبي',
--   'test@hospital.com',
--   'الغيظة',
--   '1234567890',
--   'عنوان تجريبي'
-- );

-- ============================================
-- ملاحظات
-- ============================================

/*
✅ هذه الدالة:
1. تتحقق من أن المستخدم الحالي هو أدمن
2. تضيف المستشفى بصلاحيات DEFINER (تتجاوز RLS)
3. آمنة لأنها تتحقق من الصلاحيات أولاً

⚠️ SECURITY DEFINER:
- تجعل الدالة تعمل بصلاحيات مالك الدالة (postgres/supabase)
- تتجاوز RLS policies
- لذلك يجب التحقق من الصلاحيات داخل الدالة!

🎯 الاستخدام:
- التطبيق يستدعي هذه الدالة عبر supabase.rpc()
- الدالة تتحقق من أن المستدعي هو أدمن
- ثم تضيف المستشفى متجاوزة RLS
*/

