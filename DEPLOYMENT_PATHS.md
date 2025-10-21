# مسارات النشر على السيرفر الخارجي

## 📁 المسارات المطلوبة:

### 1. ملفات Auth (الأولوية القصوى):
```
/var/www/wedoo_laravel/public/api/auth/login.php
/var/www/wedoo_laravel/public/api/auth/register.php
```

### 2. ملفات API الأخرى:
```
/var/www/wedoo_laravel/public/api/craftsman/count.php
/var/www/wedoo_laravel/public/api/task-types/index.php
/var/www/wedoo_laravel/public/api/orders/create.php
/var/www/wedoo_laravel/public/api/orders/list.php
```

## 🚀 خطوات النشر:

### الطريقة الأولى: SSH
```bash
# 1. الاتصال بالسيرفر
ssh root@vmi2704354.contaboserver.net

# 2. الانتقال للمجلد الصحيح
cd /var/www/wedoo_laravel/public/api

# 3. إنشاء مجلد auth إذا لم يكن موجود
mkdir -p auth

# 4. رفع الملفات المحدثة
# استبدال auth-login-fixed.php بـ login.php
cp /path/to/auth-login-fixed.php auth/login.php

# استبدال auth-register-fixed.php بـ register.php  
cp /path/to/auth-register-fixed.php auth/register.php

# 5. تعيين الصلاحيات
chmod 644 auth/login.php
chmod 644 auth/register.php
```

### الطريقة الثانية: FTP/SFTP
```
Host: free-styel.store
Username: root
Password: [كلمة المرور]
Port: 22

المسارات:
- /var/www/wedoo_laravel/public/api/auth/login.php
- /var/www/wedoo_laravel/public/api/auth/register.php
```

### الطريقة الثالثة: Git Pull
```bash
# إذا كان المشروع على Git
cd /var/www/wedoo_laravel
git pull origin main

# نسخ الملفات المحدثة
cp auth-login-fixed.php public/api/auth/login.php
cp auth-register-fixed.php public/api/auth/register.php
```

## ✅ اختبار النشر:
```bash
# اختبار تسجيل الدخول
curl -X POST "https://free-styel.store/api/auth/login.php" \
  -H "Content-Type: application/json" \
  -d '{"phone":"01000690805","password":"askary20"}'

# اختبار OPTIONS request
curl -X OPTIONS "https://free-styel.store/api/auth/login.php" \
  -H "Origin: http://localhost:3000" \
  -H "Access-Control-Request-Method: POST" \
  -H "Access-Control-Request-Headers: Content-Type"
```

## 🎯 النتيجة المتوقعة:
بعد النشر، يجب أن يعمل:
- ✅ تسجيل الدخول
- ✅ التسجيل  
- ✅ OPTIONS requests (CORS)
- ✅ التطبيق مع السيرفر الخارجي
