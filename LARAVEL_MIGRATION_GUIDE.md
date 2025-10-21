# 🚀 دليل إنشاء Migrations في Laravel

## 📋 **الملفات المطلوبة:**

### **1. Migrations:**
- ✅ `create_users_table.php` - جدول المستخدمين
- ✅ `create_categories_table.php` - جدول الفئات
- ✅ `create_task_types_table.php` - جدول أنواع المهام
- ✅ `create_orders_table.php` - جدول الطلبات
- ✅ `DatabaseSeeder.php` - Seeder للبيانات الأولية

---

## 🔧 **خطوات الإعداد:**

### **الخطوة 1: إنشاء Migrations في Laravel**
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
```bash
# نسخ محتوى create_users_table.php إلى:
# database/migrations/YYYY_MM_DD_HHMMSS_create_users_table.php

# نسخ محتوى create_categories_table.php إلى:
# database/migrations/YYYY_MM_DD_HHMMSS_create_categories_table.php

# نسخ محتوى create_task_types_table.php إلى:
# database/migrations/YYYY_MM_DD_HHMMSS_create_task_types_table.php

# نسخ محتوى create_orders_table.php إلى:
# database/migrations/YYYY_MM_DD_HHMMSS_create_orders_table.php

# نسخ محتوى DatabaseSeeder.php إلى:
# database/seeders/DatabaseSeeder.php
```

### **الخطوة 3: تشغيل Migrations**
```bash
# تشغيل migrations
php artisan migrate

# تشغيل seeders
php artisan db:seed
```

### **الخطوة 4: إنشاء API Controllers**
```bash
# إنشاء controllers
php artisan make:controller Api/AuthController
php artisan make:controller Api/TaskTypeController
php artisan make:controller Api/OrderController
php artisan make:controller Api/CraftsmanController
```

---

## 🎯 **API Routes المطلوبة:**

### **في `routes/api.php`:**
```php
<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\TaskTypeController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\CraftsmanController;

// Auth routes
Route::post('/auth/login', [AuthController::class, 'login']);
Route::post('/auth/register', [AuthController::class, 'register']);

// Task types routes
Route::get('/task-types/index', [TaskTypeController::class, 'index']);

// Orders routes
Route::post('/orders/create', [OrderController::class, 'create']);
Route::get('/orders/list', [OrderController::class, 'list']);

// Craftsman routes
Route::get('/craftsman/count', [CraftsmanController::class, 'count']);
```

---

## 🧪 **اختبار النظام:**

### **1. اختبار تسجيل الدخول:**
```bash
curl -X POST "https://free-styel.store/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"phone":"01000690805","password":"askary20"}' \
  -v
```

### **2. اختبار التسجيل:**
```bash
curl -X POST "https://free-styel.store/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","phone":"01234567890","email":"test@example.com","password":"password123","user_type":"customer","governorate":"تونس","city":"تونس العاصمة","district":"المركز"}' \
  -v
```

### **3. اختبار أنواع المهام:**
```bash
curl -X GET "https://free-styel.store/api/task-types/index?category_id=3" -v
```

### **4. اختبار عدد الصنايعية:**
```bash
curl -X GET "https://free-styel.store/api/craftsman/count?category_id=5" -v
```

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

**النظام جاهز للاستخدام مع Laravel!** 🚀
