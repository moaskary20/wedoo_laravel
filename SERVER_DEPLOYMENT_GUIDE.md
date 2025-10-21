# دليل نشر المشروع على السيرفر

## 🚨 المشكلة: Composer لا يجد composer.json

### السبب:
المشروع يحتوي على مجلدين منفصلين:
- `wedoo_admin_panel/` - Laravel Backend (يحتوي على composer.json)
- `handyman_app/` - Flutter Mobile App

### الحل:

#### 1. الانتقال إلى المجلد الصحيح
```bash
# بدلاً من تشغيل composer في المجلد الجذر
cd /var/www/wedoo_laravel

# انتقل إلى مجلد Laravel
cd /var/www/wedoo_laravel/wedoo_admin_panel

# الآن شغل composer
composer install --optimize-autoloader --no-dev
```

#### 2. إعداد Nginx للـ Laravel
```nginx
server {
    listen 80;
    listen 443 ssl http2;
    server_name free-styel.store www.free-styel.store;
    
    # تأكد من أن root يشير إلى مجلد public في Laravel
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

## 📁 هيكل المشروع الصحيح

```
/var/www/wedoo_laravel/
├── wedoo_admin_panel/          # Laravel Backend
│   ├── composer.json           # ← هنا ملف composer.json
│   ├── artisan
│   ├── app/
│   ├── config/
│   ├── database/
│   ├── public/                 # ← Nginx root يجب أن يشير هنا
│   └── ...
├── handyman_app/               # Flutter Mobile App
│   ├── lib/
│   ├── android/
│   ├── ios/
│   └── ...
└── README.md
```

## 🔧 خطوات النشر الصحيحة

### 1. نسخ المشروع
```bash
# نسخ المشروع من GitHub
git clone https://github.com/moaskary20/wedoo_laravel.git /var/www/wedoo_laravel
cd /var/www/wedoo_laravel
```

### 2. إعداد Laravel Backend
```bash
# الانتقال إلى مجلد Laravel
cd /var/www/wedoo_laravel/wedoo_admin_panel

# تثبيت التبعيات
composer install --optimize-autoloader --no-dev

# إعداد البيئة
cp .env.example .env
# أو نسخ من PRODUCTION_ENV_SETTINGS.md
cp ../PRODUCTION_ENV_SETTINGS.md .env

# تحديث القيم في .env
nano .env
```

### 3. إعداد قاعدة البيانات
```bash
# إنشاء قاعدة البيانات
mysql -u root -p
CREATE DATABASE wedoo_production;
CREATE USER 'wedoo_user'@'localhost' IDENTIFIED BY 'wedoo_password';
GRANT ALL PRIVILEGES ON wedoo_production.* TO 'wedoo_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### 4. إعداد Laravel
```bash
cd /var/www/wedoo_laravel/wedoo_admin_panel

# توليد مفتاح التطبيق
php artisan key:generate

# تشغيل migrations
php artisan migrate --force

# تشغيل seeders
php artisan db:seed --force

# تحسين الأداء
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

### 5. إعداد أذونات الملفات
```bash
# أذونات الملفات
sudo chown -R www-data:www-data /var/www/wedoo_laravel
sudo chmod -R 755 /var/www/wedoo_laravel
sudo chmod -R 775 /var/www/wedoo_laravel/wedoo_admin_panel/storage
sudo chmod -R 775 /var/www/wedoo_laravel/wedoo_admin_panel/bootstrap/cache
```

### 6. إعداد Nginx
```nginx
server {
    listen 80;
    listen 443 ssl http2;
    server_name free-styel.store www.free-styel.store;
    
    # مهم: root يجب أن يشير إلى مجلد public في Laravel
    root /var/www/wedoo_laravel/wedoo_admin_panel/public;
    
    index index.php;
    charset utf-8;

    # SSL Configuration
    ssl_certificate /path/to/ssl/certificate.crt;
    ssl_certificate_key /path/to/ssl/private.key;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

## 🚨 حلول المشاكل الشائعة

### 1. خطأ "Composer could not find composer.json"
```bash
# تأكد من أنك في المجلد الصحيح
pwd
# يجب أن يظهر: /var/www/wedoo_laravel/wedoo_admin_panel

# إذا لم تكن في المجلد الصحيح
cd /var/www/wedoo_laravel/wedoo_admin_panel
composer install
```

### 2. خطأ "No application encryption key has been specified"
```bash
cd /var/www/wedoo_laravel/wedoo_admin_panel
php artisan key:generate
```

### 3. خطأ "Database connection failed"
```bash
# تأكد من إعدادات قاعدة البيانات في .env
nano .env

# تأكد من أن قاعدة البيانات موجودة
mysql -u root -p
SHOW DATABASES;
```

### 4. خطأ "Permission denied"
```bash
# إصلاح أذونات الملفات
sudo chown -R www-data:www-data /var/www/wedoo_laravel
sudo chmod -R 755 /var/www/wedoo_laravel
sudo chmod -R 775 /var/www/wedoo_laravel/wedoo_admin_panel/storage
sudo chmod -R 775 /var/www/wedoo_laravel/wedoo_admin_panel/bootstrap/cache
```

## 📱 إعداد تطبيق Flutter

### 1. بناء التطبيق
```bash
cd /var/www/wedoo_laravel/handyman_app
flutter clean
flutter pub get
flutter build apk --release
```

### 2. اختبار التطبيق
```bash
# اختبار الاتصال بالـ API
curl -X GET https://free-styel.store/api/categories/list
```

## 🎯 النتيجة النهائية

بعد تطبيق هذه الخطوات:
- **Laravel Backend** سيعمل على https://free-styel.store
- **Admin Panel** سيكون متاح على https://free-styel.store/admin
- **API** سيكون متاح على https://free-styel.store/api/*
- **تطبيق Flutter** سيتصل بالـ API الجديد

## 🔍 اختبار النظام

### 1. اختبار الـ Backend
```bash
curl -X GET https://free-styel.store/api/categories/list
```

### 2. اختبار Admin Panel
- افتح https://free-styel.store/admin
- سجل الدخول باستخدام بيانات المدير

### 3. اختبار التطبيق
- قم بتثبيت APK على الجهاز
- اختبر تسجيل الدخول
- اختبر جلب الكاتيجري

**النظام جاهز للعمل! 🚀**
