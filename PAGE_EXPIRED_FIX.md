# حل مشكلة "Page Expired" في Laravel

## 🚨 المشكلة
عند محاولة تسجيل الدخول يظهر:
```
Page Expired
The page has expired due to inactivity. Please refresh and try again.
```

## 🔍 الأسباب المحتملة

### 1. مشكلة CSRF Token
- انتهاء صلاحية CSRF Token
- عدم تطابق Session
- مشكلة في إعدادات Session

### 2. مشكلة في إعدادات Session
- Session driver غير صحيح
- مشكلة في Session storage
- انتهاء صلاحية Session

### 3. مشكلة في إعدادات الخادم
- مشكلة في Nginx configuration
- مشكلة في PHP-FPM
- مشكلة في SSL

## ✅ الحلول

### 1. حل مشكلة CSRF Token

#### أ. مسح Cache و Sessions
```bash
cd /var/www/wedoo_laravel/wedoo_admin_panel

# مسح جميع الـ cache
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

# مسح Sessions
php artisan session:table
php artisan migrate
```

#### ب. إعادة تعيين Session
```bash
# حذف ملفات Session
rm -rf /var/www/wedoo_laravel/wedoo_admin_panel/storage/framework/sessions/*

# إعادة تعيين أذونات
sudo chown -R www-data:www-data /var/www/wedoo_laravel/wedoo_admin_panel/storage
sudo chmod -R 775 /var/www/wedoo_laravel/wedoo_admin_panel/storage
```

### 2. إصلاح إعدادات Session

#### أ. تحديث ملف .env
```env
# إعدادات Session
SESSION_DRIVER=file
SESSION_LIFETIME=120
SESSION_ENCRYPT=false
SESSION_PATH=/
SESSION_DOMAIN=.free-styel.store
SESSION_SECURE=true
SESSION_HTTP_ONLY=true
SESSION_SAME_SITE=lax

# إعدادات Cache
CACHE_DRIVER=file

# إعدادات App
APP_KEY=base64:YOUR_APP_KEY_HERE
APP_URL=https://free-styel.store
```

#### ب. إعادة توليد App Key
```bash
cd /var/www/wedoo_laravel/wedoo_admin_panel
php artisan key:generate
```

### 3. إصلاح إعدادات Nginx

#### أ. تحديث إعدادات Nginx
```nginx
server {
    listen 80;
    listen 443 ssl http2;
    server_name free-styel.store www.free-styel.store;
    root /var/www/wedoo_laravel/wedoo_admin_panel/public;
    
    index index.php;
    charset utf-8;

    # إعدادات Session
    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        fastcgi_param HTTP_HOST $host;
        fastcgi_param HTTPS on;
        include fastcgi_params;
    }

    # إعدادات إضافية
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
}
```

### 4. إصلاح إعدادات PHP-FPM

#### أ. تحديث إعدادات PHP
```bash
# تحديث php.ini
sudo nano /etc/php/8.2/fpm/php.ini
```

#### ب. إعدادات PHP المطلوبة
```ini
# Session settings
session.cookie_secure = On
session.cookie_httponly = On
session.cookie_samesite = Lax
session.use_strict_mode = 1
session.cookie_lifetime = 0

# Security settings
expose_php = Off
allow_url_fopen = On
allow_url_include = Off
```

### 5. حل مشكلة SSL

#### أ. تحديث إعدادات SSL
```bash
# إعادة تشغيل Nginx
sudo systemctl reload nginx

# إعادة تشغيل PHP-FPM
sudo systemctl reload php8.2-fpm
```

## 🔧 حلول متقدمة

### 1. استخدام Database Sessions

#### أ. إنشاء جدول Sessions
```bash
cd /var/www/wedoo_laravel/wedoo_admin_panel
php artisan session:table
php artisan migrate
```

#### ب. تحديث .env
```env
SESSION_DRIVER=database
```

### 2. إصلاح مشكلة Timezone

#### أ. تحديث Timezone
```bash
# تحديث timezone في .env
APP_TIMEZONE=Africa/Cairo
```

#### ب. تحديث PHP timezone
```bash
sudo nano /etc/php/8.2/fpm/php.ini
# date.timezone = Africa/Cairo
```

### 3. إصلاح مشكلة Cookies

#### أ. تحديث إعدادات Cookies
```bash
# تحديث .env
SESSION_COOKIE_NAME=wedoo_session
SESSION_COOKIE_PATH=/
SESSION_COOKIE_DOMAIN=.free-styel.store
```

## 🚨 استكشاف الأخطاء

### 1. فحص Logs
```bash
# فحص Laravel logs
tail -f /var/www/wedoo_laravel/wedoo_admin_panel/storage/logs/laravel.log

# فحص Nginx logs
tail -f /var/log/nginx/error.log

# فحص PHP-FPM logs
tail -f /var/log/php8.2-fpm.log
```

### 2. اختبار الاتصال
```bash
# اختبار API
curl -X GET https://free-styel.store/api/categories/list

# اختبار Admin Panel
curl -X GET https://free-styel.store/admin
```

### 3. فحص إعدادات Session
```bash
# فحص إعدادات Session
php artisan tinker
config('session')
```

## 🎯 الحل السريع

### 1. إعادة تعيين كامل
```bash
cd /var/www/wedoo_laravel/wedoo_admin_panel

# مسح جميع الـ cache
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

# إعادة تعيين App Key
php artisan key:generate

# إعادة تعيين Sessions
rm -rf storage/framework/sessions/*
rm -rf storage/framework/cache/*

# إعادة تعيين أذونات
sudo chown -R www-data:www-data storage
sudo chmod -R 775 storage

# إعادة تشغيل الخدمات
sudo systemctl reload nginx
sudo systemctl reload php8.2-fpm
```

### 2. اختبار النتيجة
```bash
# اختبار Admin Panel
curl -X GET https://free-styel.store/admin

# اختبار API
curl -X GET https://free-styel.store/api/categories/list
```

## 🎉 النتيجة

بعد تطبيق هذه الحلول:
- **Page Expired** لن تظهر مرة أخرى
- **تسجيل الدخول** سيعمل بشكل طبيعي
- **Admin Panel** سيكون متاح
- **API** سيعمل بشكل صحيح

**المشكلة محلولة! 🚀**
