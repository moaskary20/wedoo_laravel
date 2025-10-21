# دليل إعداد الإنتاج للنطاق الجديد

## 🌐 النطاق الجديد: https://free-styel.store

### 📱 تحديثات التطبيق

#### 1. إعدادات API (تم التحديث)
```dart
// handyman_app/lib/config/api_config.dart
class ApiConfig {
  static const String baseUrl = 'https://free-styel.store';
  // باقي الإعدادات...
}
```

### 🖥️ إعدادات الـ Backend

#### 1. متغيرات البيئة (.env)
```env
APP_NAME="Wedoo Admin Panel"
APP_ENV=production
APP_KEY=base64:YOUR_APP_KEY_HERE
APP_DEBUG=false
APP_URL=https://free-styel.store

DB_CONNECTION=mysql
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=wedoo_production
DB_USERNAME=your_username
DB_PASSWORD=your_password

# CORS Settings
CORS_ALLOWED_ORIGINS=https://free-styel.store,https://www.free-styel.store

# Session Settings
SESSION_DOMAIN=.free-styel.store
SESSION_SECURE=true
SESSION_HTTP_ONLY=true
SESSION_SAME_SITE=lax
```

#### 2. إعدادات CORS (تم التحديث)
```php
// config/cors.php
'allowed_origins' => [
    'https://free-styel.store',
    'https://www.free-styel.store',
    'https://app.free-styel.store',
],
```

#### 3. إعدادات قاعدة البيانات
```php
// config/database.php
'default' => env('DB_CONNECTION', 'mysql'),
'mysql' => [
    'driver' => 'mysql',
    'url' => env('DATABASE_URL'),
    'host' => env('DB_HOST', '127.0.0.1'),
    'port' => env('DB_PORT', '3306'),
    'database' => env('DB_DATABASE', 'wedoo_production'),
    'username' => env('DB_USERNAME', 'forge'),
    'password' => env('DB_PASSWORD', ''),
    'unix_socket' => env('DB_SOCKET', ''),
    'charset' => 'utf8mb4',
    'collation' => 'utf8mb4_unicode_ci',
    'prefix' => '',
    'prefix_indexes' => true,
    'strict' => true,
    'engine' => null,
    'options' => extension_loaded('pdo_mysql') ? array_filter([
        PDO::MYSQL_ATTR_SSL_CA => env('MYSQL_ATTR_SSL_CA'),
    ]) : [],
],
```

### 🔧 خطوات النشر

#### 1. إعداد الخادم
```bash
# تحديث النظام
sudo apt update && sudo apt upgrade -y

# تثبيت PHP 8.2+
sudo apt install php8.2-fpm php8.2-mysql php8.2-xml php8.2-mbstring php8.2-curl php8.2-zip php8.2-bcmath

# تثبيت Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# تثبيت Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
```

#### 2. إعداد Nginx
```nginx
server {
    listen 80;
    listen 443 ssl http2;
    server_name free-styel.store www.free-styel.store;
    root /var/www/wedoo_admin_panel/public;

    # SSL Configuration
    ssl_certificate /path/to/ssl/certificate.crt;
    ssl_certificate_key /path/to/ssl/private.key;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

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

#### 3. إعداد Laravel
```bash
# نسخ المشروع
git clone https://github.com/moaskary20/wedoo_laravel.git
cd wedoo_laravel/wedoo_admin_panel

# تثبيت التبعيات
composer install --optimize-autoloader --no-dev
npm install && npm run build

# إعداد البيئة
cp .env.example .env
php artisan key:generate

# إعداد قاعدة البيانات
php artisan migrate --force
php artisan db:seed --force

# تحسين الأداء
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

#### 4. إعدادات الأمان
```bash
# أذونات الملفات
sudo chown -R www-data:www-data /var/www/wedoo_admin_panel
sudo chmod -R 755 /var/www/wedoo_admin_panel
sudo chmod -R 775 /var/www/wedoo_admin_panel/storage
sudo chmod -R 775 /var/www/wedoo_admin_panel/bootstrap/cache

# إعدادات PHP
sudo nano /etc/php/8.2/fpm/php.ini
# زيادة upload_max_filesize و post_max_size
# تعيين memory_limit إلى 256M
```

### 📱 تحديث التطبيق

#### 1. إعادة بناء التطبيق
```bash
cd handyman_app
flutter clean
flutter pub get
flutter build apk --release
```

#### 2. اختبار الاتصال
```dart
// اختبار API
final response = await http.get(
  Uri.parse('https://free-styel.store/api/categories/list'),
  headers: ApiConfig.headers,
);
```

### 🔍 اختبار النظام

#### 1. اختبار الـ API
```bash
# اختبار جلب الكاتيجري
curl -X GET https://free-styel.store/api/categories/list

# اختبار تسجيل الدخول
curl -X POST https://free-styel.store/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phone":"01234567890","password":"password"}'
```

#### 2. اختبار Admin Panel
- **الوصول**: https://free-styel.store/admin
- **تسجيل الدخول** باستخدام بيانات المدير
- **اختبار جميع الصفحات** (المستخدمين، الكاتيجري، المحادثات)

#### 3. اختبار التطبيق
- **تسجيل الدخول** برقم الهاتف
- **جلب الكاتيجري** من الـ API
- **اختبار جميع الوظائف**

### 🚨 استكشاف الأخطاء

#### مشاكل شائعة:
1. **خطأ CORS**: تأكد من إعدادات CORS
2. **خطأ SSL**: تأكد من صحة الشهادة
3. **خطأ قاعدة البيانات**: تأكد من الاتصال
4. **خطأ الأذونات**: تأكد من أذونات الملفات

#### الحلول:
```bash
# إعادة تحميل Nginx
sudo systemctl reload nginx

# إعادة تحميل PHP-FPM
sudo systemctl reload php8.2-fpm

# مسح Cache
php artisan cache:clear
php artisan config:clear
php artisan route:clear
```

### 📊 مراقبة الأداء

#### 1. مراقبة الخادم
```bash
# مراقبة استخدام الذاكرة
htop

# مراقبة الأخطاء
tail -f /var/log/nginx/error.log
tail -f /var/log/php8.2-fpm.log
```

#### 2. مراقبة التطبيق
- **مراقبة API calls** في التطبيق
- **مراقبة الأخطاء** في logs
- **مراقبة الأداء** في Admin Panel

### 🎉 النتيجة

بعد تطبيق هذه الإعدادات:
- **الـ Backend** سيعمل على https://free-styel.store
- **التطبيق** سيتصل بالـ API الجديد
- **جميع الوظائف** ستعمل بشكل طبيعي
- **الأمان** محسن للإنتاج

**النظام جاهز للنشر على النطاق الجديد! 🚀**
