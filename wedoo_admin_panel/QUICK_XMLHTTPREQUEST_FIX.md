# حل سريع لمشكلة XMLHttpRequest

## 🚨 المشكلة
```
Error: The connection errored: The XMLHttpRequest onError callback was called.
```

## 🔧 الحل السريع

### 1. إضافة dio_web_adapter
```bash
cd /media/mohamed/3E16609616605147/wedoo2/handyman_app

# إضافة web adapter
flutter pub add dio_web_adapter

# تنظيف وإعادة بناء
flutter clean
flutter pub get
```

### 2. تحديث ApiService
```dart
// في services/api_service.dart
import 'package:dio_web_adapter/dio_web_adapter.dart';
import 'package:flutter/foundation.dart';

static void init() {
  _dio.options.baseUrl = ApiConfig.baseUrl;
  _dio.options.connectTimeout = Duration(seconds: 30);
  _dio.options.receiveTimeout = Duration(seconds: 30);
  
  // إضافة web adapter للـ Flutter Web
  if (kIsWeb) {
    _dio.httpClientAdapter = WebAdapter();
  }
}
```

### 3. تحديث main.dart
```dart
// في main.dart
import 'package:flutter/foundation.dart';

void main() {
  // فقط للـ mobile platforms
  if (!kIsWeb) {
    HttpOverrides.global = MyHttpOverrides();
  }
  ApiService.init();
  runApp(const HandymanApp());
}
```

### 4. تحديث CORS في Laravel
```bash
cd /var/www/wedoo_laravel/wedoo_admin_panel

# مسح cache
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

# إعادة تشغيل الخدمات
sudo systemctl reload nginx
sudo systemctl reload php8.2-fpm
```

### 5. اختبار التطبيق
```bash
cd /media/mohamed/3E16609616605147/wedoo2/handyman_app
flutter run -d chrome
```

## 🎯 النتيجة

بعد تطبيق هذه الخطوات:
- **XMLHttpRequest onError** لن تظهر
- **Flutter Web** سيتصل بالخادم بنجاح
- **CORS preflight** سيعمل بشكل صحيح
- **تسجيل الدخول** سيعمل بدون أخطاء

**المشكلة محلولة! 🚀**
