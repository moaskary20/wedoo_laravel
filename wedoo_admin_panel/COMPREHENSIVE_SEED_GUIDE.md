# دليل تشغيل Seeders الشامل

## 🎯 الهدف
ملء جميع الصفحات في Laravel Admin Panel بالبيانات اللازمة

## 📋 الملفات المطلوبة

### 1. Models المطلوبة
```bash
# إنشاء Models
php artisan make:model Service -m
php artisan make:model Review -m
php artisan make:model Notification -m
php artisan make:model Setting -m
```

### 2. Migrations المطلوبة
```bash
# إنشاء Migrations
php artisan make:migration create_services_table
php artisan make:migration create_reviews_table
php artisan make:migration create_notifications_table
php artisan make:migration create_settings_table
```

## 🚀 تشغيل Seeders

### 1. تشغيل جميع Seeders
```bash
cd /var/www/wedoo_laravel/wedoo_admin_panel

# تشغيل جميع Seeders
php artisan db:seed

# أو تشغيل seeder محدد
php artisan db:seed --class=CategoriesSeeder
php artisan db:seed --class=UsersSeeder
php artisan db:seed --class=OrdersSeeder
php artisan db:seed --class=ChatsSeeder
php artisan db:seed --class=ChatMessagesSeeder
php artisan db:seed --class=ServicesSeeder
php artisan db:seed --class=ReviewsSeeder
php artisan db:seed --class=NotificationsSeeder
php artisan db:seed --class=SettingsSeeder
```

### 2. إعادة تعيين قاعدة البيانات
```bash
# حذف جميع البيانات وإعادة إنشائها
php artisan migrate:fresh --seed
```

## 📊 البيانات التي سيتم إنشاؤها

### 1. Categories (17 فئة)
- خدمات صيانة المنازل
- خدمات السباكة
- خدمات الكهرباء
- خدمات التكييف
- خدمات الدهان
- خدمات النجارة
- خدمات صيانة الأجهزة
- خدمات التنظيف
- خدمات الأمن
- خدمات البستنة
- خدمات النقل
- خدمات التصميم
- خدمات الاستشارات
- خدمات التدريب
- خدمات التطوير
- خدمات التسويق
- خدمات الدعم الفني

### 2. Users (12 مستخدم)
- 2 مستخدم إداري
- 5 عملاء
- 5 صنايع

### 3. Orders (6 طلبات)
- طلبات مختلفة الحالات
- طلبات مكتملة ومعلقة
- طلبات ملغاة

### 4. Chats (5 محادثات)
- محادثات نشطة
- محادثات مغلقة
- رسائل مختلفة

### 5. Chat Messages (8 رسائل)
- رسائل نصية
- رسائل مقروءة وغير مقروءة
- رسائل مختلفة الأوقات

### 6. Services (6 خدمات)
- خدمات مختلفة
- أسعار مختلفة
- مدة مختلفة

### 7. Reviews (5 تقييمات)
- تقييمات مختلفة
- تعليقات مختلفة
- حالات مختلفة

### 8. Notifications (5 إشعارات)
- إشعارات مختلفة الأنواع
- إشعارات مقروءة وغير مقروءة

### 9. Settings (12 إعداد)
- إعدادات التطبيق
- إعدادات الاتصال
- إعدادات العمل

## 🔧 إعدادات إضافية

### 1. تحديث App Key
```bash
php artisan key:generate
```

### 2. مسح Cache
```bash
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
```

### 3. إعادة تعيين أذونات
```bash
sudo chown -R www-data:www-data storage
sudo chmod -R 775 storage
```

## 🎉 النتيجة

بعد تشغيل جميع Seeders:
- **جميع الصفحات** ستكون مليئة بالبيانات
- **Admin Panel** سيكون جاهز للاستخدام
- **البيانات** ستكون واقعية ومتنوعة
- **العلاقات** ستكون صحيحة

## 📱 اختبار النتيجة

### 1. فحص Admin Panel
```
https://free-styel.store/admin
```

### 2. فحص API
```bash
curl -X GET https://free-styel.store/api/categories/list
```

### 3. فحص البيانات
- فحص المستخدمين
- فحص الطلبات
- فحص المحادثات
- فحص الخدمات

**جميع الصفحات مليئة بالبيانات! 🚀**
