# ⚡ نفّذ هذا فقط - الحل النهائي!

## 🎯 المشكلة:
```
خطأ 42501 عند إضافة مستشفى
السبب: signUp() يغير session للمستخدم الجديد
```

---

## ✅ الحل (خطوتان فقط!):

### 1️⃣ نفّذ في Supabase SQL Editor:

```sql
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
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM public.admins 
    WHERE id = auth.uid() AND is_active = true
  ) THEN
    RAISE EXCEPTION 'فقط الأدمن يمكنه إضافة مستشفيات';
  END IF;

  INSERT INTO public.hospitals (
    id, name, email, district, 
    phone_number, address, is_active,
    created_at, updated_at
  )
  VALUES (
    p_hospital_id, p_name, p_email, p_district,
    p_phone_number, p_address, true,
    NOW(), NOW()
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.add_hospital_bypassing_rls TO authenticated;
```

---

### 2️⃣ شغّل التطبيق:

```bash
flutter run
```

**الكود تم تحديثه بالفعل! ✅**

---

## 🚀 جرب الآن:

```
1. سجل دخول كأدمن
2. اذهب لإضافة مستشفى
3. املأ البيانات
4. اضغط "إضافة المستشفى"
5. ✅ يجب أن يعمل!
6. سيطلب منك تسجيل الدخول مرة أخرى
```

---

## ⚠️ ملاحظة:

بعد إضافة المستشفى:
- ✅ ستتم الإضافة بنجاح
- 🔄 سيتم تسجيل خروجك تلقائياً
- 🔑 سجل دخول مرة أخرى كأدمن

**هذا طبيعي!** لأن `signUp()` غيّر الـ session.

---

**نفّذ SQL أعلاه الآن ثم جرب التطبيق!** ⚡

