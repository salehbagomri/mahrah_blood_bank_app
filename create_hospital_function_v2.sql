-- ============================================
-- دالة لإضافة مستشفى (النسخة الثانية - المحسّنة)
-- ============================================

-- حذف الدالة القديمة
DROP FUNCTION IF EXISTS public.add_hospital_bypassing_rls(UUID, TEXT, TEXT, TEXT, TEXT, TEXT);

-- إنشاء دالة جديدة تستقبل معرف الأدمن
CREATE OR REPLACE FUNCTION public.add_hospital_bypassing_rls(
  p_admin_id UUID,           -- معرف الأدمن (قبل signUp)
  p_hospital_id UUID,        -- معرف المستشفى الجديد
  p_name TEXT,
  p_email TEXT,
  p_district TEXT,
  p_phone_number TEXT DEFAULT NULL,
  p_address TEXT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER  -- تتجاوز RLS
SET search_path = public
AS $$
BEGIN
  -- التحقق من أن الأدمن (المعامل) موجود وفعّال
  IF NOT EXISTS (
    SELECT 1 FROM public.admins 
    WHERE id = p_admin_id 
      AND is_active = true
  ) THEN
    RAISE EXCEPTION 'المستخدم ليس أدمناً أو غير نشط';
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

  RAISE NOTICE 'تم إضافة المستشفى: % بواسطة الأدمن: %', p_name, p_admin_id;
END;
$$;

-- منح صلاحيات التنفيذ
GRANT EXECUTE ON FUNCTION public.add_hospital_bypassing_rls TO authenticated;

-- ============================================
-- ملاحظات
-- ============================================

/*
✅ الفرق عن النسخة السابقة:
- تستقبل معرف الأدمن كمعامل (p_admin_id)
- تتحقق من المعامل بدلاً من auth.uid()
- آمنة لأنها تتحقق من أن p_admin_id موجود في admins

🎯 الاستخدام:
await supabase.rpc('add_hospital_bypassing_rls', params: {
  'p_admin_id': adminId,        // معرف الأدمن (قبل signUp)
  'p_hospital_id': userId,      // معرف المستشفى الجديد
  'p_name': name,
  'p_email': email,
  'p_district': district,
  'p_phone_number': phone,
  'p_address': address,
});
*/

