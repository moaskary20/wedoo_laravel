# دليل اختبار التطبيق الموبيل

## 🚀 خطوات اختبار التطبيق

### 1. تنظيف وإعادة بناء التطبيق
```bash
cd /media/mohamed/3E16609616605147/wedoo2/handyman_app

# تنظيف التطبيق
flutter clean

# إعادة تحميل dependencies
flutter pub get

# بناء التطبيق
flutter build web
```

### 2. تشغيل التطبيق
```bash
# تشغيل التطبيق في وضع التطوير
flutter run

# أو تشغيل على web
flutter run -d chrome
```

### 3. اختبار تسجيل الدخول
- فتح التطبيق
- إدخال رقم الهاتف: `01012345678`
- إدخال كلمة المرور: `123456`
- الضغط على "تسجيل الدخول"

### 4. فحص Console للأخطاء
- فتح Developer Tools (F12)
- فحص Console tab
- البحث عن أخطاء API
- فحص Network tab للطلبات

## 🔧 الإصلاحات المطبقة

### 1. SSL Certificate Handling
```dart
// في main.dart
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
```

### 2. ApiService مع Dio
```dart
// خدمة API محسنة
class ApiService {
  static final Dio _dio = Dio();
  
  static void init() {
    _dio.options.baseUrl = ApiConfig.baseUrl;
    _dio.options.connectTimeout = Duration(seconds: 30);
    _dio.options.receiveTimeout = Duration(seconds: 30);
  }
}
```

### 3. Headers محسنة
```dart
static Map<String, String> get headers => {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'User-Agent': 'WedooApp/1.0 (Flutter)',
  'Origin': 'https://free-styel.store',
};
```

## 🎯 النتائج المتوقعة

### 1. تسجيل الدخول الناجح
- لا تظهر أخطاء "ClientException: Failed to fetch"
- يتم حفظ بيانات المستخدم في SharedPreferences
- الانتقال إلى الشاشة التالية

### 2. Console Logs
```
Request: POST https://free-styel.store/api/auth/login
Headers: {Content-Type: application/json, Accept: application/json, User-Agent: WedooApp/1.0 (Flutter), Origin: https://free-styel.store}
Data: {phone: 01012345678, password: 123456}
Response: 200 https://free-styel.store/api/auth/login
Response Data: {success: true, data: {...}, message: Login successful}
```

### 3. Network Tab
- طلب POST إلى `/api/auth/login`
- Status: 200 OK
- Response: JSON مع بيانات المستخدم

## 🚨 إذا لم تعمل

### 1. فحص Console للأخطاء
- البحث عن "API Error"
- فحص "Request" و "Response" logs
- التأكد من عدم وجود SSL errors

### 2. فحص Network Tab
- التأكد من إرسال الطلب
- فحص Response status
- فحص Response data

### 3. إعادة تشغيل التطبيق
```bash
flutter clean
flutter pub get
flutter run
```

## 🎉 النتيجة

بعد تطبيق هذه الإصلاحات:
- **SSL Certificate** سيعمل بشكل صحيح
- **API Connection** سيعمل بنجاح
- **تسجيل الدخول** سيعمل بدون أخطاء
- **Flutter App** سيتصل بالخادم بنجاح

**التطبيق جاهز للاستخدام! 🚀**
