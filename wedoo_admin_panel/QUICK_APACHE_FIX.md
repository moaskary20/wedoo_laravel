# الحل السريع لمشكلة Apache مع CORS

## 🚨 المشكلة
```
Web Error: The connection errored: The XMLHttpRequest onError callback was called.
```

## 🔧 الحل السريع

### 1. **تفعيل mod_headers**
```bash
sudo a2enmod headers
sudo systemctl restart apache2
```

### 2. **إنشاء ملف CORS**
```bash
sudo nano /etc/apache2/conf-available/cors.conf
```

```apache
<IfModule mod_headers.c>
    Header always set Access-Control-Allow-Origin "*"
    Header always set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
    Header always set Access-Control-Allow-Headers "Content-Type, Authorization, X-Requested-With, Accept, Origin, User-Agent"
    Header always set Access-Control-Allow-Credentials "true"
    Header always set Access-Control-Max-Age "86400"
    
    RewriteEngine On
    RewriteCond %{REQUEST_METHOD} OPTIONS
    RewriteRule ^(.*)$ $1 [R=200,L]
</IfModule>
```

### 3. **تفعيل CORS**
```bash
sudo a2enconf cors
sudo systemctl restart apache2
```

### 4. **تحديث .htaccess**
```bash
sudo nano /var/www/wedoo_laravel/wedoo_admin_panel/public/.htaccess
```

```apache
# CORS headers
<IfModule mod_headers.c>
    Header always set Access-Control-Allow-Origin "*"
    Header always set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
    Header always set Access-Control-Allow-Headers "Content-Type, Authorization, X-Requested-With, Accept, Origin, User-Agent"
    Header always set Access-Control-Allow-Credentials "true"
    Header always set Access-Control-Max-Age "86400"
</IfModule>

# Handle OPTIONS requests
RewriteEngine On
RewriteCond %{REQUEST_METHOD} OPTIONS
RewriteRule ^(.*)$ $1 [R=200,L]

# Laravel routing
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)$ index.php [QSA,L]
```

### 5. **إعادة تشغيل Apache**
```bash
sudo systemctl restart apache2
```

## 🎯 النتيجة المتوقعة
- CORS headers ستظهر
- Flutter Web سيتصل بنجاح
- XMLHttpRequest onError لن تظهر

**المشكلة محلولة! 🚀**
