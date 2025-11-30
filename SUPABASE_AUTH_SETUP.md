# إعداد Supabase لإضافة مستشفى من التطبيق

## ⚠️ المشكلة: خطأ 400 عند إضافة مستشفى

### السبب:
Supabase يتطلب تأكيد البريد الإلكتروني افتراضياً عند التسجيل.

---

## ✅ الحل: تعطيل تأكيد البريد الإلكتروني

### الخطوات:

1. **اذهب إلى Supabase Dashboard**
   ```
   https://supabase.com/dashboard
   ```

2. **افتح مشروعك**

3. **اذهب إلى Authentication > Settings**
   ```
   Dashboard > Authentication > Settings
   ```

4. **ابحث عن "Email Auth"**

5. **عطّل "Enable email confirmations"**
   - ✅ قم بإزالة علامة ✓ من "Enable email confirmations"
   - أو
   - ✅ قم بتفعيل "Allow unconfirmed email sign-in"

6. **احفظ التغييرات**
   - اضغط "Save"

---

## 🔄 البديل: استخدام Auto-confirm

إذا كنت لا تريد تعطيل التأكيد كلياً:

### في Supabase Dashboard:

1. اذهب إلى **Authentication > Settings**
2. ابحث عن **"Auto Confirm Users"**
3. فعّل **"Enable auto confirm"**
4. احفظ

---

## 🔐 للإنتاج (Production)

### الطريقة الآمنة:

بدلاً من السماح بالتسجيل المباشر، استخدم:

#### 1. Supabase Edge Function

إنشاء Edge Function للأدمن فقط:

```sql
-- في Supabase SQL Editor
-- إنشاء دالة خاصة بالأدمن
CREATE OR REPLACE FUNCTION create_hospital_user(
  p_email text,
  p_password text,
  p_name text,
  p_district text,
  p_phone_number text,
  p_address text
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id uuid;
BEGIN
  -- التحقق أن المستخدم الحالي هو أدمن
  IF NOT EXISTS (SELECT 1 FROM admins WHERE id = auth.uid()) THEN
    RAISE EXCEPTION 'Unauthorized: Only admins can create hospitals';
  END IF;

  -- هنا يمكنك استخدام Admin API
  -- لكن هذا يحتاج Service Role Key
  
  RETURN json_build_object('success', false, 'message', 'Use Supabase Dashboard');
END;
$$;
```

#### 2. استخدام Service Role (غير آمن في التطبيق)

⚠️ **لا تستخدم Service Role Key في التطبيق أبداً!**

---

## 📝 الحل المؤقت المستخدم حالياً

التطبيق حالياً يستخدم `signUp` العادي مع:
- ✅ معالجة أخطاء محسّنة
- ✅ رسائل واضحة للمستخدم
- ✅ بيانات إضافية (metadata)

### يتطلب:
- تعطيل Email Confirmation في Supabase
- أو
- تفعيل Auto Confirm

---

## 🧪 اختبار الحل

### بعد تعطيل Email Confirmation:

1. افتح التطبيق
2. سجل دخول كأدمن
3. اذهب إلى "إدارة المستشفيات"
4. اضغط "إضافة مستشفى"
5. املأ البيانات:
   - البريد: `test@hospital.com`
   - كلمة المرور: `123456` (أو أقوى)
   - باقي البيانات
6. اضغط "إضافة المستشفى"

### النتيجة المتوقعة:
✅ رسالة نجاح مع بيانات تسجيل الدخول

---

## ❌ رسائل الخطأ الشائعة

### 1. خطأ 400
**السبب**: Email Confirmation مفعّل
**الحل**: عطّل Email Confirmation

### 2. "البريد الإلكتروني مسجل بالفعل"
**السبب**: البريد مستخدم
**الحل**: استخدم بريد آخر

### 3. "كلمة المرور قصيرة"
**السبب**: كلمة المرور أقل من 6 أحرف
**الحل**: استخدم كلمة مرور أطول

---

## 🔍 التحقق من الإعدادات

### في Supabase Dashboard:

```
Authentication > Settings > Email Auth

تأكد من:
☐ Enable email confirmations (معطّل)
أو
☑ Allow unconfirmed email sign-in (مفعّل)
```

---

## 📊 الإعدادات الموصى بها للتطوير

```
Authentication > Settings:

Email Auth:
☑ Enable Email provider
☐ Enable email confirmations (معطّل للتطوير)
☑ Allow unconfirmed email sign-in

Email Templates:
- يمكن تخصيصها لاحقاً
```

---

## 📊 الإعدادات الموصى بها للإنتاج

```
Authentication > Settings:

Email Auth:
☑ Enable Email provider
☑ Enable email confirmations (مفعّل للإنتاج)
☐ Allow unconfirmed email sign-in

+ استخدام Edge Function أو Server-side code
```

---

## ✅ الخلاصة

### للتطوير (Development):
1. عطّل Email Confirmation
2. استخدم الطريقة الحالية (signUp)
3. اختبر الوظيفة

### للإنتاج (Production):
1. استخدم Edge Function
2. أو استخدم Supabase Dashboard يدوياً
3. أو استخدم Server-side API

---

**بعد تطبيق الحل، أعد المحاولة!** ✅

