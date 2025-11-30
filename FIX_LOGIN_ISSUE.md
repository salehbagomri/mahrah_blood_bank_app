# حل مشكلة "لا يمكن تحديد نوع المستخدم"

## 🐛 المشكلة

عند محاولة تسجيل الدخول، تظهر رسالة خطأ:
```
infinite recursion detected in policy for relation "admins"
```

### السبب:
سياسات RLS (Row Level Security) في Supabase تحتوي على **infinite recursion**:
- السياسة تحاول التحقق من جدول `admins`
- لكن للوصول إلى جدول `admins`، تحتاج للتحقق من السياسة
- مما يسبب حلقة لا نهائية! ♾️

---

## ✅ الحل

### الخطوة 1: تنفيذ سكريبت الإصلاح في Supabase

1. افتح [Supabase Dashboard](https://app.supabase.com/)
2. اختر مشروعك: **mahrah-blood-bank**
3. اذهب إلى **SQL Editor**
4. اضغط **New Query**
5. انسخ محتوى ملف `fix_rls_policies.sql` بالكامل
6. الصقه في المحرر
7. اضغط **Run** أو `Ctrl+Enter`

### الخطوة 2: التحقق من نجاح التنفيذ

بعد تنفيذ السكريبت، نفّذ هذا الاستعلام للتأكد:

```sql
-- اختبار الدوال الجديدة
SELECT is_admin();  -- يجب أن يرجع true أو false
SELECT is_hospital();  -- يجب أن يرجع true أو false
```

إذا لم تظهر أخطاء، فالإصلاح نجح! ✅

### الخطوة 3: أعد تشغيل التطبيق

```bash
# أعد تشغيل التطبيق
flutter run
# أو اضغط 'R' في Terminal للـ Hot Restart
```

---

## 🔧 ما الذي تم إصلاحه؟

### 1. إنشاء دوال مساعدة

تم إنشاء دالتين بـ `SECURITY DEFINER` تتجاوزان RLS:

```sql
-- التحقق من أن المستخدم admin
CREATE FUNCTION is_admin() RETURNS BOOLEAN

-- التحقق من أن المستخدم hospital
CREATE FUNCTION is_hospital() RETURNS BOOLEAN
```

### 2. تحديث السياسات

تم تحديث جميع السياسات لاستخدام هذه الدوال بدلاً من الاستعلامات المباشرة:

**قبل (مشكلة):**
```sql
CREATE POLICY "Only admins can view admins" ON admins
USING (auth.uid() IN (SELECT id FROM admins WHERE is_active = TRUE));
-- ❌ هذا يسبب infinite recursion!
```

**بعد (حل):**
```sql
CREATE POLICY "Admin can view own record" ON admins
USING (auth.uid() = id);
-- ✅ بسيط وبدون recursion!
```

### 3. تحديث الكود

تم تحديث `supabase_service.dart` لاستخدام الدوال الجديدة:

```dart
// استخدام is_admin() و is_hospital()
final isAdminResult = await client.rpc('is_admin').single();
```

مع fallback للطريقة القديمة في حالة عدم تنفيذ السكريبت.

---

## 🧪 اختبار الحل

### 1. إنشاء حساب تجريبي

```sql
-- في Supabase Dashboard
-- Authentication > Users > Add user
-- Email: admin@test.com
-- Password: test123456
-- ✅ Auto Confirm User

-- بعد إنشاء المستخدم، انسخ الـ UID ونفّذ:
INSERT INTO admins (id, name, email, is_active)
VALUES (
    'YOUR_USER_UID_HERE',
    'Admin Test',
    'admin@test.com',
    TRUE
);
```

### 2. تسجيل الدخول من التطبيق

1. افتح التطبيق
2. اضغط على أيقونة 🔑 (Login)
3. أدخل:
   - Email: `admin@test.com`
   - Password: `test123456`
4. اضغط "تسجيل الدخول"

### النتيجة المتوقعة:
- ✅ يجب أن يتم تسجيل الدخول بنجاح
- ✅ يتم توجيهك إلى لوحة الأدمن
- ✅ لا توجد رسائل خطأ

---

## 🔍 استكشاف الأخطاء

### خطأ: "Function is_admin() does not exist"

**السبب:** لم يتم تنفيذ `fix_rls_policies.sql`

**الحل:**
1. تأكد من تنفيذ السكريبت في Supabase
2. تحقق من عدم وجود أخطاء في تنفيذ السكريبت

### خطأ: "Permission denied"

**السبب:** السياسات لم يتم تحديثها بشكل صحيح

**الحل:**
1. نفّذ هذا الاستعلام لحذف جميع السياسات القديمة:

```sql
-- حذف جميع السياسات القديمة
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT policyname, tablename FROM pg_policies 
              WHERE schemaname = 'public' 
              AND tablename IN ('admins', 'hospitals', 'donors', 'reports', 'logs'))
    LOOP
        EXECUTE 'DROP POLICY IF EXISTS "' || r.policyname || '" ON ' || r.tablename;
    END LOOP;
END $$;
```

2. ثم نفّذ `fix_rls_policies.sql` مرة أخرى

### خطأ: لا يزال "لا يمكن تحديد نوع المستخدم"

**الحل:**
1. تحقق من أن المستخدم موجود في جدول admins أو hospitals:

```sql
-- التحقق
SELECT * FROM admins WHERE email = 'your-email@example.com';
SELECT * FROM hospitals WHERE email = 'your-email@example.com';
```

2. تأكد من أن `is_active = TRUE`:

```sql
-- تحديث
UPDATE admins SET is_active = TRUE WHERE email = 'your-email@example.com';
```

---

## 📊 عرض السياسات الحالية

لعرض جميع السياسات:

```sql
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;
```

---

## 🔐 السياسات الجديدة الصحيحة

### جدول admins:
- ✅ `Admin can view own record or all if admin`
- ✅ `Admin can insert if already admin`
- ✅ `Admin can update if already admin`

### جدول hospitals:
- ✅ `Hospital can view own record`
- ✅ `Admin can insert hospitals`
- ✅ `Admin can update hospitals`
- ✅ `Admin can delete hospitals`

### جدول donors:
- ✅ `Anyone can view active available donors`
- ✅ `Anyone can insert donors`
- ✅ `Hospital or admin can update donors`
- ✅ `Admin can delete donors`

### جدول reports:
- ✅ `Anyone can insert reports`
- ✅ `Admin can view reports`
- ✅ `Admin can update reports`

---

## ✅ الخلاصة

1. **نفّذ `fix_rls_policies.sql`** في Supabase SQL Editor
2. **أعد تشغيل التطبيق**
3. **جرّب تسجيل الدخول**
4. **يجب أن يعمل بدون مشاكل!** 🎉

---

## 📞 الدعم

إذا استمرت المشكلة:
1. تحقق من Supabase Logs (Dashboard > Logs)
2. تأكد من تنفيذ جميع خطوات الإصلاح
3. راجع ملف `CREATE_ACCOUNTS.md` للتأكد من صحة إنشاء الحسابات

---

**🩸 التبرع بالدم ينقذ الأرواح!**

