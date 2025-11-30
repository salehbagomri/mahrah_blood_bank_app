# 🚀 نفّذ هذا الآن - الحل المضمون!

## 📊 ما اكتشفناه:

```
✅ أنت مسجل دخول كأدمن
✅ معرفك: 0e47c51e-417f-43a7-b53f-24e6187a1864
✅ موجود في جدول admins: true
✅ تم إنشاء المستخدم الجديد: نجح
❌ خطأ 42501: سياسة RLS تمنع الإضافة
```

---

## 🔥 الحل (نسخ ولصق!):

### 1️⃣ افتح Supabase SQL Editor

```
Supabase Dashboard > SQL Editor > New Query
```

---

### 2️⃣ انسخ والصق هذا الكود:

```sql
-- حذف جميع سياسات INSERT القديمة
DO $$ 
DECLARE
    pol RECORD;
BEGIN
    FOR pol IN (
        SELECT policyname 
        FROM pg_policies 
        WHERE schemaname = 'public' 
          AND tablename = 'hospitals'
          AND cmd = 'INSERT'
    ) LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.hospitals', pol.policyname);
    END LOOP;
END $$;

-- إنشاء السياسة الصحيحة
CREATE POLICY "hospitals_insert_for_admins"
ON public.hospitals
FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 
    FROM public.admins 
    WHERE admins.id = auth.uid() 
      AND admins.is_active = true
  )
);
```

---

### 3️⃣ اضغط "Run" أو F5

انتظر حتى ترى: ✅ Success

---

### 4️⃣ في التطبيق:

```bash
1. أغلق التطبيق تماماً (Stop)
2. شغّله من جديد (Run)
3. جرب إضافة مستشفى مباشرة
4. ✅ يجب أن يعمل!
```

---

## ⚡ بديل: استخدم السكريبت الجاهز

**نفّذ:** `FINAL_SOLUTION.sql` في Supabase

(يحتوي على نفس الكود + فحوصات إضافية)

---

## 🎯 لماذا سيعمل الآن:

### المشكلة السابقة:
```sql
-- السياسة القديمة كانت:
WITH CHECK (public.is_admin())
-- أو
WITH CHECK (EXISTS(...))

← لكن لم تكن تعمل بشكل صحيح
```

### الحل الجديد:
```sql
-- السياسة الجديدة:
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.admins 
    WHERE admins.id = auth.uid() 
      AND admins.is_active = true
  )
)

← تستخدم EXISTS مباشرة مع اسم الجدول الكامل
← تتحقق من is_active أيضاً
← أكثر وضوحاً لـ Postgres
```

---

## 🔍 للتحقق من النجاح:

بعد تنفيذ السكريبت، نفّذ:

```sql
SELECT policyname, cmd 
FROM pg_policies 
WHERE tablename = 'hospitals' AND cmd = 'INSERT';
```

**يجب أن ترى:**
```
policyname: hospitals_insert_for_admins
cmd: INSERT
```

---

## ⚠️ إذا لم يعمل:

### الخطوة 1: تحقق من السياسة
```sql
SELECT * FROM pg_policies WHERE tablename = 'hospitals';
```

### الخطوة 2: تحقق من RLS
```sql
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'hospitals';
```
يجب أن يكون `rowsecurity = true`

### الخطوة 3: اختبار يدوي
```sql
-- تسجيل دخول كأدمن في SQL Editor غير ممكن
-- لكن يمكن محاكاة:

SET SESSION "request.jwt.claim.sub" = '0e47c51e-417f-43a7-b53f-24e6187a1864';

-- ثم جرب:
INSERT INTO hospitals (id, name, email, district, is_active)
VALUES (
  gen_random_uuid(),
  'Test Hospital',
  'test@example.com',
  'الغيظة',
  true
);
```

---

## 📞 إذا استمرت المشكلة:

أرسل لي نتيجة:

```sql
SELECT * FROM pg_policies WHERE tablename = 'hospitals';
```

---

## 🚀 الملخص السريع:

```bash
1. نفّذ الكود SQL أعلاه في Supabase ✅
2. أغلق التطبيق تماماً ✅
3. افتحه من جديد ✅
4. جرب إضافة مستشفى ✅
5. يجب أن يعمل! 🎉
```

---

**نفّذ الكود الآن!** ⬆️

