# دليل النشر والإطلاق

## 🚀 نشر تطبيق بنك دم محافظة المهرة

---

## 📋 قبل البدء

تأكد من:
- ✅ اختبار التطبيق بشكل كامل
- ✅ تحديث قاعدة البيانات في Production
- ✅ إعداد Supabase Production Environment
- ✅ تجهيز الأيقونات والشعارات
- ✅ مراجعة الأمان والصلاحيات

---

## 🗄️ 1. إعداد Supabase للإنتاج

### الخطوة 1: إنشاء مشروع إنتاج

1. أنشئ مشروع Supabase منفصل للإنتاج
2. اختر Region قريب من المستخدمين (مثل Europe West)
3. استخدم كلمة مرور قوية جداً

### الخطوة 2: تنفيذ Schema

```sql
-- نفّذ ملف supabase_schema.sql كاملاً
-- لا تنفذ sample_data.sql في الإنتاج!
```

### الخطوة 3: Backup Plan

```sql
-- قم بإعداد backups تلقائية
-- في Supabase Dashboard > Settings > Backups
-- اختر Daily Backups (في الخطة المدفوعة)
```

### الخطوة 4: تكوين البيئة

```dart
// استخدم environment variables
// أو أنشئ ملف config منفصل للإنتاج
```

---

## 📱 2. نشر على Android

### الخطوة 1: تحديث معلومات التطبيق

#### android/app/build.gradle
```gradle
android {
    defaultConfig {
        applicationId "com.mahrah.blood_bank"
        minSdkVersion 21
        targetSdkVersion 33
        versionCode 1
        versionName "1.0.0"
    }
}
```

#### android/app/src/main/AndroidManifest.xml
```xml
<manifest>
    <application
        android:label="بنك دم المهرة"
        android:icon="@mipmap/ic_launcher">
    </application>
</manifest>
```

### الخطوة 2: إنشاء Keystore

```bash
keytool -genkey -v -keystore ~/mahrah-blood-bank.jks -keyalg RSA -keysize 2048 -validity 10000 -alias mahrah-blood-bank
```

#### android/key.properties
```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=mahrah-blood-bank
storeFile=path/to/mahrah-blood-bank.jks
```

### الخطوة 3: تحديث build.gradle

```gradle
// في android/app/build.gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### الخطوة 4: بناء APK/AAB

```bash
# بناء APK
flutter build apk --release

# بناء App Bundle (مفضل لـ Google Play)
flutter build appbundle --release

# الملفات الناتجة:
# APK: build/app/outputs/flutter-apk/app-release.apk
# AAB: build/app/outputs/bundle/release/app-release.aab
```

### الخطوة 5: رفع على Google Play Console

1. اذهب إلى [Google Play Console](https://play.google.com/console)
2. أنشئ تطبيق جديد
3. املأ معلومات التطبيق
4. ارفع AAB file
5. املأ:
   - وصف التطبيق
   - لقطات الشاشة
   - أيقونة التطبيق
   - سياسة الخصوصية
6. اختر "Internal Testing" أولاً
7. بعد الاختبار، انقل إلى "Production"

---

## 🍎 3. نشر على iOS

### الخطوة 1: تحديث معلومات التطبيق

#### ios/Runner/Info.plist
```xml
<key>CFBundleName</key>
<string>بنك دم المهرة</string>
<key>CFBundleDisplayName</key>
<string>بنك دم المهرة</string>
```

### الخطوة 2: إعداد Xcode

1. افتح `ios/Runner.xcworkspace` في Xcode
2. اختر Team في Signing & Capabilities
3. تأكد من Bundle Identifier: `com.mahrah.bloodBank`

### الخطوة 3: بناء IPA

```bash
# تأكد من أن لديك Apple Developer Account
flutter build ios --release

# أو استخدم Xcode:
# Product > Archive > Distribute App
```

### الخطوة 4: رفع على App Store

1. اذهب إلى [App Store Connect](https://appstoreconnect.apple.com/)
2. أنشئ تطبيق جديد
3. املأ معلومات التطبيق
4. استخدم Xcode لرفع IPA
5. اختر "TestFlight" للاختبار أولاً
6. بعد الاختبار، أرسل للمراجعة

---

## 🌐 4. نشر على الويب

### الخطوة 1: بناء للويب

```bash
flutter build web --release
```

### الخطوة 2: نشر على Firebase Hosting

```bash
# تثبيت Firebase CLI
npm install -g firebase-tools

# تسجيل الدخول
firebase login

# تهيئة المشروع
firebase init hosting

# النشر
firebase deploy --only hosting
```

### الخطوة 3: نشر على Vercel

```bash
# تثبيت Vercel CLI
npm install -g vercel

# النشر
cd build/web
vercel
```

---

## ⚙️ 5. تكوينات الإنتاج

### أمان Supabase

```sql
-- تأكد من تفعيل جميع RLS Policies
-- راجع جميع الصلاحيات
-- استخدم Environment Variables للمفاتيح
```

### تحسين الأداء

```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/images/
  
  # تفعيل Tree Shaking
  # استخدام --split-debug-info
```

```bash
# بناء مُحسّن
flutter build apk --release --split-debug-info=debug-info --obfuscate
```

### مراقبة الأخطاء

يمكنك إضافة:
- Firebase Crashlytics
- Sentry
- أو أي أداة مراقبة أخرى

---

## 📊 6. التحليلات والمراقبة

### Supabase Analytics

- راقب عدد الطلبات
- راقب استخدام قاعدة البيانات
- راقب الأخطاء في Logs

### Google Analytics (اختياري)

```yaml
dependencies:
  firebase_analytics: ^10.0.0
```

---

## 🔄 7. التحديثات المستقبلية

### رفع إصدار جديد

1. حدّث `version` في `pubspec.yaml`:
```yaml
version: 1.1.0+2  # versionName+versionCode
```

2. بناء إصدار جديد:
```bash
flutter build appbundle --release
```

3. رفع على Google Play Console

### استراتيجية التحديث

- **Major Update (2.0.0)**: تغييرات كبيرة
- **Minor Update (1.1.0)**: ميزات جديدة
- **Patch Update (1.0.1)**: إصلاحات

---

## 🔒 8. الأمان

### قبل النشر

- ✅ لا تُضمّن أي مفاتيح سرية في الكود
- ✅ استخدم Environment Variables
- ✅ راجع جميع RLS Policies
- ✅ اختبر جميع المسارات الأمنية
- ✅ فعّل HTTPS فقط
- ✅ راجع صلاحيات التطبيق

---

## 📝 9. الوثائق المطلوبة

### لـ Google Play

- سياسة الخصوصية (Privacy Policy)
- شروط الاستخدام (Terms of Service)
- وصف التطبيق (بالعربية والإنجليزية)
- لقطات شاشة (8 على الأقل)
- أيقونة عالية الدقة (512x512)

### لـ App Store

- نفس المتطلبات أعلاه
- Preview Videos (اختياري)

---

## ✅ قائمة فحص ما قبل النشر

- [ ] اختبار شامل للتطبيق
- [ ] مراجعة الأمان
- [ ] تحديث Supabase للإنتاج
- [ ] بناء APK/AAB/IPA
- [ ] اختبار التطبيق المبني
- [ ] تجهيز الوثائق
- [ ] رفع على Store
- [ ] اختبار Beta
- [ ] إطلاق Production

---

## 🆘 الدعم والصيانة

### المراقبة المستمرة

- راقب Supabase Dashboard يومياً
- راجع تقييمات المستخدمين
- راقب الأخطاء والـ Crashes
- حدّث قاعدة البيانات عند الحاجة

### Backup استراتيجية

- Backup يومي لقاعدة البيانات
- حفظ نسخ من الكود في أماكن متعددة
- توثيق جميع التغييرات

---

**🎉 مبروك! تطبيقك الآن جاهز للإطلاق!**

التبرع بالدم ينقذ الأرواح 🩸

