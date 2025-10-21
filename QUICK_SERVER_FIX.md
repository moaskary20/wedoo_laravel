# حل سريع لمشكلة Composer على السيرفر

## 🚨 المشكلة
```
Composer could not find a composer.json file in /var/www/wedoo_laravel
```

## ✅ الحل السريع

### 1. الانتقال إلى المجلد الصحيح
```bash
# بدلاً من:
cd /var/www/wedoo_laravel
composer install  # ❌ خطأ

# استخدم:
cd /var/www/wedoo_laravel/wedoo_admin_panel
composer install  # ✅ صحيح
```

### 2. إعداد Laravel
```bash
cd /var/www/wedoo_laravel/wedoo_admin_panel

# إعداد البيئة
cp PRODUCTION_ENV_SETTINGS.md .env
# أو
cp .env.example .env

# تحديث القيم في .env
nano .env

# توليد مفتاح التطبيق
php artisan key:generate

# تشغيل migrations
php artisan migrate --force

# تحسين الأداء
php artisan config:cache
php artisan route:cache
```

### 3. إعداد Nginx
```nginx
server {
    listen 80;
    listen 443 ssl http2;
    server_name free-styel.store www.free-styel.store;
    
    # مهم: root يجب أن يشير إلى مجلد public
    root /var/www/wedoo_laravel/wedoo_admin_panel/public;
    
    index index.php;
    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
```

### 4. إعداد أذونات الملفات
```bash
sudo chown -R www-data:www-data /var/www/wedoo_laravel
sudo chmod -R 755 /var/www/wedoo_laravel
sudo chmod -R 775 /var/www/wedoo_laravel/wedoo_admin_panel/storage
sudo chmod -R 775 /var/www/wedoo_laravel/wedoo_admin_panel/bootstrap/cache
```

## 🎯 السبب
المشروع يحتوي على مجلدين:
- `wedoo_admin_panel/` - Laravel Backend (يحتوي على composer.json)
- `handyman_app/` - Flutter Mobile App

Composer يحتاج إلى أن يتم تشغيله في مجلد Laravel وليس في المجلد الجذر.

## ✅ النتيجة
بعد تطبيق هذه الخطوات:
- Laravel سيعمل على https://free-styel.store
- Admin Panel سيكون متاح على https://free-styel.store/admin
- API سيكون متاح على https://free-styel.store/api/*

**المشكلة محلولة! 🚀**
