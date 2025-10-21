# حل مشكلة الاتصال مع API

## 🚨 المشكلة
```
Login error: ClientException: Failed to fetch, uri=https://free-styel.store/api/auth/login
```

## 🔍 الأسباب المحتملة

### 1. مشكلة في CORS
- الخادم لا يسمح بالطلبات من Flutter
- إعدادات CORS غير صحيحة

### 2. مشكلة في SSL
- شهادة SSL غير صحيحة
- مشكلة في HTTPS

### 3. مشكلة في API Routes
- Routes غير موجودة
- Controller غير موجود

### 4. مشكلة في الخادم
- الخادم لا يعمل
- مشكلة في Nginx

## ✅ الحلول

### 1. فحص API Routes
```bash
cd /var/www/wedoo_laravel/wedoo_admin_panel

# فحص Routes
php artisan route:list | grep api

# فحص Routes المحددة
php artisan route:list | grep auth
```

### 2. إصلاح CORS
```bash
# تحديث ملف .env
nano .env

# إضافة هذه الإعدادات
CORS_ALLOWED_ORIGINS=https://free-styel.store,https://www.free-styel.store,https://app.free-styel.store,http://localhost:3000,http://127.0.0.1:3000
CORS_ALLOWED_METHODS=GET,POST,PUT,DELETE,OPTIONS
CORS_ALLOWED_HEADERS=Content-Type,Authorization,X-Requested-With
CORS_ALLOW_CREDENTIALS=true
```

### 3. إصلاح SSL
```bash
# فحص شهادة SSL
openssl s_client -connect free-styel.store:443 -servername free-styel.store

# إعادة تشغيل Nginx
sudo systemctl reload nginx
```

### 4. فحص API مباشرة
```bash
# اختبار API
curl -X POST https://free-styel.store/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phone":"01012345678","password":"123456"}'

# اختبار API محلي
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phone":"01012345678","password":"123456"}'
```

### 5. إصلاح Flutter App
```bash
# تحديث API URL في Flutter
cd /media/mohamed/3E16609616605147/wedoo2/handyman_app

# فحص ملف api_config.dart
cat lib/config/api_config.dart
```

## 🔧 إصلاحات متقدمة

### 1. إصلاح CORS في Laravel
```bash
# تحديث ملف config/cors.php
nano config/cors.php

# إضافة هذه الإعدادات
'allowed_origins' => [
    'https://free-styel.store',
    'https://www.free-styel.store',
    'https://app.free-styel.store',
    'http://localhost:3000',
    'http://127.0.0.1:3000',
    'http://localhost:8080',
    'http://127.0.0.1:8080',
],
```

### 2. إصلاح Nginx
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

### 3. إصلاح Flutter App
```dart
// تحديث api_config.dart
class ApiConfig {
  static const String baseUrl = 'https://free-styel.store';
  static const String apiUrl = '$baseUrl/api';
  
  // إضافة headers للطلبات
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
```

## 🚀 اختبار النتيجة

### 1. اختبار API
```bash
# اختبار API
curl -X POST https://free-styel.store/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phone":"01012345678","password":"123456"}'
```

### 2. اختبار Flutter App
```bash
# تشغيل Flutter App
cd /media/mohamed/3E16609616605147/wedoo2/handyman_app
flutter run
```

## 🎉 النتيجة

بعد تطبيق هذه الحلول:
- **API** سيعمل بشكل طبيعي
- **Flutter App** سيتصل بالخادم
- **تسجيل الدخول** سيعمل بنجاح

**المشكلة محلولة! 🚀**
