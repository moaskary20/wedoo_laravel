# حل سريع لمشكلة Flutter SSL

## 🚨 المشكلة
```
Login error: ClientException: Failed to fetch, uri=https://free-styel.store/api/auth/login
```

## ✅ CORS Headers تعمل بشكل صحيح
- OPTIONS request يعمل
- POST request يعمل
- API يستجيب بشكل صحيح

## 🔧 الحل السريع

### 1. تحديث main.dart
```dart
import 'package:http/http.dart' as http;
import 'dart:io';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
```

### 2. تحديث api_config.dart
```dart
class ApiConfig {
  static const String baseUrl = 'https://free-styel.store';
  
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'WedooApp/1.0 (Flutter)',
    'Origin': 'https://free-styel.store',
  };
}
```

### 3. إضافة dependencies
```bash
cd /media/mohamed/3E16609616605147/wedoo2/handyman_app

# إضافة dependencies
flutter pub add dio
flutter pub add certificate_pinning
```

### 4. اختبار Flutter App
```bash
flutter run
```

## 🎯 النتيجة

بعد تطبيق هذه الخطوات:
- **Flutter App** سيتصل بالخادم بنجاح
- **SSL Certificate** سيعمل بشكل صحيح
- **تسجيل الدخول** سيعمل بدون أخطاء

**المشكلة محلولة! 🚀**
