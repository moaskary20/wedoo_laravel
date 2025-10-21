# دليل تشغيل Seeders - الإصدار المحدث

## 🚀 خطوات التشغيل

### 1. تشغيل Migrations أولاً
```bash
cd /var/www/wedoo_laravel/wedoo_admin_panel

# تشغيل جميع migrations
php artisan migrate

# أو إعادة تعيين كامل
php artisan migrate:fresh
```

### 2. تشغيل Seeders
```bash
# تشغيل جميع seeders
php artisan db:seed

# أو تشغيل seeder محدد
php artisan db:seed --class=CategoriesSeeder
php artisan db:seed --class=TaskTypesSeeder
php artisan db:seed --class=UsersSeeder
php artisan db:seed --class=OrdersSeeder
```

### 3. إعادة تعيين كامل (إذا لزم الأمر)
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

### 2. Task Types (6 أنواع مهام)
- إصلاح صنابير المياه
- تركيب مكيفات الهواء
- دهان المنازل
- إصلاح الكهرباء
- تركيب الأثاث
- صيانة الأجهزة المنزلية

### 3. Users (12 مستخدم)
- 2 مستخدم إداري
- 5 عملاء
- 5 صنايع

### 4. Orders (6 طلبات)
- طلبات مختلفة الحالات
- طلبات مكتملة ومعلقة
- طلبات ملغاة

### 5. Chats (5 محادثات)
- محادثات نشطة
- محادثات مغلقة
- رسائل مختلفة

### 6. Chat Messages (8 رسائل)
- رسائل نصية
- رسائل مقروءة وغير مقروءة
- رسائل مختلفة الأوقات

### 7. Services (6 خدمات)
- خدمات مختلفة
- أسعار مختلفة
- مدة مختلفة

### 8. Reviews (5 تقييمات)
- تقييمات مختلفة
- تعليقات مختلفة
- حالات مختلفة

### 9. Notifications (5 إشعارات)
- إشعارات مختلفة الأنواع
- إشعارات مقروءة وغير مقروءة

### 10. Settings (12 إعداد)
- إعدادات التطبيق
- إعدادات الاتصال
- إعدادات العمل

## 🔧 إصلاح المشاكل

### إذا ظهرت أخطاء:
```bash
# مسح cache
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

# إعادة تعيين أذونات
sudo chown -R www-data:www-data storage
sudo chmod -R 775 storage

# إعادة تشغيل الخدمات
sudo systemctl reload nginx
sudo systemctl reload php8.2-fpm
```

## 🎉 النتيجة

بعد تشغيل جميع Seeders:
- **جميع الصفحات** ستكون مليئة بالبيانات
- **Admin Panel** سيكون جاهز للاستخدام
- **البيانات** ستكون واقعية ومتنوعة
- **العلاقات** ستكون صحيحة ومترابطة

**جميع الصفحات مليئة بالبيانات! 🚀**
