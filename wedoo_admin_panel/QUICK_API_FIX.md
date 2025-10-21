# حل سريع لمشكلة API

## 🚨 المشكلة
```
Login error: ClientException: Failed to fetch, uri=https://free-styel.store/api/auth/login
```

## ✅ الحل السريع

### 1. فحص API Routes
```bash
cd /var/www/wedoo_laravel/wedoo_admin_panel

# فحص Routes
php artisan route:list | grep api
```

### 2. اختبار API مباشرة
```bash
# اختبار API
curl -X POST https://free-styel.store/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phone":"01012345678","password":"123456"}'
```

### 3. إصلاح CORS
```bash
# تحديث ملف .env
nano .env

# إضافة هذه الإعدادات
CORS_ALLOWED_ORIGINS=https://free-styel.store,https://www.free-styel.store,https://app.free-styel.store,http://localhost:3000,http://127.0.0.1:3000
```

### 4. مسح Cache
```bash
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
```

### 5. إعادة تشغيل الخدمات
```bash
sudo systemctl reload nginx
sudo systemctl reload php8.2-fpm
```

## 🔧 إصلاح Flutter App

### 1. تحديث API URL
```dart
// في ملف lib/config/api_config.dart
class ApiConfig {
  static const String baseUrl = 'https://free-styel.store';
  static const String apiUrl = '$baseUrl/api';
}
```

### 2. إضافة Headers
```dart
// إضافة headers للطلبات
static Map<String, String> get headers => {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
};
```

## 🎯 اختبار النتيجة

### 1. اختبار API
```bash
curl -X POST https://free-styel.store/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phone":"01012345678","password":"123456"}'
```

### 2. اختبار Flutter App
```bash
cd /media/mohamed/3E16609616605147/wedoo2/handyman_app
flutter run
```

## 🎉 النتيجة

بعد تطبيق هذه الخطوات:
- **API** سيعمل بشكل طبيعي
- **Flutter App** سيتصل بالخادم
- **تسجيل الدخول** سيعمل بنجاح

**المشكلة محلولة! 🚀**
