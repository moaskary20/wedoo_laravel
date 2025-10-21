# 🚀 دليل الإعداد الكامل لـ Laravel - نظام Wedoo

## 📋 **الملفات المطلوبة:**

### **1. Migrations:**
- ✅ `create_users_table.php` - جدول المستخدمين
- ✅ `create_categories_table.php` - جدول الفئات  
- ✅ `create_task_types_table.php` - جدول أنواع المهام
- ✅ `create_orders_table.php` - جدول الطلبات
- ✅ `DatabaseSeeder.php` - Seeder للبيانات الأولية

### **2. Controllers:**
- ✅ `AuthController.php` - تسجيل الدخول والتسجيل
- ✅ `TaskTypeController.php` - أنواع المهام
- ✅ `OrderController.php` - الطلبات
- ✅ `CraftsmanController.php` - عدد الصنايعية

### **3. Routes:**
- ✅ `api_routes.php` - مسارات الـ API

---

## 🔧 **خطوات الإعداد الكامل:**

### **الخطوة 1: إنشاء Migrations**
```bash
# الانتقال لمجلد Laravel
cd /var/www/wedoo_laravel

# إنشاء migrations
php artisan make:migration create_users_table
php artisan make:migration create_categories_table  
php artisan make:migration create_task_types_table
php artisan make:migration create_orders_table

# إنشاء seeder
php artisan make:seeder DatabaseSeeder
```

### **الخطوة 2: نسخ محتوى الملفات**

#### **A. نسخ Migrations:**
```bash
# نسخ محتوى create_users_table.php إلى:
# database/migrations/YYYY_MM_DD_HHMMSS_create_users_table.php

# نسخ محتوى create_categories_table.php إلى:
# database/migrations/YYYY_MM_DD_HHMMSS_create_categories_table.php

# نسخ محتوى create_task_types_table.php إلى:
# database/migrations/YYYY_MM_DD_HHMMSS_create_task_types_table.php

# نسخ محتوى create_orders_table.php إلى:
# database/migrations/YYYY_MM_DD_HHMMSS_create_orders_table.php
```

#### **B. نسخ Seeder:**
```bash
# نسخ محتوى DatabaseSeeder.php إلى:
# database/seeders/DatabaseSeeder.php
```

#### **C. نسخ Controllers:**
```bash
# نسخ محتوى AuthController.php إلى:
# app/Http/Controllers/Api/AuthController.php

# نسخ محتوى TaskTypeController.php إلى:
# app/Http/Controllers/Api/TaskTypeController.php

# نسخ محتوى OrderController.php إلى:
# app/Http/Controllers/Api/OrderController.php

# نسخ محتوى CraftsmanController.php إلى:
# app/Http/Controllers/Api/CraftsmanController.php
```

#### **D. نسخ Routes:**
```bash
# نسخ محتوى api_routes.php إلى:
# routes/api.php
```

### **الخطوة 3: تشغيل Migrations و Seeders**
```bash
# تشغيل migrations
php artisan migrate

# تشغيل seeders
php artisan db:seed
```

### **الخطوة 4: اختبار النظام**
```bash
# اختبار تسجيل الدخول
curl -X POST "https://free-styel.store/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"phone":"01000690805","password":"askary20"}' \
  -v

# اختبار التسجيل
curl -X POST "https://free-styel.store/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","phone":"01234567890","email":"test@example.com","password":"password123","user_type":"customer","governorate":"تونس","city":"تونس العاصمة","district":"المركز"}' \
  -v

# اختبار أنواع المهام
curl -X GET "https://free-styel.store/api/task-types/index?category_id=3" -v

# اختبار عدد الصنايعية
curl -X GET "https://free-styel.store/api/craftsman/count?category_id=5" -v
```

---

## 🎯 **المميزات الجديدة:**

### **✅ نظام Laravel كامل:**
- Migrations للجداول
- Seeders للبيانات الأولية
- Controllers للـ API
- Routes للـ API
- قاعدة بيانات MySQL

### **✅ تسجيل الدخول والتسجيل:**
- التحقق من بيانات المستخدم من قاعدة البيانات
- دعم المستخدمين الجدد
- حفظ جلسات المستخدمين

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

بعد الإعداد، سيعمل التطبيق بشكل كامل مع Laravel:
- ✅ Migrations للجداول
- ✅ Seeders للبيانات الأولية
- ✅ API Controllers
- ✅ Routes للـ API
- ✅ قاعدة بيانات MySQL
- ✅ نظام تسجيل الدخول والتسجيل
- ✅ أنواع المهام من قاعدة البيانات
- ✅ عدد الصنايعية من قاعدة البيانات
- ✅ نظام الطلبات المرتبط بقاعدة البيانات
- ✅ دعم المستخدمين الجدد
- ✅ حفظ البيانات بشكل دائم

**النظام جاهز للاستخدام مع Laravel!** 🚀
