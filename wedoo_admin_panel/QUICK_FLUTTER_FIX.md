# حل سريع لمشكلة Flutter App

## 🚨 المشكلة
```
Login error: ClientException: Failed to fetch, uri=https://free-styel.store/api/auth/login
```

## ✅ API يعمل بشكل صحيح
```bash
curl -X POST https://free-styel.store/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phone":"01012345678","password":"123456"}'
```

## 🔧 الحل السريع

### 1. إصلاح CORS
```bash
cd /var/www/wedoo_laravel/wedoo_admin_panel

# تحديث .env
nano .env

# إضافة هذه الإعدادات
CORS_ALLOWED_ORIGINS=https://free-styel.store,https://www.free-styel.store,https://app.free-styel.store,http://localhost:3000,http://127.0.0.1:3000,http://localhost:8080,http://127.0.0.1:8080
```

### 2. مسح Cache
```bash
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
```

### 3. إعادة تشغيل الخدمات
```bash
sudo systemctl reload nginx
sudo systemctl reload php8.2-fpm
```

### 4. اختبار API
```bash
curl -X POST https://free-styel.store/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phone":"01012345678","password":"123456"}'
```

### 5. تشغيل Flutter App
```bash
cd /media/mohamed/3E16609616605147/wedoo2/handyman_app
flutter run
```

## 🎯 النتيجة

بعد تطبيق هذه الخطوات:
- **API** سيعمل بشكل طبيعي
- **Flutter App** سيتصل بالخادم
- **تسجيل الدخول** سيعمل بنجاح

**المشكلة محلولة! 🚀**
