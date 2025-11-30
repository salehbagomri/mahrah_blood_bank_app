# 🚀 نفّذ هذا الآن!

## ✅ أنت موجود كأدمن:
```
المعرف: 0e47c51e-417f-43a7-b53f-24e6187a1864
الاسم: المدير العام
البريد: s.bagomri@gmail.com.com
نشط: true ✅
```

---

## 🔧 الخطوات (دقيقتان فقط!):

### 1️⃣ افتح Supabase SQL Editor

```
Supabase Dashboard > SQL Editor > New Query
```

---

### 2️⃣ نفّذ هذا الكود:

**انسخ والصق والضغط على Run:**

```sql
-- حذف جميع سياسات INSERT القديمة
DROP POLICY IF EXISTS "Enable insert for admins only" ON public.hospitals;
DROP POLICY IF EXISTS "hospitals_insert_policy" ON public.hospitals;
DROP POLICY IF EXISTS "hospitals_insert_admin" ON public.hospitals;
DROP POLICY IF EXISTS "hospitals_insert_policy_temp" ON public.hospitals;

-- إنشاء السياسة الصحيحة
CREATE POLICY "hospitals_insert"
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

-- التحقق
SELECT policyname, cmd FROM pg_policies 
WHERE tablename = 'hospitals' AND cmd = 'INSERT';
```

**يجب أن ترى:**
```
policyname: hospitals_insert
cmd: INSERT
```

---

### 3️⃣ في التطبيق (مهم جداً!):

```bash
1. أغلق التطبيق تماماً (Stop/Kill)
   ↓
2. شغّله من جديد (Run)
   ↓
3. سجل دخول بـ: s.bagomri@gmail.com.com
   ↓
4. اذهب لإضافة مستشفى
   ↓
5. ✅ يجب أن يعمل!
```

---

## 🎯 بديل أسرع:

إذا أردت إصلاح **جميع السياسات** (SELECT, INSERT, UPDATE, DELETE) مرة واحدة:

**نفّذ:** `COMPLETE_POLICIES_FIX.sql` بدلاً من الكود أعلاه

---

## ⚠️ إذا لم يعمل بعد:

### فحص 1: هل السياسة موجودة؟

```sql
SELECT * FROM pg_policies WHERE tablename = 'hospitals';
```

يجب أن ترى: `hospitals_insert`

---

### فحص 2: هل أنت مسجل دخول في التطبيق؟

```
تأكد من:
✅ سجلت دخول بـ s.bagomri@gmail.com.com
✅ أعدت تشغيل التطبيق (Hot Restart)
```

---

### فحص 3: هل Session نشط؟

في التطبيق، أضف هذا التشخيص مؤقتاً:

```dart
// في _addHospital() قبل السطر await supabase.from('hospitals').insert
final userId = Supabase.instance.client.auth.currentUser?.id;
print('🔍 User ID: $userId');

// تحقق من الأدمن
final isAdminCheck = await Supabase.instance.client
    .from('admins')
    .select()
    .eq('id', userId!)
    .maybeSingle();
print('🔍 Is Admin: ${isAdminCheck != null}');
```

---

## 📋 السكريبتات الإضافية:

| الملف | متى تستخدمه |
|------|-------------|
| `FINAL_FIX_SIMPLE.sql` | نفس الحل أعلاه (ملف منفصل) |
| `COMPLETE_POLICIES_FIX.sql` | إصلاح جميع السياسات مرة واحدة |
| `CHECK_POLICIES.sql` | فحص السياسات الحالية |

---

## 🚀 الملخص:

```bash
1. نفّذ الكود SQL أعلاه في Supabase
2. أغلق التطبيق
3. افتحه من جديد
4. سجل دخول
5. جرب!
```

---

**نفّذ الكود SQL الآن!** ⬆️

