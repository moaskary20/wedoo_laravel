# 🚨 URGENT: رفع ملفات التسجيل والدخول إلى السيرفر الخارجي

## 📋 الملفات المطلوب رفعها:

### 1. ملف تسجيل الدخول
**المسار المحلي:** `free-styel-api-simple/auth/login.php`  
**المسار على السيرفر:** `/var/www/wedoo_laravel/public/api/auth/login.php`

### 2. ملف التسجيل
**المسار المحلي:** `free-styel-api-simple/auth/register.php`  
**المسار على السيرفر:** `/var/www/wedoo_laravel/public/api/auth/register.php`

## 🚀 خطوات الرفع:

### الطريقة الأولى: رفع مباشر
```bash
# 1. الاتصال بالسيرفر
ssh root@vmi2704354.contaboserver.net

# 2. إنشاء مجلد auth إذا لم يكن موجوداً
mkdir -p /var/www/wedoo_laravel/public/api/auth

# 3. رفع الملفات (استخدم SCP أو SFTP)
scp free-styel-api-simple/auth/login.php root@vmi2704354.contaboserver.net:/var/www/wedoo_laravel/public/api/auth/
scp free-styel-api-simple/auth/register.php root@vmi2704354.contaboserver.net:/var/www/wedoo_laravel/public/api/auth/

# 4. تعيين الصلاحيات
chmod 644 /var/www/wedoo_laravel/public/api/auth/login.php
chmod 644 /var/www/wedoo_laravel/public/api/auth/register.php
```

### الطريقة الثانية: Git Pull
```bash
# 1. الاتصال بالسيرفر
ssh root@vmi2704354.contaboserver.net

# 2. الانتقال لمجلد المشروع
cd /var/www/wedoo_laravel

# 3. سحب التحديثات من GitHub
git pull origin main

# 4. نسخ الملفات إلى المسار الصحيح
cp free-styel-api-simple/auth/login.php public/api/auth/
cp free-styel-api-simple/auth/register.php public/api/auth/

# 5. تعيين الصلاحيات
chmod 644 public/api/auth/login.php
chmod 644 public/api/auth/register.php
```

## 🧪 اختبار الملفات:

### اختبار تسجيل الدخول:
```bash
curl -X POST "https://free-styel.store/api/auth/login.php" \
  -H "Content-Type: application/json" \
  -d '{"phone":"01000690805","password":"askary20"}'
```

### اختبار التسجيل:
```bash
curl -X POST "https://free-styel.store/api/auth/register.php" \
  -H "Content-Type: application/json" \
  -d '{"name":"أحمد محمد","phone":"01234567890","email":"ahmed@example.com","password":"password123","user_type":"customer","governorate":"تونس","city":"تونس العاصمة","district":"المركز"}'
```

## ⚠️ ملاحظات مهمة:

1. **تأكد من وجود مجلد `auth`** في `/var/www/wedoo_laravel/public/api/`
2. **تحقق من الصلاحيات** (644 للملفات)
3. **اختبر الملفات** بعد الرفع مباشرة
4. **تأكد من CORS headers** في الملفات

## 🎯 النتيجة المتوقعة:

بعد رفع الملفات بنجاح، يجب أن تعمل:
- ✅ تسجيل المستخدمين الجدد
- ✅ دخول المستخدمين المسجلين
- ✅ حفظ البيانات في السيرفر
- ✅ استرجاع البيانات عند الدخول

---
**تاريخ الإنشاء:** $(date)  
**الحالة:** عاجل - مطلوب رفع فوري
