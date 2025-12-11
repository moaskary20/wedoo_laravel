# تعليمات إصلاح المشكلة على السيرفر (Apache)

## معلومات السيرفر
- **IP:** 144.91.106.22
- **User:** root
- **Password:** LU1AIb6QtL4ckQr875X
- **Web Server:** Apache

## الطريقة السريعة (استخدام السكريبت)

### 1. رفع السكريبت إلى السيرفر

من جهازك المحلي:

```bash
# نسخ السكريبت إلى السيرفر
scp wedoo_admin_panel/FIX_ON_SERVER.sh root@144.91.106.22:/root/

# الدخول إلى السيرفر
ssh root@144.91.106.22

# تشغيل السكريبت
chmod +x /root/FIX_ON_SERVER.sh
/root/FIX_ON_SERVER.sh
```

## الطريقة اليدوية (خطوة بخطوة)

### 1. الاتصال بالسيرفر

```bash
ssh root@144.91.106.22
# Password: LU1AIb6QtL4ckQr875X
```

### 2. الانتقال إلى مجلد المشروع

```bash
cd /var/www/wedoo_laravel/wedoo_admin_panel
```

### 3. سحب آخر التحديثات

```bash
git pull origin main
```

### 4. التحقق من الملفات المحدثة

```bash
# التحقق من ملف Blade template
cat resources/views/filament/pages/brevo-settings.blade.php

# يجب أن يحتوي على:
# @php
#     $errors = $errors ?? \Illuminate\Support\Facades\View::shared('errors', new \Illuminate\Support\ViewErrorBag);
# @endphp
```

### 5. مسح جميع الـ Cache

```bash
php artisan config:clear
php artisan cache:clear
php artisan view:clear
php artisan route:clear
```

### 6. حذف compiled views القديمة (مهم جداً!)

```bash
rm -rf storage/framework/views/*
```

هذا السطر مهم جداً لأنه يحذف compiled views القديمة التي تحتوي على الكود القديم.

### 7. إعادة بناء Cache

```bash
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

### 8. إصلاح الصلاحيات

```bash
chmod -R 775 storage bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache
```

### 9. إعادة تشغيل Apache

```bash
systemctl restart apache2
# أو
service apache2 restart
```

### 10. التحقق من حالة Apache

```bash
systemctl status apache2
```

## التحقق من الإصلاح

### 1. فتح الصفحة في المتصفح

افتح: `https://free-styel.store/admin/brevo-settings`

### 2. التحقق من Logs

إذا استمرت المشكلة:

```bash
# فحص Laravel logs
tail -f storage/logs/laravel.log

# فحص Apache error logs
tail -f /var/log/apache2/error.log
```

### 3. التحقق من Compiled Views

```bash
# التحقق من أن compiled views تم تحديثها
ls -la storage/framework/views/ | head -20
```

## حلول إضافية إذا استمرت المشكلة

### 1. التحقق من إصدار PHP

```bash
php -v
# يجب أن يكون PHP 8.3.6
```

### 2. التحقق من Composer

```bash
composer --version
composer dump-autoload
```

### 3. التحقق من Filament

```bash
composer show filament/filament
```

### 4. إعادة تثبيت Dependencies

```bash
composer install --no-dev --optimize-autoloader
```

### 5. التحقق من .env

```bash
# التأكد من أن ملف .env موجود
ls -la .env

# التحقق من الصلاحيات
chmod 644 .env
chown www-data:www-data .env
```

## ملاحظات مهمة

1. **Apache vs Nginx:** السيرفر يستخدم Apache، لذلك استخدم `systemctl restart apache2` بدلاً من Nginx.

2. **Compiled Views:** حذف `storage/framework/views/*` مهم جداً لأنه يحذف الكود القديم المترجم.

3. **Cache:** يجب مسح جميع أنواع Cache قبل إعادة بنائها.

4. **Permissions:** تأكد من أن `www-data` لديه صلاحيات الكتابة على `storage` و `bootstrap/cache`.

## إذا استمرت المشكلة

1. تحقق من Laravel logs: `tail -f storage/logs/laravel.log`
2. تحقق من Apache logs: `tail -f /var/log/apache2/error.log`
3. تحقق من PHP-FPM logs (إذا كان مستخدماً): `tail -f /var/log/php8.3-fpm.log`
4. أرسل رسالة الخطأ الكاملة

