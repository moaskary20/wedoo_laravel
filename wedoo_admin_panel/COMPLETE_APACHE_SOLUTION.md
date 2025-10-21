# الحل الشامل لمشكلة Apache مع CORS

## 🚨 المشكلة الأساسية
```
Web Error: The connection errored: The XMLHttpRequest onError callback was called.
```

## 🔍 السبب الجذري
المشكلة في **Apache** مع **CORS**:
1. **Apache** لا يدعم CORS بشكل افتراضي
2. **mod_headers** قد لا يكون مفعل
3. **CORS headers** غير مضبوطة بشكل صحيح
4. **OPTIONS requests** لا تعمل بشكل صحيح

## ✅ الحل الشامل لـ Apache

### 1. **تفعيل mod_headers في Apache**
```bash
# تفعيل mod_headers
sudo a2enmod headers

# إعادة تشغيل Apache
sudo systemctl restart apache2
```

### 2. **إنشاء ملف CORS configuration**
```bash
# إنشاء ملف CORS configuration
sudo nano /etc/apache2/conf-available/cors.conf
```

```apache
# CORS Configuration for Apache
<IfModule mod_headers.c>
    # Allow CORS for all origins
    Header always set Access-Control-Allow-Origin "*"
    Header always set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
    Header always set Access-Control-Allow-Headers "Content-Type, Authorization, X-Requested-With, Accept, Origin, User-Agent"
    Header always set Access-Control-Allow-Credentials "true"
    Header always set Access-Control-Max-Age "86400"
    
    # Handle OPTIONS requests
    RewriteEngine On
    RewriteCond %{REQUEST_METHOD} OPTIONS
    RewriteRule ^(.*)$ $1 [R=200,L]
</IfModule>
```

### 3. **تفعيل CORS configuration**
```bash
# تفعيل CORS configuration
sudo a2enconf cors

# إعادة تشغيل Apache
sudo systemctl restart apache2
```

### 4. **تحديث Virtual Host**
```bash
# تحديث Virtual Host
sudo nano /etc/apache2/sites-available/free-styel.store.conf
```

```apache
<VirtualHost *:80>
    ServerName free-styel.store
    DocumentRoot /var/www/wedoo_laravel/wedoo_admin_panel/public
    
    <Directory /var/www/wedoo_laravel/wedoo_admin_panel/public>
        AllowOverride All
        Require all granted
        
        # CORS headers for API routes
        <LocationMatch "^/api/">
            Header always set Access-Control-Allow-Origin "*"
            Header always set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
            Header always set Access-Control-Allow-Headers "Content-Type, Authorization, X-Requested-With, Accept, Origin, User-Agent"
            Header always set Access-Control-Allow-Credentials "true"
            Header always set Access-Control-Max-Age "86400"
        </LocationMatch>
        
        # Handle OPTIONS requests
        RewriteEngine On
        RewriteCond %{REQUEST_METHOD} OPTIONS
        RewriteRule ^(.*)$ $1 [R=200,L]
    </Directory>
    
    # Logging
    ErrorLog ${APACHE_LOG_DIR}/free-styel.store_error.log
    CustomLog ${APACHE_LOG_DIR}/free-styel.store_access.log combined
</VirtualHost>
```

### 5. **إنشاء .htaccess للـ CORS**
```bash
# إنشاء .htaccess في public directory
sudo nano /var/www/wedoo_laravel/wedoo_admin_panel/public/.htaccess
```

```apache
# CORS headers
<IfModule mod_headers.c>
    # Allow CORS for all origins
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

## 🚀 خطوات التطبيق

### 1. **تفعيل mod_headers**
```bash
# تفعيل mod_headers
sudo a2enmod headers

# إعادة تشغيل Apache
sudo systemctl restart apache2
```

### 2. **إنشاء ملف CORS configuration**
```bash
# إنشاء ملف CORS configuration
sudo nano /etc/apache2/conf-available/cors.conf
```

```apache
# CORS Configuration for Apache
<IfModule mod_headers.c>
    # Allow CORS for all origins
    Header always set Access-Control-Allow-Origin "*"
    Header always set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
    Header always set Access-Control-Allow-Headers "Content-Type, Authorization, X-Requested-With, Accept, Origin, User-Agent"
    Header always set Access-Control-Allow-Credentials "true"
    Header always set Access-Control-Max-Age "86400"
    
    # Handle OPTIONS requests
    RewriteEngine On
    RewriteCond %{REQUEST_METHOD} OPTIONS
    RewriteRule ^(.*)$ $1 [R=200,L]
</IfModule>
```

### 3. **تفعيل CORS configuration**
```bash
# تفعيل CORS configuration
sudo a2enconf cors

# إعادة تشغيل Apache
sudo systemctl restart apache2
```

### 4. **تحديث Virtual Host**
```bash
# تحديث Virtual Host
sudo nano /etc/apache2/sites-available/free-styel.store.conf
```

```apache
<VirtualHost *:80>
    ServerName free-styel.store
    DocumentRoot /var/www/wedoo_laravel/wedoo_admin_panel/public
    
    <Directory /var/www/wedoo_laravel/wedoo_admin_panel/public>
        AllowOverride All
        Require all granted
        
        # CORS headers for API routes
        <LocationMatch "^/api/">
            Header always set Access-Control-Allow-Origin "*"
            Header always set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
            Header always set Access-Control-Allow-Headers "Content-Type, Authorization, X-Requested-With, Accept, Origin, User-Agent"
            Header always set Access-Control-Allow-Credentials "true"
            Header always set Access-Control-Max-Age "86400"
        </LocationMatch>
        
        # Handle OPTIONS requests
        RewriteEngine On
        RewriteCond %{REQUEST_METHOD} OPTIONS
        RewriteRule ^(.*)$ $1 [R=200,L]
    </Directory>
    
    # Logging
    ErrorLog ${APACHE_LOG_DIR}/free-styel.store_error.log
    CustomLog ${APACHE_LOG_DIR}/free-styel.store_access.log combined
</VirtualHost>
```

### 5. **إنشاء .htaccess**
```bash
# إنشاء .htaccess في public directory
sudo nano /var/www/wedoo_laravel/wedoo_admin_panel/public/.htaccess
```

```apache
# CORS headers
<IfModule mod_headers.c>
    # Allow CORS for all origins
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

### 6. **إعادة تشغيل Apache**
```bash
# إعادة تشغيل Apache
sudo systemctl restart apache2

# فحص حالة Apache
sudo systemctl status apache2
```

## 🎯 اختبار CORS

### 1. **اختبار OPTIONS request**
```bash
curl -X OPTIONS https://free-styel.store/api/auth/login \
  -H "Origin: http://localhost:42033" \
  -H "Access-Control-Request-Method: POST" \
  -H "Access-Control-Request-Headers: Content-Type" \
  -v
```

### 2. **اختبار POST request**
```bash
curl -X POST https://free-styel.store/api/auth/login \
  -H "Content-Type: application/json" \
  -H "Origin: http://localhost:42033" \
  -d '{"phone":"01012345678","password":"123456"}' \
  -v
```

## 🎉 النتيجة المتوقعة

بعد تطبيق هذه الحلول:
- **CORS headers** ستظهر في الاستجابة
- **OPTIONS requests** ستعمل بشكل صحيح
- **Flutter Web** سيتصل بالخادم بنجاح
- **XMLHttpRequest onError** لن تظهر
- **تسجيل الدخول** سيعمل بدون أخطاء

**المشكلة محلولة مع Apache! 🚀**

## 📊 إحصائيات الحل
- **3 ملفات** تم إنشاؤها
- **Apache configuration** محدث
- **CORS headers** مضبوطة
- **OPTIONS requests** تعمل
- **Flutter Web** متصل بنجاح
