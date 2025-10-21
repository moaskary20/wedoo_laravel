# حل مشكلة XMLHttpRequest onError

## 🚨 المشكلة
```
Error: The connection errored: The XMLHttpRequest onError callback was called. This typically indicates an error on the network layer.
```

## 🔍 السبب الجذري
المشكلة في **Flutter Web** مع **XMLHttpRequest**:
1. **CORS preflight** لا يعمل بشكل صحيح
2. **Mixed Content** مشكلة في HTTPS/HTTP
3. **Web Security** مشكلة في المتصفح

## ✅ الحلول

### 1. إصلاح ApiService للـ Web
```dart
// في services/api_service.dart
import 'package:dio/dio.dart';
import 'package:dio_web_adapter/dio_web_adapter.dart';
import '../config/api_config.dart';

class ApiService {
  static final Dio _dio = Dio();
  
  static void init() {
    _dio.options.baseUrl = ApiConfig.baseUrl;
    _dio.options.connectTimeout = Duration(seconds: 30);
    _dio.options.receiveTimeout = Duration(seconds: 30);
    
    // إضافة web adapter للـ Flutter Web
    _dio.httpClientAdapter = WebAdapter();
    
    // إضافة interceptors
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers.addAll(ApiConfig.headers);
        print('Request: ${options.method} ${options.uri}');
        print('Headers: ${options.headers}');
        print('Data: ${options.data}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        print('Response: ${response.statusCode} ${response.requestOptions.uri}');
        print('Response Data: ${response.data}');
        handler.next(response);
      },
      onError: (error, handler) {
        print('Error: ${error.message}');
        print('Error Response: ${error.response?.data}');
        handler.next(error);
      },
    ));
  }
}
```

### 2. إضافة dio_web_adapter
```bash
cd /media/mohamed/3E16609616605147/wedoo2/handyman_app

# إضافة web adapter
flutter pub add dio_web_adapter
```

### 3. تحديث main.dart للـ Web
```dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'screens/login_screen.dart';
import 'services/api_service.dart';
import 'package:flutter/foundation.dart';

void main() {
  // فقط للـ mobile platforms
  if (!kIsWeb) {
    HttpOverrides.global = MyHttpOverrides();
  }
  ApiService.init();
  runApp(const HandymanApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
```

### 4. إصلاح CORS في Laravel
```bash
cd /var/www/wedoo_laravel/wedoo_admin_panel

# تحديث .env
echo "CORS_ALLOWED_ORIGINS=https://free-styel.store,https://www.free-styel.store,https://app.free-styel.store,http://localhost:3000,http://127.0.0.1:3000,http://localhost:8080,http://127.0.0.1:8080,http://localhost:5000,http://127.0.0.1:5000,http://localhost:8000,http://127.0.0.1:8000,http://localhost:42033,http://127.0.0.1:42033,*" >> .env
```

### 5. إصلاح Nginx للـ CORS
```bash
sudo nano /etc/nginx/sites-available/free-styel.store

# إضافة هذه الإعدادات
location /api/ {
    try_files $uri $uri/ /index.php?$query_string;
    
    # CORS headers
    add_header 'Access-Control-Allow-Origin' '*' always;
    add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
    add_header 'Access-Control-Allow-Headers' 'Content-Type, Authorization, X-Requested-With, Accept, Origin, User-Agent' always;
    add_header 'Access-Control-Allow-Credentials' 'true' always;
    
    if ($request_method = 'OPTIONS') {
        add_header 'Access-Control-Allow-Origin' '*';
        add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS';
        add_header 'Access-Control-Allow-Headers' 'Content-Type, Authorization, X-Requested-With, Accept, Origin, User-Agent';
        add_header 'Access-Control-Max-Age' 1728000;
        add_header 'Content-Type' 'text/plain; charset=utf-8';
        add_header 'Content-Length' 0;
        return 204;
    }
}
```

## 🚀 خطوات التطبيق

### 1. تحديث Flutter App
```bash
cd /media/mohamed/3E16609616605147/wedoo2/handyman_app

# إضافة web adapter
flutter pub add dio_web_adapter

# تنظيف وإعادة بناء
flutter clean
flutter pub get
flutter run -d chrome
```

### 2. تحديث Laravel Backend
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

### 3. اختبار API
```bash
# اختبار OPTIONS request
curl -X OPTIONS https://free-styel.store/api/auth/login \
  -H "Origin: http://localhost:42033" \
  -v

# اختبار POST request
curl -X POST https://free-styel.store/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phone":"01012345678","password":"123456"}' \
  -v
```

## 🎯 النتيجة المتوقعة

بعد تطبيق هذه الحلول:
- **XMLHttpRequest onError** لن تظهر
- **Flutter Web** سيتصل بالخادم بنجاح
- **CORS preflight** سيعمل بشكل صحيح
- **تسجيل الدخول** سيعمل بدون أخطاء

**المشكلة محلولة! 🚀**
