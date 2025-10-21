# دليل تحديث النطاق إلى https://free-styel.store

## 🎯 التحديثات المنجزة

### ✅ 1. تحديث التطبيق (Flutter)
```dart
// handyman_app/lib/config/api_config.dart
class ApiConfig {
  static const String baseUrl = 'https://free-styel.store';
  // جميع الـ endpoints محدثة تلقائياً
}
```

### ✅ 2. تحديث إعدادات CORS
```php
// wedoo_admin_panel/config/cors.php
'allowed_origins' => [
    'https://free-styel.store',
    'https://www.free-styel.store',
    'https://app.free-styel.store',
    'http://localhost:3000',
    'http://127.0.0.1:3000',
],
```

### ✅ 3. إعدادات الإنتاج
- **ملف إعدادات البيئة** للإنتاج
- **إعدادات الأمان** محسنة
- **إعدادات SSL** جاهزة

## 🚀 خطوات النشر

### 1. إعداد الخادم
```bash
# تثبيت المتطلبات
sudo apt update
sudo apt install nginx php8.2-fpm mysql-server composer nodejs

# إعداد قاعدة البيانات
mysql -u root -p
CREATE DATABASE wedoo_production;
CREATE USER 'wedoo_user'@'localhost' IDENTIFIED BY 'wedoo_password';
GRANT ALL PRIVILEGES ON wedoo_production.* TO 'wedoo_user'@'localhost';
FLUSH PRIVILEGES;
```

### 2. نشر الكود
```bash
# نسخ المشروع
git clone https://github.com/moaskary20/wedoo_laravel.git
cd wedoo_laravel/wedoo_admin_panel

# تثبيت التبعيات
composer install --optimize-autoloader --no-dev
npm install && npm run build

# إعداد البيئة
cp PRODUCTION_ENV_SETTINGS.md .env
# تحديث القيم المطلوبة في .env

# إعداد Laravel
php artisan key:generate
php artisan migrate --force
php artisan db:seed --force
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

### 3. إعداد Nginx
```nginx
server {
    listen 80;
    listen 443 ssl http2;
    server_name free-styel.store www.free-styel.store;
    root /var/www/wedoo_admin_panel/public;

    # SSL Configuration
    ssl_certificate /path/to/ssl/certificate.crt;
    ssl_certificate_key /path/to/ssl/private.key;

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

### 4. إعداد SSL
```bash
# استخدام Let's Encrypt
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d free-styel.store -d www.free-styel.store
```

## 📱 تحديث التطبيق

### 1. إعادة بناء التطبيق
```bash
cd handyman_app
flutter clean
flutter pub get
flutter build apk --release
```

### 2. اختبار الاتصال
```dart
// اختبار API
final response = await http.get(
  Uri.parse('https://free-styel.store/api/categories/list'),
  headers: ApiConfig.headers,
);
print('Status: ${response.statusCode}');
print('Body: ${response.body}');
```

## 🔍 اختبار النظام

### 1. اختبار الـ API
```bash
# اختبار جلب الكاتيجري
curl -X GET https://free-styel.store/api/categories/list

# اختبار تسجيل الدخول
curl -X POST https://free-styel.store/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phone":"01234567890","password":"password"}'
```

### 2. اختبار Admin Panel
- **الوصول**: https://free-styel.store/admin
- **تسجيل الدخول** باستخدام بيانات المدير
- **اختبار جميع الصفحات**

### 3. اختبار التطبيق
- **تسجيل الدخول** برقم الهاتف
- **جلب الكاتيجري** من الـ API
- **اختبار جميع الوظائف**

## 🚨 استكشاف الأخطاء

### مشاكل شائعة:
1. **خطأ CORS**: تأكد من إعدادات CORS
2. **خطأ SSL**: تأكد من صحة الشهادة
3. **خطأ قاعدة البيانات**: تأكد من الاتصال
4. **خطأ الأذونات**: تأكد من أذونات الملفات

### الحلول:
```bash
# إعادة تحميل الخدمات
sudo systemctl reload nginx
sudo systemctl reload php8.2-fpm

# مسح Cache
php artisan cache:clear
php artisan config:clear
php artisan route:clear

# مراقبة الأخطاء
tail -f /var/log/nginx/error.log
tail -f /var/log/php8.2-fpm.log
```

## 📊 مراقبة الأداء

### 1. مراقبة الخادم
```bash
# مراقبة استخدام الذاكرة
htop

# مراقبة الأخطاء
tail -f /var/log/nginx/error.log
tail -f /var/log/php8.2-fpm.log
```

### 2. مراقبة التطبيق
- **مراقبة API calls** في التطبيق
- **مراقبة الأخطاء** في logs
- **مراقبة الأداء** في Admin Panel

## 🎉 النتيجة

بعد تطبيق هذه الإعدادات:
- **الـ Backend** سيعمل على https://free-styel.store
- **التطبيق** سيتصل بالـ API الجديد
- **جميع الوظائف** ستعمل بشكل طبيعي
- **الأمان** محسن للإنتاج

**النظام جاهز للنشر على النطاق الجديد! 🚀**

## 📞 الدعم

إذا واجهت أي مشاكل:
1. راجع ملفات الـ logs
2. تأكد من إعدادات SSL
3. تأكد من إعدادات قاعدة البيانات
4. تأكد من أذونات الملفات
