-- بيانات تجريبية لتطبيق بنك دم محافظة المهرة
-- ملاحظة: هذه بيانات وهمية للاختبار فقط

-- ========================================
-- 1. بيانات المتبرعين التجريبية
-- ========================================

-- المتبرعين من مديرية الغيضة
INSERT INTO donors (name, phone_number, blood_type, district, age, gender, notes) VALUES
('أحمد محمد سالم', '777111222', 'A+', 'الغيضة', 28, 'male', 'متبرع دائم'),
('فاطمة علي أحمد', '777222333', 'O+', 'الغيضة', 32, 'female', 'متاحة للتبرع'),
('خالد حسن محمد', '777333444', 'B+', 'الغيضة', 25, 'male', NULL),
('سارة سعيد عمر', '777444555', 'AB+', 'الغيضة', 29, 'female', NULL),
('عبدالله محمد علي', '777555666', 'O-', 'الغيضة', 35, 'male', 'الفصيلة العامة');

-- المتبرعين من مديرية سيحوت
INSERT INTO donors (name, phone_number, blood_type, district, age, gender, notes) VALUES
('محمد عبدالله سالم', '777666777', 'A+', 'سيحوت', 30, 'male', NULL),
('نور حسن علي', '777777888', 'B-', 'سيحوت', 27, 'female', NULL),
('سالم أحمد محمد', '777888999', 'O+', 'سيحوت', 33, 'male', 'متاح دائماً'),
('هدى محمد سعيد', '777999000', 'A-', 'سيحوت', 24, 'female', NULL);

-- المتبرعين من مديرية حصوين
INSERT INTO donors (name, phone_number, blood_type, district, age, gender, notes) VALUES
('علي محمد حسن', '777000111', 'O+', 'حصوين', 31, 'male', NULL),
('رنا سالم أحمد', '777111000', 'AB+', 'حصوين', 26, 'female', NULL),
('حسن عبدالله علي', '777222111', 'B+', 'حصوين', 29, 'male', 'متبرع منتظم'),
('مريم محمد سعيد', '777333222', 'A+', 'حصوين', 28, 'female', NULL);

-- المتبرعين من مديرية قشن
INSERT INTO donors (name, phone_number, blood_type, district, age, gender, notes) VALUES
('سعيد علي محمد', '777444333', 'O-', 'قشن', 34, 'male', 'فصيلة نادرة'),
('أمل حسن سالم', '777555444', 'A+', 'قشن', 27, 'female', NULL),
('فيصل محمد أحمد', '777666555', 'B+', 'قشن', 30, 'male', NULL);

-- المتبرعين من مديرية حات
INSERT INTO donors (name, phone_number, blood_type, district, age, gender, notes) VALUES
('عمر سالم علي', '777777666', 'AB-', 'حات', 32, 'male', 'فصيلة نادرة'),
('ليلى أحمد محمد', '777888777', 'O+', 'حات', 25, 'female', NULL),
('ياسر محمد حسن', '777999888', 'A+', 'حات', 29, 'male', NULL);

-- المتبرعين من مديرية حوف
INSERT INTO donors (name, phone_number, blood_type, district, age, gender, notes) VALUES
('راشد علي سعيد', '777000999', 'B+', 'حوف', 31, 'male', NULL),
('سلمى حسن محمد', '777111888', 'O+', 'حوف', 26, 'female', 'متاحة للطوارئ');

-- المتبرعين من مديرية الحصن
INSERT INTO donors (name, phone_number, blood_type, district, age, gender, notes) VALUES
('ماجد محمد علي', '777222999', 'A-', 'الحصن', 33, 'male', NULL),
('هيفاء سالم أحمد', '777333000', 'AB+', 'الحصن', 28, 'female', NULL);

-- المتبرعين من مديرية المسيلة
INSERT INTO donors (name, phone_number, blood_type, district, age, gender, notes) VALUES
('طارق حسن سعيد', '777444111', 'O+', 'المسيلة', 30, 'male', NULL),
('ريم علي محمد', '777555222', 'B-', 'المسيلة', 27, 'female', NULL);

-- المتبرعين من مديرية شحن
INSERT INTO donors (name, phone_number, blood_type, district, age, gender, notes) VALUES
('وليد محمد حسن', '777666333', 'A+', 'شحن', 29, 'male', NULL),
('دينا سعيد علي', '777777444', 'O-', 'شحن', 25, 'female', 'فصيلة نادرة');

-- ========================================
-- 2. إحصائيات البيانات التجريبية
-- ========================================

-- إجمالي المتبرعين: 30
-- توزيع الفصائل:
-- O+: 8 متبرعين
-- A+: 8 متبرعين
-- B+: 5 متبرعين
-- AB+: 3 متبرعين
-- O-: 3 متبرعين
-- A-: 2 متبرعين
-- B-: 2 متبرعين
-- AB-: 1 متبرع

-- توزيع المديريات:
-- الغيضة: 5 متبرعين
-- سيحوت: 4 متبرعين
-- حصوين: 4 متبرعين
-- قشن: 3 متبرعين
-- حات: 3 متبرعين
-- حوف: 2 متبرعين
-- الحصن: 2 متبرعين
-- المسيلة: 2 متبرعين
-- شحن: 2 متبرعين

-- ========================================
-- 3. ملاحظات مهمة
-- ========================================

-- 1. جميع أرقام الهواتف وهمية وللاختبار فقط
-- 2. الأسماء مستعارة ولا تمثل أشخاص حقيقيين
-- 3. يمكنك تعديل أو حذف هذه البيانات حسب الحاجة
-- 4. لحذف جميع البيانات التجريبية:
--    DELETE FROM donors WHERE phone_number LIKE '777%';

-- ========================================
-- 4. إضافة متبرعين موقوفين (للاختبار)
-- ========================================

-- متبرع تبرع مؤخراً وموقوف لمدة 6 أشهر
UPDATE donors 
SET 
    last_donation_date = NOW() - INTERVAL '30 days',
    suspended_until = NOW() + INTERVAL '150 days'
WHERE phone_number = '777111222';

-- متبرع تبرع قبل 5 أشهر (سيكون متاحاً قريباً)
UPDATE donors 
SET 
    last_donation_date = NOW() - INTERVAL '150 days',
    suspended_until = NOW() + INTERVAL '30 days'
WHERE phone_number = '777222333';

-- ========================================
-- 5. إضافة بلاغات تجريبية (للأدمن)
-- ========================================

-- بلاغ عن رقم لا يعمل
INSERT INTO reports (donor_id, donor_phone_number, reason, notes, status)
SELECT id, phone_number, 'number_not_working', 'الرقم مغلق', 'pending'
FROM donors
WHERE phone_number = '777666777'
LIMIT 1;

-- بلاغ عن رقم خاطئ
INSERT INTO reports (donor_id, donor_phone_number, reason, notes, status)
SELECT id, phone_number, 'wrong_number', 'الرقم غير صحيح', 'pending'
FROM donors
WHERE phone_number = '777888999'
LIMIT 1;

-- ========================================
-- انتهى ملف البيانات التجريبية
-- ========================================

-- للتحقق من نجاح إدراج البيانات:
SELECT 
    blood_type,
    COUNT(*) as count
FROM donors
WHERE is_active = TRUE
GROUP BY blood_type
ORDER BY count DESC;

SELECT 
    district,
    COUNT(*) as count
FROM donors
WHERE is_active = TRUE
GROUP BY district
ORDER BY count DESC;

