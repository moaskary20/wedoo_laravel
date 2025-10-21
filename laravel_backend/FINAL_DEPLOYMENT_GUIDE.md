# 🚀 دليل النشر النهائي - حل مشكلة OPTIONS Preflight

## 📋 **المشكلة الحالية:**
التطبيق يواجه مشكلة في الاتصال بالسيرفر الخارجي بسبب عدم معالجة OPTIONS preflight requests بشكل صحيح.

## 🎯 **الحل المطلوب:**
نشر الملفات المحدثة على السيرفر الخارجي لمعالجة OPTIONS requests بشكل صحيح.

---

## 📁 **الملفات المطلوبة للنشر:**

### 1. **ملف تسجيل الدخول المحدث:**
- **الملف المحلي:** `auth-login-options-fixed.php`
- **المسار على السيرفر:** `/var/www/wedoo_laravel/public/api/auth/login.php`

### 2. **ملف التسجيل المحدث:**
- **الملف المحلي:** `auth-register-options-fixed.php`
- **المسار على السيرفر:** `/var/www/wedoo_laravel/public/api/auth/register.php`

---

## 🔧 **خطوات النشر:**

### **الطريقة الأولى: SSH + SCP**

```bash
# 1. الاتصال بالسيرفر
ssh root@vmi2704354.contaboserver.net

# 2. الانتقال للمجلد الصحيح
cd /var/www/wedoo_laravel/public/api

# 3. إنشاء مجلد auth إذا لم يكن موجود
mkdir -p auth

# 4. نسخ احتياطي للملفات الموجودة
cp auth/login.php auth/login.php.backup
cp auth/register.php auth/register.php.backup

# 5. رفع الملفات المحدثة (من جهازك المحلي)
scp auth-login-options-fixed.php root@vmi2704354.contaboserver.net:/var/www/wedoo_laravel/public/api/auth/login.php
scp auth-register-options-fixed.php root@vmi2704354.contaboserver.net:/var/www/wedoo_laravel/public/api/auth/register.php

# 6. تعيين الصلاحيات الصحيحة
chmod 644 /var/www/wedoo_laravel/public/api/auth/login.php
chmod 644 /var/www/wedoo_laravel/public/api/auth/register.php
```

### **الطريقة الثانية: Git + Copy**

```bash
# 1. الاتصال بالسيرفر
ssh root@vmi2704354.contaboserver.net

# 2. الانتقال لمجلد المشروع
cd /var/www/wedoo_laravel

# 3. سحب التحديثات من Git
git pull origin main

# 4. نسخ الملفات المحدثة
cp auth-login-options-fixed.php public/api/auth/login.php
cp auth-register-options-fixed.php public/api/auth/register.php

# 5. تعيين الصلاحيات
chmod 644 public/api/auth/login.php
chmod 644 public/api/auth/register.php
```

### **الطريقة الثالثة: FTP/SFTP**

```bash
# استخدام FileZilla أو أي عميل FTP
# رفع الملفات التالية:
# - auth-login-options-fixed.php → /var/www/wedoo_laravel/public/api/auth/login.php
# - auth-register-options-fixed.php → /var/www/wedoo_laravel/public/api/auth/register.php
```

---

## 🧪 **اختبار النشر:**

### **1. اختبار تسجيل الدخول:**
```bash
curl -X POST "https://free-styel.store/api/auth/login.php" \
  -H "Content-Type: application/json" \
  -d '{"phone":"01000690805","password":"askary20"}' \
  -v
```

### **2. اختبار OPTIONS Preflight:**
```bash
curl -X OPTIONS "https://free-styel.store/api/auth/login.php" \
  -H "Origin: http://localhost:3000" \
  -H "Access-Control-Request-Method: POST" \
  -H "Access-Control-Request-Headers: Content-Type" \
  -v
```

### **3. اختبار التسجيل:**
```bash
curl -X POST "https://free-styel.store/api/auth/register.php" \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","phone":"01234567890","email":"test@example.com","password":"password123","user_type":"customer","governorate":"تونس","city":"تونس العاصمة","district":"المركز"}' \
  -v
```

---

## ✅ **النتائج المتوقعة بعد النشر:**

### **1. تسجيل الدخول:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "مستخدم تجريبي",
    "phone": "01000690805",
    "email": "demo@example.com",
    "user_type": "customer",
    "governorate": "تونس",
    "city": "تونس العاصمة",
    "district": "المركز",
    "membership_code": "558206",
    "status": "active",
    "access_token": "token_...",
    "refresh_token": "refresh_...",
    "login_time": "2025-10-21 03:40:00"
  },
  "message": "Login successful",
  "timestamp": 1761018000
}
```

### **2. OPTIONS Preflight:**
```json
{
  "status": "OK",
  "message": "CORS preflight successful",
  "method": "OPTIONS",
  "timestamp": 1761018000
}
```

### **3. التسجيل:**
```json
{
  "success": true,
  "data": {
    "id": 1234,
    "name": "Test User",
    "phone": "01234567890",
    "email": "test@example.com",
    "user_type": "customer",
    "governorate": "تونس",
    "city": "تونس العاصمة",
    "district": "المركز",
    "membership_code": "WED123456",
    "access_token": "token_...",
    "refresh_token": "refresh_...",
    "created_at": "2025-10-21 03:40:00",
    "status": "active"
  },
  "message": "User registered successfully",
  "timestamp": 1761018000
}
```

---

## 🎯 **بعد النشر:**

1. **اختبار التطبيق:** تشغيل Flutter app واختبار تسجيل الدخول والتسجيل
2. **مراقبة الأخطاء:** التأكد من عدم وجود أخطاء CORS
3. **اختبار جميع الوظائف:** التأكد من عمل جميع APIs

---

## 📞 **الدعم:**

إذا واجهت أي مشاكل في النشر، يمكنك:

1. **التحقق من الصلاحيات:** `ls -la /var/www/wedoo_laravel/public/api/auth/`
2. **مراجعة سجلات الأخطاء:** `tail -f /var/log/apache2/error.log`
3. **اختبار الاتصال:** `ping free-styel.store`

---

## 🎉 **النتيجة النهائية:**

بعد النشر الناجح، سيعمل التطبيق بشكل مثالي مع السيرفر الخارجي `https://free-styel.store/` بدون أي مشاكل CORS أو OPTIONS preflight! 🚀
