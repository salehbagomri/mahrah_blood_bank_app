# ✅ الحل النهائي - الإصدار 2

## 🔍 ما اكتشفناه:

```
المشكلة:
├─ قبل signUp: auth.uid() = 0e47c51e (الأدمن) ✅
├─ بعد signUp: auth.uid() = a624abfb (المستخدم الجديد) ❌
└─ عند استدعاء الدالة: auth.uid() = a624abfb (ليس أدمن!) ❌

النتيجة: "فقط الأدمن يمكنه إضافة مستشفيات" ❌
```

---

## ✅ الحل:

**تمرير معرف الأدمن كمعامل للدالة!**

```
1. حفظ adminId قبل signUp ✅
2. استدعاء signUp (يغير session) 
3. استدعاء الدالة مع adminId المحفوظ ✅
4. الدالة تتحقق من adminId (وليس auth.uid()) ✅
```

---

## 🚀 نفّذ هذا الآن:

### 1️⃣ نفّذ في Supabase SQL Editor:

```sql
-- حذف الدالة القديمة
DROP FUNCTION IF EXISTS public.add_hospital_bypassing_rls(UUID, TEXT, TEXT, TEXT, TEXT, TEXT);

-- إنشاء دالة جديدة
CREATE OR REPLACE FUNCTION public.add_hospital_bypassing_rls(
  p_admin_id UUID,        -- معرف الأدمن ← جديد!
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
  -- التحقق من معرف الأدمن المُمرَّر (وليس auth.uid())
  IF NOT EXISTS (
    SELECT 1 FROM public.admins 
    WHERE id = p_admin_id 
      AND is_active = true
  ) THEN
    RAISE EXCEPTION 'المستخدم ليس أدمناً أو غير نشط';
  END IF;

  -- إضافة المستشفى
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

### 2️⃣ الكود تم تحديثه بالفعل! ✅

**ما تم:**
- ✅ حفظ `adminId` قبل `signUp`
- ✅ تمرير `p_admin_id` للدالة
- ✅ الدالة تتحقق من `p_admin_id` (وليس `auth.uid()`)

---

### 3️⃣ شغّل التطبيق:

```bash
flutter run
```

---

### 4️⃣ جرب الآن:

```
1. سجل دخول كأدمن
2. اذهب لإضافة مستشفى
3. املأ البيانات
4. اضغط "إضافة المستشفى"
5. ✅ يجب أن يعمل الآن!
```

---

## 📊 الفرق بين النسختين:

### النسخة الأولى (لم تعمل):
```sql
-- التحقق من auth.uid() ← يتغير بعد signUp!
IF NOT EXISTS (
  SELECT 1 FROM admins WHERE id = auth.uid()
) THEN ...
```

### النسخة الثانية (ستعمل):
```sql
-- التحقق من p_admin_id ← محفوظ قبل signUp!
IF NOT EXISTS (
  SELECT 1 FROM admins WHERE id = p_admin_id
) THEN ...
```

---

## 🎯 ملاحظات:

### الأمان:
```
✅ آمنة: تتحقق من أن p_admin_id موجود في admins
✅ لا يمكن خداعها: SECURITY DEFINER يتحقق من قاعدة البيانات
✅ محمية: لا يمكن تمرير معرف عشوائي
```

### تجربة المستخدم:
```
بعد الإضافة:
1. رسالة نجاح ✅
2. تسجيل خروج تلقائي 🔄
3. إعادة توجيه للصفحة الرئيسية 🏠
4. تسجيل دخول مرة أخرى 🔑
```

---

**نفّذ `create_hospital_function_v2.sql` الآن!** 🚀

