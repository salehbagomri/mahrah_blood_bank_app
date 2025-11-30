# دليل الخطوط - بنك دم محافظة المهرة

## 🔤 الخط المستخدم

### IBM Plex Sans Arabic
- **الخط الأساسي**: IBM Plex Sans Arabic
- **المصدر**: Google Fonts
- **الترخيص**: Open Font License (مجاني للاستخدام)
- **الدعم**: كامل للغة العربية مع جميع الحركات والتشكيل

---

## 📦 التثبيت

### في `pubspec.yaml`

```yaml
dependencies:
  google_fonts: ^6.3.2
```

تم تثبيت الحزمة بالفعل في المشروع.

---

## 🎨 كيفية الاستخدام

### 1. في ThemeData (الطريقة الموصى بها)

```dart
import 'package:google_fonts/google_fonts.dart';

ThemeData(
  textTheme: GoogleFonts.ibmPlexSansArabicTextTheme(
    ThemeData.light().textTheme,
  ),
)
```

هذه الطريقة تطبق الخط على جميع النصوص في التطبيق تلقائياً.

### 2. في TextStyle مباشرة

```dart
Text(
  'مرحباً بك',
  style: GoogleFonts.ibmPlexSansArabic(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.blue,
  ),
)
```

### 3. باستخدام Theme

```dart
Text(
  'مرحباً بك',
  style: Theme.of(context).textTheme.headlineLarge,
)
```

يستخدم الخط المعرف في ThemeData تلقائياً.

---

## ⚙️ الإعداد في المشروع

### في `lib/constants/app_theme.dart`

تم تطبيق IBM Plex Sans Arabic على جميع أنماط النصوص:

```dart
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      // الخطوط
      textTheme: GoogleFonts.ibmPlexSansArabicTextTheme(
        ThemeData.light().textTheme,
      ).copyWith(
        displayLarge: GoogleFonts.ibmPlexSansArabic(...),
        displayMedium: GoogleFonts.ibmPlexSansArabic(...),
        // ... جميع الأنماط الأخرى
      ),
      
      // AppBar
      appBarTheme: AppBarTheme(
        titleTextStyle: GoogleFonts.ibmPlexSansArabic(...),
      ),
      
      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: GoogleFonts.ibmPlexSansArabic(...),
        ),
      ),
      // ... بقية الأنماط
    );
  }
}
```

---

## 📝 أنماط النصوص المتاحة

### العناوين الكبيرة (Display)
- **displayLarge**: 32px, Bold
- **displayMedium**: 28px, Bold
- **displaySmall**: 24px, Bold

### العناوين المتوسطة (Headline)
- **headlineLarge**: 22px, SemiBold (600)
- **headlineMedium**: 20px, SemiBold (600)
- **headlineSmall**: 18px, SemiBold (600)

### العناوين الصغيرة (Title)
- **titleLarge**: 18px, SemiBold (600)
- **titleMedium**: 16px, SemiBold (600)
- **titleSmall**: 14px, SemiBold (600)

### النصوص العادية (Body)
- **bodyLarge**: 16px, Normal (400)
- **bodyMedium**: 14px, Normal (400)
- **bodySmall**: 12px, Normal (400)

### التسميات (Label)
- **labelLarge**: 16px, SemiBold (600)
- **labelMedium**: 14px, Medium (500)
- **labelSmall**: 12px, Medium (500)

---

## 🎯 أمثلة الاستخدام

### مثال 1: عنوان رئيسي

```dart
Text(
  'بنك دم محافظة المهرة',
  style: Theme.of(context).textTheme.displayLarge,
)
```

### مثال 2: نص عادي

```dart
Text(
  'مرحباً بك في التطبيق',
  style: Theme.of(context).textTheme.bodyMedium,
)
```

### مثال 3: نص مخصص

```dart
Text(
  'نص مخصص',
  style: GoogleFonts.ibmPlexSansArabic(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    letterSpacing: 0.5,
  ),
)
```

### مثال 4: نص مع تأثيرات

```dart
Text(
  'نص مميز',
  style: GoogleFonts.ibmPlexSansArabic(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    decoration: TextDecoration.underline,
    decorationColor: AppColors.primary,
    decorationThickness: 2,
  ),
)
```

---

## 🔧 Font Variations

IBM Plex Sans Arabic يدعم أوزان الخطوط التالية:

- **100** - Thin
- **200** - Extra Light
- **300** - Light
- **400** - Regular (Normal)
- **500** - Medium
- **600** - Semi Bold
- **700** - Bold

### استخدام Font Variations

```dart
import 'dart:ui';

TextStyle(
  fontFamily: 'IBM Plex Sans Arabic',
  fontSize: 18,
  fontVariations: [
    FontVariation('wght', 400), // Regular
  ],
)
```

لكن باستخدام Google Fonts، يمكنك ببساطة:

```dart
GoogleFonts.ibmPlexSansArabic(
  fontWeight: FontWeight.w400, // Regular
)
```

---

## 📱 الأداء والتحسين

### التخزين المؤقت (Caching)

Google Fonts تقوم تلقائياً بـ:
- ✅ تحميل الخطوط من الإنترنت في المرة الأولى
- ✅ حفظها محلياً (Cache) للاستخدام في المرات القادمة
- ✅ تحسين الأداء تلقائياً

### Pre-caching (اختياري)

لتحميل الخط مسبقاً عند بدء التطبيق:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Pre-cache font
  await GoogleFonts.pendingFonts([
    GoogleFonts.ibmPlexSansArabic(),
  ]);
  
  runApp(MyApp());
}
```

---

## 🌐 البدائل الاحتياطية (Fallback Fonts)

في حالة فشل تحميل الخط من Google Fonts، سيستخدم النظام:
- **Android**: Roboto
- **iOS**: San Francisco
- **Windows**: Segoe UI

لكن جميع هذه الخطوط تدعم العربية بشكل أساسي.

---

## 🎨 أمثلة من التطبيق

### في AppBar

```dart
AppBar(
  title: Text(
    AppStrings.appName,
    style: GoogleFonts.ibmPlexSansArabic(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
)
```

### في Buttons

```dart
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    textStyle: GoogleFonts.ibmPlexSansArabic(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  ),
  child: Text('اضغط هنا'),
)
```

### في Input Fields

```dart
TextField(
  decoration: InputDecoration(
    labelText: 'الاسم',
    labelStyle: GoogleFonts.ibmPlexSansArabic(
      fontSize: 14,
      color: AppColors.textSecondary,
    ),
    hintStyle: GoogleFonts.ibmPlexSansArabic(
      fontSize: 14,
      color: AppColors.textHint,
    ),
  ),
  style: GoogleFonts.ibmPlexSansArabic(
    fontSize: 16,
  ),
)
```

---

## 🔍 مشاكل شائعة وحلولها

### مشكلة 1: الخط لا يظهر بشكل صحيح

**الحل**:
```dart
// تأكد من استيراد google_fonts
import 'package:google_fonts/google_fonts.dart';

// تأكد من أن الإنترنت متصل في المرة الأولى
// أو استخدم Pre-caching
```

### مشكلة 2: الخط يبدو مختلفاً في أماكن مختلفة

**الحل**:
```dart
// استخدم نفس fontWeight في جميع الأماكن
GoogleFonts.ibmPlexSansArabic(
  fontWeight: FontWeight.w400, // استخدم القيم المدعومة
)
```

### مشكلة 3: الخط بطيء في التحميل

**الحل**:
```dart
// استخدم Pre-caching في main.dart
// أو انتظر حتى يتم الحفظ في Cache
```

---

## 📊 مقارنة مع خطوط أخرى

| الخط | دعم العربية | الحجم | الأداء | التوافق |
|------|------------|-------|--------|---------|
| IBM Plex Sans Arabic | ممتاز | متوسط | ممتاز | عالي |
| Cairo | ممتاز | كبير | جيد | عالي |
| Tajawal | جيد جداً | صغير | ممتاز | عالي |
| Noto Sans Arabic | ممتاز | كبير | جيد | عالي |

**لماذا IBM Plex Sans Arabic؟**
- ✅ قراءة ممتازة على الشاشات
- ✅ دعم كامل للعربية
- ✅ أوزان متعددة (100-700)
- ✅ تصميم احترافي
- ✅ مجاني ومفتوح المصدر

---

## 📄 الترخيص

**IBM Plex Sans Arabic** مرخص تحت:
- **Open Font License (OFL)**
- الاستخدام مجاني للمشاريع الشخصية والتجارية
- يمكن التعديل وإعادة التوزيع

---

## 🔗 مصادر إضافية

- [Google Fonts - IBM Plex Sans Arabic](https://fonts.google.com/specimen/IBM+Plex+Sans+Arabic)
- [Google Fonts Flutter Package](https://pub.dev/packages/google_fonts)
- [IBM Plex GitHub](https://github.com/IBM/plex)

---

**آخر تحديث**: نوفمبر 2025  
**الإصدار**: 1.0.0

