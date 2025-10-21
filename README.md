# 🚀 Wedoo - نظام خدمات اليد العاملة

## 📋 **وصف المشروع:**
نظام شامل لإدارة خدمات اليد العاملة يتضمن تطبيق Flutter للهواتف المحمولة و Laravel backend مع API endpoints.

## 🗂️ **هيكل المشروع:**

```
wedoo2/
├── handyman_app/                    # تطبيق Flutter للهواتف المحمولة
│   ├── lib/
│   │   ├── screens/                 # شاشات التطبيق
│   │   ├── models/                  # نماذج البيانات
│   │   └── config/                  # إعدادات API
│   ├── android/                     # إعدادات Android
│   ├── ios/                         # إعدادات iOS
│   ├── web/                         # إعدادات Web
│   └── pubspec.yaml                 # تبعيات Flutter
├── laravel_backend/                 # Laravel Backend
│   ├── Controllers/                 # Laravel Controllers
│   ├── Migrations/                  # قاعدة البيانات
│   ├── Seeders/                     # البيانات الأولية
│   ├── API Files/                   # ملفات API PHP
│   └── Documentation/               # أدلة الإعداد
└── handyman_backend/               # Backend إضافي
```

## 🎯 **المميزات:**

### **📱 تطبيق Flutter:**
- ✅ **واجهة مستخدم عربية** مع دعم RTL
- ✅ **نظام تسجيل الدخول والتسجيل**
- ✅ **إدارة الفئات والخدمات**
- ✅ **نظام الطلبات** مع تتبع الحالة
- ✅ **خرائط Google** لاختيار الموقع
- ✅ **رفع الصور** للمهام
- ✅ **نظام الإشعارات**
- ✅ **إدارة الملف الشخصي**

### **🔧 Laravel Backend:**
- ✅ **API RESTful** للتعامل مع التطبيق
- ✅ **نظام المصادقة** مع JWT
- ✅ **قاعدة بيانات MySQL** مع Migrations
- ✅ **Seeders** للبيانات الأولية
- ✅ **CORS** للتعامل مع التطبيق
- ✅ **إدارة المستخدمين** والطلبات

## 🚀 **خطوات الإعداد:**

### **1. إعداد Laravel Backend:**
```bash
cd laravel_backend

# إنشاء مشروع Laravel جديد
composer create-project laravel/laravel wedoo_laravel
cd wedoo_laravel

# نسخ الملفات
cp ../*Controller.php app/Http/Controllers/Api/
cp ../create_*.php database/migrations/
cp ../DatabaseSeeder.php database/seeders/
cp ../api_routes.php routes/api.php

# تشغيل Migrations
php artisan migrate

# تشغيل Seeders
php artisan db:seed
```

### **2. إعداد Flutter App:**
```bash
cd handyman_app

# تثبيت التبعيات
flutter pub get

# تشغيل التطبيق
flutter run
```

### **3. إعداد قاعدة البيانات:**
```bash
# إنشاء قاعدة البيانات
mysql -u root -p < laravel_backend/create_database.sql

# أو استخدام Laravel Migrations
cd laravel_backend/wedoo_laravel
php artisan migrate
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

### **اختبار Laravel API:**
```bash
# اختبار تسجيل الدخول
curl -X POST "http://localhost:8000/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"phone":"01000690805","password":"askary20"}'

# اختبار التسجيل
curl -X POST "http://localhost:8000/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","phone":"01234567890","email":"test@example.com","password":"password123","user_type":"customer","governorate":"تونس","city":"تونس العاصمة","district":"المركز"}'
```

### **اختبار Flutter App:**
```bash
cd handyman_app
flutter run -d chrome
```

## 📱 **شاشات التطبيق:**

### **الشاشات الرئيسية:**
- **LoginScreen** - تسجيل الدخول
- **CategoryGridScreen** - شبكة الفئات
- **CategoryDetailScreen** - تفاصيل الفئة
- **ServiceRequestForm** - نموذج طلب الخدمة
- **MainNavigationScreen** - التنقل الرئيسي

### **شاشات الإدارة:**
- **SettingsScreen** - الإعدادات
- **EditProfileScreen** - تعديل الملف الشخصي
- **NotificationsScreen** - الإشعارات
- **MyOrdersScreen** - طلباتي

### **شاشات إضافية:**
- **ShopsExhibitionsScreen** - المعارض والمتاجر
- **CraftSecretsScreen** - أسرار الحرف
- **ContactUsScreen** - اتصل بنا

## 🎨 **التصميم:**

### **الألوان:**
- **الخلفية الرئيسية:** `#fec901` (أصفر)
- **النص:** `#333333` (رمادي داكن)
- **الخط:** Cairo (عربي)

### **المكونات:**
- **أزرار مستديرة** مع زوايا ناعمة
- **أيقونات Font Awesome**
- **خرائط Google**
- **رفع الصور**

## 🚀 **النشر:**

### **Laravel Backend:**
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

### **Flutter App:**
```bash
# بناء التطبيق
flutter build apk --release
flutter build ios --release
flutter build web --release
```

## 📚 **الوثائق:**

- **LARAVEL_COMPLETE_SETUP.md** - دليل إعداد Laravel
- **DATABASE_SETUP_GUIDE.md** - دليل قاعدة البيانات
- **CORS_SETUP.md** - إعداد CORS
- **DEPLOYMENT_GUIDE.md** - دليل النشر

## 🎉 **النتيجة النهائية:**

- ✅ **تطبيق Flutter كامل** مع جميع الشاشات
- ✅ **Laravel Backend** مع API endpoints
- ✅ **قاعدة بيانات MySQL** مع البيانات الأولية
- ✅ **نظام المصادقة** والتسجيل
- ✅ **إدارة الطلبات** والخدمات
- ✅ **خرائط Google** ورفع الصور
- ✅ **نظام الإشعارات** والإعدادات

**المشروع جاهز للاستخدام!** 🚀

## 📞 **الدعم:**

للمساعدة أو الاستفسارات، يرجى مراجعة الوثائق في مجلد `laravel_backend/` أو فتح issue في GitHub.
