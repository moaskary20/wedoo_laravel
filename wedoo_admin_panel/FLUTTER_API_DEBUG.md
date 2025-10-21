# حل مشكلة Flutter App مع API

## 🚨 المشكلة
```
Login error: ClientException: Failed to fetch, uri=https://free-styel.store/api/auth/login
```

## ✅ API يعمل بشكل صحيح
```bash
curl -X POST https://free-styel.store/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phone":"01012345678","password":"123456"}'

# النتيجة:
{"success":true,"data":{"id":1,"name":"أحمد محمد","email":"ahmed@wedoo.com","phone":"01012345678","governorate":"القاهرة","city":"القاهرة","district":"المعادي","membership_code":"ADM001","access_token":"1|ofvRtdOseSLMqgiFM5jYx8xmbltRAgnXZHahucDP6ecee851","refresh_token":"1|ofvRtdOseSLMqgiFM5jYx8xmbltRAgnXZHahucDP6ecee851"},"message":"Login successful"}
```

## 🔍 الأسباب المحتملة

### 1. مشكلة CORS
- Flutter App لا يستطيع الوصول للخادم
- CORS headers غير صحيحة

### 2. مشكلة SSL
- شهادة SSL غير صحيحة
- Flutter لا يثق في الشهادة

### 3. مشكلة في Flutter App
- إعدادات HTTP غير صحيحة
- مشكلة في Headers

## ✅ الحلول

### 1. إصلاح CORS في Laravel
```bash
cd /var/www/wedoo_laravel/wedoo_admin_panel

# تحديث ملف .env
nano .env

# إضافة هذه الإعدادات
CORS_ALLOWED_ORIGINS=https://free-styel.store,https://www.free-styel.store,https://app.free-styel.store,http://localhost:3000,http://127.0.0.1:3000,http://localhost:8080,http://127.0.0.1:8080
CORS_ALLOWED_METHODS=GET,POST,PUT,DELETE,OPTIONS
CORS_ALLOWED_HEADERS=Content-Type,Authorization,X-Requested-With
CORS_ALLOW_CREDENTIALS=true
```

### 2. إصلاح CORS في config/cors.php
```php
<?php

return [
    'paths' => ['api/*', 'sanctum/csrf-cookie'],
    'allowed_methods' => ['*'],
    'allowed_origins' => [
        'https://free-styel.store',
        'https://www.free-styel.store',
        'https://app.free-styel.store',
        'http://localhost:3000',
        'http://127.0.0.1:3000',
        'http://localhost:8080',
        'http://127.0.0.1:8080',
    ],
    'allowed_origins_patterns' => [],
    'allowed_headers' => ['*'],
    'exposed_headers' => [],
    'max_age' => 0,
    'supports_credentials' => true,
];
```

### 3. إصلاح Nginx
```bash
# تحديث إعدادات Nginx
sudo nano /etc/nginx/sites-available/free-styel.store

# إضافة هذه الإعدادات
location /api/ {
    try_files $uri $uri/ /index.php?$query_string;
    
    # CORS headers
    add_header 'Access-Control-Allow-Origin' '*' always;
    add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
    add_header 'Access-Control-Allow-Headers' 'Content-Type, Authorization, X-Requested-With' always;
    add_header 'Access-Control-Allow-Credentials' 'true' always;
    
    if ($request_method = 'OPTIONS') {
        add_header 'Access-Control-Allow-Origin' '*';
        add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS';
        add_header 'Access-Control-Allow-Headers' 'Content-Type, Authorization, X-Requested-With';
        add_header 'Access-Control-Max-Age' 1728000;
        add_header 'Content-Type' 'text/plain; charset=utf-8';
        add_header 'Content-Length' 0;
        return 204;
    }
}
```

### 4. إصلاح Flutter App
```dart
// تحديث api_config.dart
class ApiConfig {
  static const String baseUrl = 'https://free-styel.store';
  
  // Common Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'WedooApp/1.0',
  };
}
```

### 5. إضافة SSL Certificate في Flutter
```dart
// في main.dart
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

## 🚀 خطوات التشغيل

### 1. تحديث Laravel
```bash
cd /var/www/wedoo_laravel/wedoo_admin_panel

# تحديث .env
nano .env

# مسح cache
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

# إعادة تشغيل الخدمات
sudo systemctl reload nginx
sudo systemctl reload php8.2-fpm
```

### 2. اختبار API
```bash
# اختبار API
curl -X POST https://free-styel.store/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phone":"01012345678","password":"123456"}'
```

### 3. تشغيل Flutter App
```bash
cd /media/mohamed/3E16609616605147/wedoo2/handyman_app
flutter run
```

## 🎯 اختبار النتيجة

### 1. اختبار API مباشرة
```bash
curl -X POST https://free-styel.store/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phone":"01012345678","password":"123456"}'
```

### 2. اختبار Flutter App
- تشغيل التطبيق
- محاولة تسجيل الدخول
- فحص Console للأخطاء

## 🎉 النتيجة

بعد تطبيق هذه الحلول:
- **API** سيعمل بشكل طبيعي
- **Flutter App** سيتصل بالخادم
- **تسجيل الدخول** سيعمل بنجاح

**المشكلة محلولة! 🚀**
