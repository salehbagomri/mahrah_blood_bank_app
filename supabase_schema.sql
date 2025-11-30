-- بنك دم محافظة المهرة - Supabase Database Schema
-- يجب تنفيذ هذا السكريبت في Supabase SQL Editor

-- ========================================
-- 1. إنشاء الجداول (Tables)
-- ========================================

-- جدول المتبرعين
CREATE TABLE IF NOT EXISTS donors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20) NOT NULL UNIQUE,
    blood_type VARCHAR(5) NOT NULL CHECK (blood_type IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')),
    district VARCHAR(50) NOT NULL CHECK (district IN ('الغيضة', 'سيحوت', 'حصوين', 'قشن', 'حات', 'حوف', 'الحصن', 'المسيلة', 'شحن')),
    age INTEGER NOT NULL CHECK (age >= 18 AND age <= 65),
    gender VARCHAR(10) NOT NULL CHECK (gender IN ('male', 'female')),
    notes TEXT,
    is_available BOOLEAN DEFAULT TRUE,
    last_donation_date TIMESTAMP WITH TIME ZONE,
    suspended_until TIMESTAMP WITH TIME ZONE,
    added_by UUID REFERENCES auth.users(id),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- جدول المستشفيات
CREATE TABLE IF NOT EXISTS hospitals (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    district VARCHAR(50) NOT NULL CHECK (district IN ('الغيضة', 'سيحوت', 'حصوين', 'قشن', 'حات', 'حوف', 'الحصن', 'المسيلة', 'شحن')),
    phone_number VARCHAR(20),
    address TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- جدول البلاغات
CREATE TABLE IF NOT EXISTS reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    donor_id UUID NOT NULL REFERENCES donors(id) ON DELETE CASCADE,
    donor_phone_number VARCHAR(20) NOT NULL,
    reason VARCHAR(50) NOT NULL CHECK (reason IN ('number_not_working', 'wrong_number', 'refuses_to_donate', 'other')),
    notes TEXT,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    reviewed_by UUID REFERENCES auth.users(id),
    reviewed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- جدول الأدمن
CREATE TABLE IF NOT EXISTS admins (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- جدول السجلات (اختياري - لتتبع العمليات)
CREATE TABLE IF NOT EXISTS logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id),
    action VARCHAR(100) NOT NULL,
    table_name VARCHAR(50),
    record_id UUID,
    details JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ========================================
-- 2. إنشاء الفهارس (Indexes) لتحسين الأداء
-- ========================================

-- فهارس جدول المتبرعين
CREATE INDEX IF NOT EXISTS idx_donors_blood_type ON donors(blood_type);
CREATE INDEX IF NOT EXISTS idx_donors_district ON donors(district);
CREATE INDEX IF NOT EXISTS idx_donors_is_available ON donors(is_available);
CREATE INDEX IF NOT EXISTS idx_donors_is_active ON donors(is_active);
CREATE INDEX IF NOT EXISTS idx_donors_phone_number ON donors(phone_number);
CREATE INDEX IF NOT EXISTS idx_donors_created_at ON donors(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_donors_suspended_until ON donors(suspended_until);

-- فهارس جدول البلاغات
CREATE INDEX IF NOT EXISTS idx_reports_donor_id ON reports(donor_id);
CREATE INDEX IF NOT EXISTS idx_reports_status ON reports(status);
CREATE INDEX IF NOT EXISTS idx_reports_created_at ON reports(created_at DESC);

-- فهارس جدول المستشفيات
CREATE INDEX IF NOT EXISTS idx_hospitals_district ON hospitals(district);
CREATE INDEX IF NOT EXISTS idx_hospitals_is_active ON hospitals(is_active);

-- ========================================
-- 3. إنشاء الوظائف (Functions)
-- ========================================

-- دالة لتحديث updated_at تلقائياً
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- دالة للحصول على الإحصائيات العامة
CREATE OR REPLACE FUNCTION get_statistics()
RETURNS JSON AS $$
DECLARE
    result JSON;
BEGIN
    SELECT json_build_object(
        'total_donors', (SELECT COUNT(*) FROM donors WHERE is_active = TRUE),
        'most_common_blood_type', (
            SELECT blood_type 
            FROM donors 
            WHERE is_active = TRUE 
            GROUP BY blood_type 
            ORDER BY COUNT(*) DESC 
            LIMIT 1
        ),
        'most_common_blood_type_count', (
            SELECT COUNT(*) 
            FROM donors 
            WHERE is_active = TRUE 
            GROUP BY blood_type 
            ORDER BY COUNT(*) DESC 
            LIMIT 1
        ),
        'most_active_district', (
            SELECT district 
            FROM donors 
            WHERE is_active = TRUE 
            GROUP BY district 
            ORDER BY COUNT(*) DESC 
            LIMIT 1
        ),
        'most_active_district_count', (
            SELECT COUNT(*) 
            FROM donors 
            WHERE is_active = TRUE 
            GROUP BY district 
            ORDER BY COUNT(*) DESC 
            LIMIT 1
        ),
        'latest_donor_name', (
            SELECT name 
            FROM donors 
            WHERE is_active = TRUE 
            ORDER BY created_at DESC 
            LIMIT 1
        ),
        'latest_donor_date', (
            SELECT created_at 
            FROM donors 
            WHERE is_active = TRUE 
            ORDER BY created_at DESC 
            LIMIT 1
        ),
        'blood_type_distribution', (
            SELECT json_object_agg(blood_type, count) 
            FROM (
                SELECT blood_type, COUNT(*)::int as count 
                FROM donors 
                WHERE is_active = TRUE 
                GROUP BY blood_type
            ) as dist
        ),
        'district_distribution', (
            SELECT json_object_agg(district, count) 
            FROM (
                SELECT district, COUNT(*)::int as count 
                FROM donors 
                WHERE is_active = TRUE 
                GROUP BY district
            ) as dist
        ),
        'last_updated', NOW()
    ) INTO result;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- دالة للبحث المتقدم عن المتبرعين
CREATE OR REPLACE FUNCTION search_donors(
    p_blood_type VARCHAR DEFAULT NULL,
    p_district VARCHAR DEFAULT NULL,
    p_available_only BOOLEAN DEFAULT TRUE
)
RETURNS SETOF donors AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM donors
    WHERE 
        is_active = TRUE
        AND (NOT p_available_only OR is_available = TRUE)
        AND (p_blood_type IS NULL OR blood_type = p_blood_type)
        AND (p_district IS NULL OR district = p_district)
        AND (suspended_until IS NULL OR suspended_until < NOW())
        AND (
            last_donation_date IS NULL 
            OR last_donation_date < NOW() - INTERVAL '180 days'
        )
    ORDER BY 
        CASE 
            WHEN blood_type = p_blood_type AND district = p_district THEN 1
            WHEN blood_type = p_blood_type THEN 2
            ELSE 3
        END,
        created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- 4. إنشاء المشغلات (Triggers)
-- ========================================

-- مشغل لتحديث updated_at في جدول donors
DROP TRIGGER IF EXISTS update_donors_updated_at ON donors;
CREATE TRIGGER update_donors_updated_at
    BEFORE UPDATE ON donors
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- مشغل لتحديث updated_at في جدول hospitals
DROP TRIGGER IF EXISTS update_hospitals_updated_at ON hospitals;
CREATE TRIGGER update_hospitals_updated_at
    BEFORE UPDATE ON hospitals
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- مشغل لتحديث updated_at في جدول admins
DROP TRIGGER IF EXISTS update_admins_updated_at ON admins;
CREATE TRIGGER update_admins_updated_at
    BEFORE UPDATE ON admins
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- 5. سياسات الأمان (Row Level Security - RLS)
-- ========================================

-- تفعيل RLS على جميع الجداول
ALTER TABLE donors ENABLE ROW LEVEL SECURITY;
ALTER TABLE hospitals ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE admins ENABLE ROW LEVEL SECURITY;
ALTER TABLE logs ENABLE ROW LEVEL SECURITY;

-- ========================================
-- سياسات جدول المتبرعين (donors)
-- ========================================

-- الجميع يمكنهم قراءة المتبرعين النشطين والمتاحين
CREATE POLICY "Anyone can view active available donors"
    ON donors FOR SELECT
    USING (is_active = TRUE AND is_available = TRUE);

-- الجميع يمكنهم إضافة متبرع جديد
CREATE POLICY "Anyone can insert donors"
    ON donors FOR INSERT
    WITH CHECK (TRUE);

-- المستشفيات يمكنهم تحديث المتبرعين
CREATE POLICY "Hospitals can update donors"
    ON donors FOR UPDATE
    USING (
        auth.uid() IN (SELECT id FROM hospitals WHERE is_active = TRUE)
        OR auth.uid() IN (SELECT id FROM admins WHERE is_active = TRUE)
    );

-- الأدمن فقط يمكنهم حذف المتبرعين
CREATE POLICY "Only admins can delete donors"
    ON donors FOR DELETE
    USING (
        auth.uid() IN (SELECT id FROM admins WHERE is_active = TRUE)
    );

-- ========================================
-- سياسات جدول المستشفيات (hospitals)
-- ========================================

-- الأدمن فقط يمكنهم قراءة المستشفيات
CREATE POLICY "Only admins can view hospitals"
    ON hospitals FOR SELECT
    USING (
        auth.uid() IN (SELECT id FROM admins WHERE is_active = TRUE)
    );

-- الأدمن فقط يمكنهم إضافة مستشفيات
CREATE POLICY "Only admins can insert hospitals"
    ON hospitals FOR INSERT
    WITH CHECK (
        auth.uid() IN (SELECT id FROM admins WHERE is_active = TRUE)
    );

-- الأدمن فقط يمكنهم تحديث المستشفيات
CREATE POLICY "Only admins can update hospitals"
    ON hospitals FOR UPDATE
    USING (
        auth.uid() IN (SELECT id FROM admins WHERE is_active = TRUE)
    );

-- الأدمن فقط يمكنهم حذف المستشفيات
CREATE POLICY "Only admins can delete hospitals"
    ON hospitals FOR DELETE
    USING (
        auth.uid() IN (SELECT id FROM admins WHERE is_active = TRUE)
    );

-- ========================================
-- سياسات جدول البلاغات (reports)
-- ========================================

-- الجميع يمكنهم إضافة بلاغ
CREATE POLICY "Anyone can insert reports"
    ON reports FOR INSERT
    WITH CHECK (TRUE);

-- الأدمن فقط يمكنهم قراءة البلاغات
CREATE POLICY "Only admins can view reports"
    ON reports FOR SELECT
    USING (
        auth.uid() IN (SELECT id FROM admins WHERE is_active = TRUE)
    );

-- الأدمن فقط يمكنهم تحديث البلاغات
CREATE POLICY "Only admins can update reports"
    ON reports FOR UPDATE
    USING (
        auth.uid() IN (SELECT id FROM admins WHERE is_active = TRUE)
    );

-- ========================================
-- سياسات جدول الأدمن (admins)
-- ========================================

-- الأدمن فقط يمكنهم قراءة الأدمن
CREATE POLICY "Only admins can view admins"
    ON admins FOR SELECT
    USING (
        auth.uid() IN (SELECT id FROM admins WHERE is_active = TRUE)
    );

-- الأدمن فقط يمكنهم إضافة أدمن جديد
CREATE POLICY "Only admins can insert admins"
    ON admins FOR INSERT
    WITH CHECK (
        auth.uid() IN (SELECT id FROM admins WHERE is_active = TRUE)
    );

-- الأدمن فقط يمكنهم تحديث الأدمن
CREATE POLICY "Only admins can update admins"
    ON admins FOR UPDATE
    USING (
        auth.uid() IN (SELECT id FROM admins WHERE is_active = TRUE)
    );

-- ========================================
-- سياسات جدول السجلات (logs)
-- ========================================

-- الأدمن فقط يمكنهم قراءة السجلات
CREATE POLICY "Only admins can view logs"
    ON logs FOR SELECT
    USING (
        auth.uid() IN (SELECT id FROM admins WHERE is_active = TRUE)
    );

-- الجميع يمكنهم إضافة سجل (تلقائياً)
CREATE POLICY "Anyone can insert logs"
    ON logs FOR INSERT
    WITH CHECK (TRUE);

-- ========================================
-- 6. إنشاء Views للاستعلامات الشائعة
-- ========================================

-- View للمتبرعين المتاحين فقط
CREATE OR REPLACE VIEW available_donors AS
SELECT 
    id, name, phone_number, blood_type, district, 
    age, gender, notes, created_at
FROM donors
WHERE 
    is_active = TRUE 
    AND is_available = TRUE
    AND (suspended_until IS NULL OR suspended_until < NOW())
    AND (last_donation_date IS NULL OR last_donation_date < NOW() - INTERVAL '180 days');

-- View للإحصائيات السريعة
CREATE OR REPLACE VIEW quick_statistics AS
SELECT 
    COUNT(*) as total_donors,
    COUNT(CASE WHEN blood_type = 'A+' THEN 1 END) as blood_type_a_plus,
    COUNT(CASE WHEN blood_type = 'A-' THEN 1 END) as blood_type_a_minus,
    COUNT(CASE WHEN blood_type = 'B+' THEN 1 END) as blood_type_b_plus,
    COUNT(CASE WHEN blood_type = 'B-' THEN 1 END) as blood_type_b_minus,
    COUNT(CASE WHEN blood_type = 'AB+' THEN 1 END) as blood_type_ab_plus,
    COUNT(CASE WHEN blood_type = 'AB-' THEN 1 END) as blood_type_ab_minus,
    COUNT(CASE WHEN blood_type = 'O+' THEN 1 END) as blood_type_o_plus,
    COUNT(CASE WHEN blood_type = 'O-' THEN 1 END) as blood_type_o_minus
FROM donors
WHERE is_active = TRUE;

-- ========================================
-- 7. بيانات تجريبية (اختياري)
-- ========================================

-- يمكن إضافة بيانات تجريبية للاختبار
-- INSERT INTO donors (name, phone_number, blood_type, district, age, gender, notes)
-- VALUES 
--     ('أحمد محمد', '777123456', 'A+', 'الغيضة', 25, 'male', 'متبرع دائم'),
--     ('فاطمة علي', '777234567', 'B+', 'سيحوت', 30, 'female', NULL),
--     ('خالد سعيد', '777345678', 'O+', 'حصوين', 28, 'male', 'متاح دائماً');

-- ========================================
-- ملاحظات مهمة:
-- ========================================
-- 1. يجب إنشاء أول admin يدوياً عبر Supabase Dashboard
-- 2. يجب تفعيل Email Auth في Supabase للمستشفيات والأدمن
-- 3. يمكن إضافة المزيد من السياسات حسب الحاجة
-- 4. يُنصح بعمل backup دوري لقاعدة البيانات
-- 5. يمكن إضافة المزيد من الفهارس بناءً على استخدام التطبيق

