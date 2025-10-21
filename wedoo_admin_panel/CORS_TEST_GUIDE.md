# دليل اختبار CORS Headers

## 🔧 إعدادات CORS المحدثة

### 1. ملف config/cors.php
```php
'allowed_origins' => [
    'https://free-styel.store',
    'https://www.free-styel.store',
    'https://app.free-styel.store',
    'http://localhost:3000',
    'http://127.0.0.1:3000',
    'http://localhost:8080',
    'http://127.0.0.1:8080',
    'http://localhost:5000',
    'http://127.0.0.1:5000',
    'http://localhost:8000',
    'http://127.0.0.1:8000',
    '*', // Allow all origins for development
],
```

### 2. ملف .env
```env
CORS_ALLOWED_ORIGINS=https://free-styel.store,https://www.free-styel.store,https://app.free-styel.store,http://localhost:3000,http://127.0.0.1:3000,http://localhost:8080,http://127.0.0.1:8080,http://localhost:5000,http://127.0.0.1:5000,http://localhost:8000,http://127.0.0.1:8000,*
CORS_ALLOWED_METHODS=GET,POST,PUT,DELETE,OPTIONS
CORS_ALLOWED_HEADERS=Content-Type,Authorization,X-Requested-With,Accept,Origin
CORS_ALLOW_CREDENTIALS=true
```

### 3. CorsMiddleware مخصص
```php
// app/Http/Middleware/CorsMiddleware.php
public function handle(Request $request, Closure $next)
{
    // Handle preflight requests
    if ($request->getMethod() === "OPTIONS") {
        return response('', 200)
            ->header('Access-Control-Allow-Origin', '*')
            ->header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
            ->header('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With, Accept, Origin')
            ->header('Access-Control-Allow-Credentials', 'true')
            ->header('Access-Control-Max-Age', '86400');
    }

    $response = $next($request);

    // Add CORS headers to all responses
    $response->headers->set('Access-Control-Allow-Origin', '*');
    $response->headers->set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    $response->headers->set('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With, Accept, Origin');
    $response->headers->set('Access-Control-Allow-Credentials', 'true');

    return $response;
}
```

## 🚀 خطوات التطبيق

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

### 3. فحص Browser Developer Tools
- فتح Developer Tools
- فحص Network tab
- البحث عن CORS headers في Response

## 🎯 النتيجة المتوقعة

بعد تطبيق هذه الإعدادات:
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
