# حل سريع لمشكلة "Page Expired"

## 🚨 المشكلة
```
Page Expired
The page has expired due to inactivity. Please refresh and try again.
```

## ✅ الحل السريع

### 1. مسح جميع الـ Cache
```bash
cd /var/www/wedoo_laravel/wedoo_admin_panel

php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
```

### 2. إعادة تعيين App Key
```bash
php artisan key:generate
```

### 3. مسح Sessions
```bash
rm -rf storage/framework/sessions/*
rm -rf storage/framework/cache/*
```

### 4. إعادة تعيين أذونات
```bash
sudo chown -R www-data:www-data storage
sudo chmod -R 775 storage
```

### 5. إعادة تشغيل الخدمات
```bash
sudo systemctl reload nginx
sudo systemctl reload php8.2-fpm
```

## 🔧 إذا لم تعمل الطريقة السريعة

### 1. تحديث إعدادات .env
```env
SESSION_DRIVER=file
SESSION_LIFETIME=120
SESSION_ENCRYPT=false
SESSION_PATH=/
SESSION_DOMAIN=.free-styel.store
SESSION_SECURE=true
SESSION_HTTP_ONLY=true
SESSION_SAME_SITE=lax
```

### 2. إعادة تشغيل Laravel
```bash
php artisan config:cache
php artisan route:cache
```

## 🎯 النتيجة

بعد تطبيق هذه الخطوات:
- **Page Expired** لن تظهر
- **تسجيل الدخول** سيعمل
- **Admin Panel** سيكون متاح

**المشكلة محلولة! 🚀**
