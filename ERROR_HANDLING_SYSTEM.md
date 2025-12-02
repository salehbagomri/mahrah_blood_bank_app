# 🛡️ نظام معالجة الأخطاء الاحترافي - بنك دم المهرة

**التاريخ**: 2 ديسمبر 2025
**الإصدار**: 2.0.0

---

## 📋 المحتويات

1. [نظرة عامة](#نظرة-عامة)
2. [الملفات الجديدة](#الملفات-الجديدة)
3. [الميزات الرئيسية](#الميزات-الرئيسية)
4. [كيفية الاستخدام](#كيفية-الاستخدام)
5. [Firebase Crashlytics](#firebase-crashlytics)
6. [الاختبار](#الاختبار)
7. [الملفات المحدثة](#الملفات-المحدثة)

---

## 🎯 نظرة عامة

تم تطوير **نظام معالجة أخطاء شامل واحترافي** للتطبيق يشمل:

✅ **تحويل جميع الأخطاء التقنية إلى رسائل عربية واضحة**
✅ **معالجة ذكية لانقطاع الإنترنت**
✅ **إعادة محاولة تلقائية للعمليات الفاشلة**
✅ **Timeout للعمليات الطويلة**
✅ **عرض أخطاء جميل واحترافي**
✅ **تتبع الأخطاء في الإنتاج عبر Firebase Crashlytics**

---

## 📁 الملفات الجديدة

### 1. `lib/utils/error_handler.dart`
**المعالج المركزي للأخطاء**

```dart
// تحويل الخطأ لرسالة عربية
String message = ErrorHandler.getArabicMessage(error);

// تحديد نوع الخطأ
ErrorType type = ErrorHandler.getErrorType(error);

// الحصول على أيقونة
IconData icon = ErrorHandler.getErrorIcon(type);

// الحصول على اقتراح حل
String suggestion = ErrorHandler.getSuggestion(type);

// تسجيل الخطأ
ErrorHandler.logError(error, stackTrace);
```

**الميزات:**
- يدعم 9 أنواع من الأخطاء
- رسائل عربية واضحة لكل نوع
- معالجة خاصة لأخطاء Supabase/PostgreSQL
- معالجة أخطاء المصادقة
- معالجة أخطاء الشبكة والـ Timeout

---

### 2. `lib/utils/network_checker.dart`
**فاحص الاتصال بالإنترنت**

```dart
// فحص الاتصال
bool connected = await NetworkChecker().checkConnection();

// فحص سريع
bool connected = await NetworkChecker().quickCheck();

// الاستماع لتغيرات الاتصال
NetworkChecker().connectionStream.listen((isConnected) {
  print('الاتصال: $isConnected');
});

// من BuildContext
bool connected = await context.checkInternetConnection();
```

**الميزات:**
- يحاول 3 خوادم مختلفة (Google DNS, Cloudflare DNS, Google.com)
- Cooldown 3 ثوانٍ لتجنب الفحص المتكرر
- Stream للمراقبة المستمرة

---

### 3. `lib/utils/retry_helper.dart`
**مساعد إعادة المحاولة**

```dart
// إعادة محاولة بسيطة
var result = await RetryHelper.retry(
  () => someOperation(),
  maxRetries: 3,
);

// إعادة محاولة مع timeout
var result = await RetryHelper.retryWithTimeout(
  () => someOperation(),
  timeout: Duration(seconds: 30),
  maxRetries: 2,
);

// إعادة محاولة لأخطاء الشبكة فقط
var result = await RetryHelper.retryOnNetworkError(
  () => someOperation(),
  maxRetries: 3,
);
```

**الميزات:**
- Exponential backoff (1s, 2s, 4s)
- شروط مخصصة للإعادة
- معالجة Timeout

---

### 4. `lib/widgets/error_display_widget.dart`
**عرض الأخطاء بشكل احترافي**

```dart
// عرض في SnackBar
ErrorDisplay.showSnackBar(
  context,
  error,
  onRetry: () => reload(),
);

// عرض في Dialog
await ErrorDisplay.showErrorDialog(
  context,
  error,
  title: 'خطأ',
  onRetry: () => reload(),
);

// عرض في الصفحة (Empty State)
return ErrorDisplay.buildErrorWidget(
  error,
  onRetry: () => reload(),
);
```

**Widgets إضافية:**
- `OfflineBanner` - شريط تنبيه في الأعلى عند انقطاع الإنترنت
- `RetryWidget` - widget لإعادة المحاولة

---

### 5. `lib/utils/firebase_error_logger.dart`
**تسجيل الأخطاء في Firebase**

```dart
// تهيئة Crashlytics
await FirebaseErrorLogger.initialize();

// تسجيل خطأ
await FirebaseErrorLogger.logError(
  error,
  stackTrace,
  reason: 'فشل تحميل البيانات',
  context: {'userId': '123', 'screen': 'home'},
  fatal: false,
);

// تسجيل حدث
await FirebaseErrorLogger.log('تم فتح الشاشة الرئيسية');

// تعيين معلومات المستخدم
await FirebaseErrorLogger.setUserInfo(
  userId: '123',
  email: 'user@example.com',
  name: 'محمد أحمد',
);
```

**الميزات:**
- معطل تلقائياً في وضع التطوير
- مفعّل في الإنتاج
- التقاط أخطاء Flutter التلقائية
- التقاط أخطاء Platform
- معلومات سياق مخصصة

---

## 🌟 الميزات الرئيسية

### 1. معالجة أنواع الأخطاء

| النوع | الرسالة العربية | الأيقونة | اللون |
|------|-----------------|----------|--------|
| `network` | لا يوجد اتصال بالإنترنت | `wifi_off` | برتقالي |
| `timeout` | انتهت مهلة الاتصال | `access_time` | كهرماني |
| `permission` | ليس لديك صلاحية | `lock` | أحمر |
| `duplicate` | البيانات مكررة | `content_copy` | أزرق |
| `notFound` | البيانات غير موجودة | `search_off` | رمادي |
| `authentication` | خطأ في تسجيل الدخول | `person_off` | برتقالي غامق |
| `server` | خطأ من الخادم | `cloud_off` | بنفسجي |
| `validation` | خطأ في البيانات المدخلة | `error_outline` | بني |
| `unknown` | خطأ غير متوقع | `warning` | أحمر غامق |

### 2. معالجة أخطاء PostgreSQL

| الكود | الرسالة |
|------|---------|
| `23505` | البيانات مكررة. هذا السجل موجود بالفعل |
| `23503` | لا يمكن تنفيذ هذا الإجراء بسبب ارتباطات أخرى |
| `42501` | ليس لديك صلاحية لتنفيذ هذا الإجراء |
| `PGRST116` | البيانات المطلوبة غير موجودة |
| `PGRST301` | انتهت جلسة العمل. سجل دخول مجدداً |

### 3. معالجة أخطاء Auth

- `invalid login credentials` → البريد الإلكتروني أو كلمة المرور غير صحيحة
- `email not confirmed` → يجب تأكيد البريد الإلكتروني أولاً
- `user already registered` → هذا البريد الإلكتروني مسجل بالفعل
- `network request failed` → لا يوجد اتصال بالإنترنت
- `jwt` → انتهت جلسة العمل

---

## 🚀 كيفية الاستخدام

### في Providers

```dart
import '../utils/error_handler.dart';

class MyProvider with ChangeNotifier {
  Future<void> loadData() async {
    try {
      final data = await service.getData();
    } catch (e, stackTrace) {
      _errorMessage = ErrorHandler.getArabicMessage(e);
      ErrorHandler.logError(e, stackTrace);
    }
  }
}
```

### في Services

```dart
import '../utils/retry_helper.dart';

class MyService {
  Future<List<Data>> getData() async {
    return RetryHelper.retryWithTimeout(
      () async {
        final response = await client.from('table').select();
        return response.map((json) => Data.fromJson(json)).toList();
      },
      timeout: Duration(seconds: 30),
      maxRetries: 2,
    );
  }
}
```

### في UI

```dart
import '../../widgets/error_display_widget.dart';

// في حالة الخطأ
if (provider.hasError) {
  ErrorDisplay.showSnackBar(
    context,
    provider.errorMessage,
    onRetry: () => provider.loadData(),
  );
}

// أو في الصفحة
if (provider.hasError) {
  return ErrorDisplay.buildErrorWidget(
    provider.errorMessage,
    onRetry: () => provider.loadData(),
  );
}
```

---

## 🔥 Firebase Crashlytics

### ✅ التهيئة مكتملة!

**Firebase Project**: `mahrah-blood-bank`
**Package Name**: `com.bagomri.mahrahbloodbank`

**1. ملفات Firebase المُضافة:**

- ✅ **Android**: `android/app/google-services.json`
- ✅ **iOS**: `ios/Runner/GoogleService-Info.plist`

**2. تكوين Gradle:**

تم تحديث `android/app/build.gradle.kts`:
```kotlin
plugins {
    id("com.google.gms.google-services")
}

android {
    namespace = "com.bagomri.mahrahbloodbank"
    applicationId = "com.bagomri.mahrahbloodbank"
}
```

**3. التهيئة في `main.dart`:**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase
  await Firebase.initializeApp();
  await FirebaseErrorLogger.initialize();

  runApp(MyApp());
}
```

### مراقبة الأخطاء في Firebase Console

1. افتح [Firebase Console](https://console.firebase.google.com)
2. اختر مشروعك
3. اذهب إلى **Crashlytics** من القائمة الجانبية
4. ستجد:
   - **Crash-free users percentage**
   - **Top crashes** (أكثر الأخطاء)
   - **معلومات تفصيلية** لكل خطأ

### تعطيل Crashlytics مؤقتاً

```dart
// في main.dart
await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
```

---

## 🧪 الاختبار

### 1. اختبار معالجة الأخطاء

```dart
// في أي Provider
try {
  throw SocketException('No internet');
} catch (e, stackTrace) {
  ErrorHandler.logError(e, stackTrace);
  // يجب أن يطبع: "لا يوجد اتصال بالإنترنت"
}
```

### 2. اختبار Retry

```dart
int attempts = 0;
final result = await RetryHelper.retry(
  () async {
    attempts++;
    if (attempts < 3) throw Exception('Failed');
    return 'Success';
  },
  maxRetries: 3,
);
// يجب أن ينجح في المحاولة الثالثة
```

### 3. اختبار Firebase Crashlytics

```dart
// اختبار crash تجريبي (في Staging فقط!)
FirebaseErrorLogger.testCrash();
```

### 4. اختبار Network Checker

```dart
// قطع الإنترنت من الجهاز ثم:
bool connected = await NetworkChecker().checkConnection();
print(connected); // يجب أن يطبع: false
```

---

## 📝 الملفات المحدثة

### Providers
- ✅ `lib/providers/donor_provider.dart` - 9 catch blocks
- ✅ `lib/providers/dashboard_provider.dart` - 1 catch block
- ✅ `lib/providers/statistics_provider.dart` - 2 catch blocks
- ✅ `lib/providers/auth_provider.dart` - كان جيداً بالفعل

### Services
- ✅ `lib/services/donor_service.dart` - أضيف timeout + retry لـ `searchDonors()`
- ⚠️ باقي الدوال في Services يمكن تحديثها بنفس الطريقة عند الحاجة

### Main
- ✅ `lib/main.dart` - تهيئة Firebase Crashlytics

### Dependencies
- ✅ `pubspec.yaml` - إضافة `firebase_core` و `firebase_crashlytics`

---

## 📊 الإحصائيات

| البند | العدد |
|------|-------|
| ملفات جديدة | 5 |
| ملفات محدثة | 7+ |
| Providers محسّنة | 4 |
| أنواع أخطاء مدعومة | 9 |
| أكواد PostgreSQL معالجة | 5+ |
| خطوط كود جديدة | ~800 |

---

## ⚡ التحسينات المستقبلية (اختياري)

1. **تحديث باقي Services** لإضافة timeout + retry
2. **إضافة Offline Mode** - حفظ البيانات محلياً عند انقطاع الإنترنت
3. **تحسين Retry Logic** - backoff ذكي بناءً على نوع الخطأ
4. **Analytics** - تتبع أنواع الأخطاء الأكثر حدوثاً
5. **User Feedback** - السماح للمستخدم بإرسال تقرير الخطأ

---

## 🎉 الخلاصة

تم بناء **نظام معالجة أخطاء احترافي ومتكامل** يشمل:

✅ معالجة ذكية لجميع أنواع الأخطاء
✅ رسائل عربية واضحة للمستخدم
✅ إعادة محاولة تلقائية
✅ معالجة Timeout
✅ UI جميل لعرض الأخطاء
✅ تتبع الأخطاء في الإنتاج عبر Firebase

**النتيجة**: تطبيق **احترافي ومتكامل** بتجربة مستخدم ممتازة حتى في حالات الأخطاء! 🚀

---

💙 **صُنع بحب لأهالي المهرة**
بواسطة **Saleh Bagomri** - [www.bagomri.com](https://www.bagomri.com)
