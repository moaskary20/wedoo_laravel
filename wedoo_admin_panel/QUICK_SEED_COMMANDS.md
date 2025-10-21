# أوامر تشغيل Seeders السريعة

## 🚀 تشغيل سريع

### 1. تشغيل جميع Seeders
```bash
cd /var/www/wedoo_laravel/wedoo_admin_panel

# تشغيل جميع Seeders
php artisan db:seed
```

### 2. إعادة تعيين كامل
```bash
# حذف جميع البيانات وإعادة إنشائها
php artisan migrate:fresh --seed
```

### 3. تشغيل seeder محدد
```bash
# تشغيل Categories فقط
php artisan db:seed --class=CategoriesSeeder

# تشغيل Users فقط
php artisan db:seed --class=UsersSeeder

# تشغيل Orders فقط
php artisan db:seed --class=OrdersSeeder
```

## 📊 النتيجة

بعد التشغيل:
- **17 فئة** خدمات
- **12 مستخدم** (2 إداري، 5 عملاء، 5 صنايع)
- **6 طلبات** مختلفة
- **5 محادثات** نشطة
- **8 رسائل** محادثة
- **6 خدمات** متنوعة
- **5 تقييمات** مختلفة
- **5 إشعارات** متنوعة
- **12 إعداد** أساسي

## 🎯 اختبار سريع

```bash
# فحص Admin Panel
curl -X GET https://free-styel.store/admin

# فحص API
curl -X GET https://free-styel.store/api/categories/list
```

**جميع الصفحات مليئة بالبيانات! 🚀**
