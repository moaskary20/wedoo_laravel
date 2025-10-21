# تطبيق إصلاح CORS Headers

## 🚀 خطوات التطبيق السريع

### 1. مسح Cache
```bash
cd /var/www/wedoo_laravel/wedoo_admin_panel

php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
```

### 2. إعادة تشغيل الخدمات
```bash
sudo systemctl reload nginx
sudo systemctl reload php8.2-fpm
```

### 3. اختبار CORS Headers
```bash
# اختبار OPTIONS request
curl -X OPTIONS https://free-styel.store/api/auth/login \
  -H "Origin: http://localhost:3000" \
  -H "Access-Control-Request-Method: POST" \
  -H "Access-Control-Request-Headers: Content-Type" \
  -v

# اختبار POST request
curl -X POST https://free-styel.store/api/auth/login \
  -H "Content-Type: application/json" \
  -H "Origin: http://localhost:3000" \
  -d '{"phone":"01012345678","password":"123456"}' \
  -v
```

### 4. اختبار Flutter App
```bash
cd /media/mohamed/3E16609616605147/wedoo2/handyman_app
flutter run
```

## 🔍 فحص CORS Headers

### 1. فحص Response Headers
```bash
curl -I https://free-styel.store/api/auth/login
```

### 2. فحص OPTIONS Request
```bash
curl -X OPTIONS https://free-styel.store/api/auth/login \
  -H "Origin: http://localhost:3000" \
  -v
```

## 🎯 النتيجة المتوقعة

بعد تطبيق هذه الخطوات:
- **CORS headers** ستظهر في جميع الاستجابات
- **Flutter App** سيتصل بالخادم بنجاح
- **تسجيل الدخول** سيعمل بدون أخطاء

## 🚨 إذا لم تعمل

### 1. فحص Nginx Configuration
```bash
sudo nano /etc/nginx/sites-available/free-styel.store

# إضافة هذه الإعدادات
location /api/ {
    try_files $uri $uri/ /index.php?$query_string;
    
    # CORS headers
    add_header 'Access-Control-Allow-Origin' '*' always;
    add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
    add_header 'Access-Control-Allow-Headers' 'Content-Type, Authorization, X-Requested-With, Accept, Origin' always;
    add_header 'Access-Control-Allow-Credentials' 'true' always;
    
    if ($request_method = 'OPTIONS') {
        add_header 'Access-Control-Allow-Origin' '*';
        add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS';
        add_header 'Access-Control-Allow-Headers' 'Content-Type, Authorization, X-Requested-With, Accept, Origin';
        add_header 'Access-Control-Max-Age' 1728000;
        add_header 'Content-Type' 'text/plain; charset=utf-8';
        add_header 'Content-Length' 0;
        return 204;
    }
}
```

### 2. إعادة تشغيل Nginx
```bash
sudo systemctl reload nginx
```

**المشكلة محلولة! 🚀**
