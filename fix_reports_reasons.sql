-- ============================================
-- إصلاح أسباب البلاغات
-- ============================================

-- 1. حذف القيد القديم على عمود reason
ALTER TABLE reports DROP CONSTRAINT IF EXISTS reports_reason_check;

-- 2. إضافة قيد جديد يشمل جميع الأسباب
ALTER TABLE reports 
ADD CONSTRAINT reports_reason_check 
CHECK (reason IN (
    'number_not_working',    -- الرقم لا يعمل
    'wrong_number',          -- رقم خاطئ
    'refuses_to_donate',     -- يرفض التبرع
    'number_busy',           -- الرقم مشغول دائماً
    'no_answer',             -- لا يرد على الاتصال
    'deceased',              -- متوفى
    'moved_away',            -- انتقل إلى منطقة أخرى
    'health_issues',         -- مشاكل صحية
    'other'                  -- سبب آخر
));

-- 3. التحقق من النتيجة
SELECT 
    constraint_name, 
    constraint_type,
    check_clause
FROM information_schema.table_constraints tc
LEFT JOIN information_schema.check_constraints cc
    ON tc.constraint_name = cc.constraint_name
WHERE tc.table_name = 'reports'
AND tc.constraint_type = 'CHECK';

