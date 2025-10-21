# 🗄️ دليل إعداد قاعدة البيانات - نظام تسجيل الدخول المرتبط بقاعدة البيانات

## 📋 **الملفات المطلوبة:**

### **1. ملفات قاعدة البيانات:**
- ✅ `database.php` - ملف الاتصال بقاعدة البيانات
- ✅ `create_database.sql` - سكريبت إنشاء قاعدة البيانات والجداول
- ✅ `auth-login-database.php` - تسجيل الدخول المرتبط بقاعدة البيانات
- ✅ `auth-register-database.php` - التسجيل المرتبط بقاعدة البيانات
- ✅ `task-types-database.php` - أنواع المهام من قاعدة البيانات
- ✅ `craftsman-count-database.php` - عدد الصنايعية من قاعدة البيانات
- ✅ `orders-create-database.php` - إنشاء الطلبات في قاعدة البيانات
- ✅ `orders-list-database.php` - قائمة الطلبات من قاعدة البيانات

---

## 🔧 **خطوات الإعداد:**

### **الخطوة 1: إنشاء قاعدة البيانات**
```sql
-- تشغيل ملف create_database.sql
mysql -u root -p < create_database.sql
```

### **الخطوة 2: رفع الملفات للسيرفر**
```bash
# الاتصال بالسيرفر
ssh root@vmi2704354.contaboserver.net

# الانتقال للمجلد
cd /var/www/wedoo_laravel/public/api

# إنشاء المجلدات
mkdir -p auth
mkdir -p orders
mkdir -p task-types
mkdir -p craftsman

# رفع الملفات
scp database.php root@vmi2704354.contaboserver.net:/var/www/wedoo_laravel/public/api/
scp auth-login-database.php root@vmi2704354.contaboserver.net:/var/www/wedoo_laravel/public/api/auth/login.php
scp auth-register-database.php root@vmi2704354.contaboserver.net:/var/www/wedoo_laravel/public/api/auth/register.php
scp task-types-database.php root@vmi2704354.contaboserver.net:/var/www/wedoo_laravel/public/api/task-types/index.php
scp craftsman-count-database.php root@vmi2704354.contaboserver.net:/var/www/wedoo_laravel/public/api/craftsman/count.php
scp orders-create-database.php root@vmi2704354.contaboserver.net:/var/www/wedoo_laravel/public/api/orders/create.php
scp orders-list-database.php root@vmi2704354.contaboserver.net:/var/www/wedoo_laravel/public/api/orders/list.php

# تعيين الصلاحيات
chmod 644 /var/www/wedoo_laravel/public/api/database.php
chmod 644 /var/www/wedoo_laravel/public/api/auth/login.php
chmod 644 /var/www/wedoo_laravel/public/api/auth/register.php
chmod 644 /var/www/wedoo_laravel/public/api/task-types/index.php
chmod 644 /var/www/wedoo_laravel/public/api/craftsman/count.php
chmod 644 /var/www/wedoo_laravel/public/api/orders/create.php
chmod 644 /var/www/wedoo_laravel/public/api/orders/list.php
```

### **الخطوة 3: إنشاء قاعدة البيانات على السيرفر**
```bash
# الاتصال بقاعدة البيانات
mysql -u root -p

# تشغيل سكريبت إنشاء قاعدة البيانات
source /var/www/wedoo_laravel/public/api/create_database.sql
```

---

## 🧪 **اختبار النظام:**

### **1. اختبار تسجيل الدخول:**
```bash
curl -X POST "https://free-styel.store/api/auth/login.php" \
  -H "Content-Type: application/json" \
  -d '{"phone":"01000690805","password":"askary20"}' \
  -v
```

### **2. اختبار التسجيل:**
```bash
curl -X POST "https://free-styel.store/api/auth/register.php" \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","phone":"01234567890","email":"test@example.com","password":"password123","user_type":"customer","governorate":"تونس","city":"تونس العاصمة","district":"المركز"}' \
  -v
```

### **3. اختبار أنواع المهام:**
```bash
curl -X GET "https://free-styel.store/api/task-types/index.php?category_id=3" -v
```

### **4. اختبار عدد الصنايعية:**
```bash
curl -X GET "https://free-styel.store/api/craftsman/count.php?category_id=5" -v
```

---

## 🎯 **المميزات الجديدة:**

### **✅ تسجيل الدخول المرتبط بقاعدة البيانات:**
- التحقق من بيانات المستخدم من قاعدة البيانات
- دعم المستخدمين الجدد
- حفظ جلسات المستخدمين

### **✅ التسجيل المرتبط بقاعدة البيانات:**
- حفظ المستخدمين الجدد في قاعدة البيانات
- إنشاء رمز عضوية فريد
- التحقق من عدم تكرار البيانات

### **✅ أنواع المهام من قاعدة البيانات:**
- جلب أنواع المهام من قاعدة البيانات
- دعم إضافة أنواع مهام جديدة
- ربط أنواع المهام بالفئات

### **✅ عدد الصنايعية من قاعدة البيانات:**
- حساب عدد الصنايعية الفعلي من قاعدة البيانات
- دعم إضافة صنايعية جدد

### **✅ نظام الطلبات المرتبط بقاعدة البيانات:**
- حفظ الطلبات في قاعدة البيانات
- ربط الطلبات بالمستخدمين وأنواع المهام
- تتبع حالة الطلبات

---

## 🎉 **النتيجة النهائية:**

بعد الإعداد، سيعمل التطبيق بشكل كامل مع قاعدة البيانات:
- ✅ تسجيل الدخول والتسجيل من قاعدة البيانات
- ✅ أنواع المهام من قاعدة البيانات
- ✅ عدد الصنايعية من قاعدة البيانات
- ✅ نظام الطلبات المرتبط بقاعدة البيانات
- ✅ دعم المستخدمين الجدد
- ✅ حفظ البيانات بشكل دائم

**النظام جاهز للاستخدام مع قاعدة البيانات!** 🚀
