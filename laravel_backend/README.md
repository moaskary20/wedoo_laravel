# 🚀 Wedoo Laravel Backend

## 📋 **وصف المشروع:**
نظام إدارة خدمات اليد العاملة (Wedoo) مبني على Laravel مع API endpoints للتعامل مع المستخدمين والطلبات والخدمات.

## 🗂️ **هيكل المشروع:**

```
laravel_backend/
├── app/
│   └── Http/
│       └── Controllers/
│           └── Api/
│               ├── AuthController.php          # تسجيل الدخول والتسجيل
│               ├── CraftsmanController.php     # إدارة الصنايعية
│               ├── OrderController.php         # إدارة الطلبات
│               └── TaskTypeController.php      # أنواع المهام
├── database/
│   ├── migrations/
│   │   ├── create_users_table.php             # جدول المستخدمين
│   │   ├── create_categories_table.php        # جدول الفئات
│   │   ├── create_task_types_table.php        # جدول أنواع المهام
│   │   └── create_orders_table.php            # جدول الطلبات
│   └── seeders/
│       └── DatabaseSeeder.php                  # بيانات أولية
└── routes/
    └── api.php                                 # مسارات API
```

## 🚀 **خطوات الإعداد:**

### **1. تثبيت Laravel:**
```bash
composer create-project laravel/laravel wedoo_laravel
cd wedoo_laravel
```

### **2. نسخ الملفات:**
```bash
# نسخ Controllers
cp app/Http/Controllers/Api/*.php app/Http/Controllers/Api/

# نسخ Migrations
cp database/migrations/*.php database/migrations/

# نسخ Seeders
cp database/seeders/*.php database/seeders/

# نسخ Routes
cp routes/api.php routes/api.php
```

### **3. تشغيل Migrations:**
```bash
php artisan migrate
```

### **4. تشغيل Seeders:**
```bash
php artisan db:seed
```

## 🔗 **API Endpoints:**

### **Authentication:**
- `POST /api/auth/login` - تسجيل الدخول
- `POST /api/auth/register` - التسجيل

### **Task Types:**
- `GET /api/task-types/index?category_id={id}` - أنواع المهام

### **Orders:**
- `POST /api/orders/create` - إنشاء طلب
- `GET /api/orders/list?user_id={id}` - قائمة الطلبات

### **Craftsman:**
- `GET /api/craftsman/count?category_id={id}` - عدد الصنايعية

## 🗄️ **قاعدة البيانات:**

### **الجداول:**
- **users** - المستخدمين (عملاء وصنايعية)
- **categories** - فئات الخدمات
- **task_types** - أنواع المهام
- **orders** - الطلبات

### **البيانات الأولية:**
- 8 فئات خدمات
- 13 نوع مهمة
- مستخدم تجريبي للاختبار

## 🧪 **اختبار النظام:**

```bash
# اختبار تسجيل الدخول
curl -X POST "http://localhost:8000/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"phone":"01000690805","password":"askary20"}'

# اختبار التسجيل
curl -X POST "http://localhost:8000/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","phone":"01234567890","email":"test@example.com","password":"password123","user_type":"customer","governorate":"تونس","city":"تونس العاصمة","district":"المركز"}'

# اختبار أنواع المهام
curl -X GET "http://localhost:8000/api/task-types/index?category_id=3"

# اختبار عدد الصنايعية
curl -X GET "http://localhost:8000/api/craftsman/count?category_id=5"
```

## 🎯 **المميزات:**

- ✅ **نظام تسجيل الدخول والتسجيل** مع Laravel
- ✅ **إدارة المستخدمين** (عملاء وصنايعية)
- ✅ **إدارة الفئات والخدمات**
- ✅ **نظام الطلبات** المرتبط بقاعدة البيانات
- ✅ **API RESTful** للتعامل مع التطبيق
- ✅ **قاعدة بيانات MySQL** مع Migrations
- ✅ **Seeders** للبيانات الأولية

## 📱 **التكامل مع Flutter:**

هذا المشروع مصمم للعمل مع تطبيق Flutter الذي يستخدم:
- `https://free-styel.store/api/` كـ base URL
- نظام تسجيل الدخول والتسجيل
- جلب أنواع المهام والطلبات
- إدارة الصنايعية

## 🚀 **النشر:**

```bash
# نسخ المشروع إلى السيرفر
git clone https://github.com/moaskary20/wedoo_laravel.git

# تثبيت المتطلبات
composer install

# إعداد البيئة
cp .env.example .env
php artisan key:generate

# تشغيل Migrations
php artisan migrate

# تشغيل Seeders
php artisan db:seed

# تشغيل السيرفر
php artisan serve
```

**المشروع جاهز للاستخدام!** 🎉
