# دليل تشغيل Migrations على السيرفر الخارجي

## 📋 الخطوات المطلوبة

### 1. الاتصال بالسيرفر

#### عبر SSH:
```bash
ssh username@free-styel.store
# أو
ssh username@your-server-ip
```

### 2. الانتقال إلى مجلد المشروع

```bash
# إذا كان المشروع في مجلد wedoo_admin_panel
cd /var/www/wedoo_admin_panel
# أو
cd /path/to/wedoo_admin_panel

# التحقق من المسار الصحيح
pwd
ls -la
```

### 3. تحديث الكود من GitHub (إذا لزم الأمر)

```bash
# التحقق من الفرع الحالي
git branch

# جلب آخر التحديثات
git fetch origin

# دمج التحديثات
git pull origin main

# أو إذا كنت على فرع آخر
git checkout main
git pull origin main
```

### 4. التحقق من وجود Migration الجديدة

```bash
# التحقق من وجود ملف Migration الجديد
ls -la database/migrations/ | grep craftsman_task_types

# يجب أن ترى:
# 2025_01_21_000001_create_craftsman_task_types_table.php
```

### 5. تشغيل Migrations

#### الطريقة الآمنة (مع التحقق):
```bash
# أولاً: التحقق من Migrations التي سيتم تشغيلها
php artisan migrate:status

# ثم: تشغيل Migrations الجديدة فقط
php artisan migrate
```

#### الطريقة المباشرة (للإنتاج):
```bash
# تشغيل جميع Migrations الجديدة
php artisan migrate --force

# ملاحظة: --force يلغي التأكيد في بيئة الإنتاج
```

### 6. التحقق من نجاح Migration

```bash
# التحقق من أن الجدول تم إنشاؤه
php artisan tinker
>>> Schema::hasTable('craftsman_task_types')
# يجب أن يعيد: true

>>> exit
```

أو عبر MySQL مباشرة:
```bash
mysql -u your_username -p your_database_name
mysql> SHOW TABLES LIKE 'craftsman_task_types';
mysql> DESCRIBE craftsman_task_types;
mysql> exit;
```

## 🔧 أوامر إضافية مفيدة

### مسح Cache بعد Migration:
```bash
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear
```

### إعادة بناء Cache (للأداء):
```bash
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

### التحقق من حالة Migrations:
```bash
# عرض جميع Migrations وحالتها
php artisan migrate:status
```

### Rollback (إذا احتجت التراجع):
```bash
# التراجع عن آخر migration
php artisan migrate:rollback

# التراجع عن آخر 3 migrations
php artisan migrate:rollback --step=3
```

## ⚠️ ملاحظات مهمة

1. **النسخ الاحتياطي**: قبل تشغيل migrations على الإنتاج، تأكد من عمل نسخة احتياطية:
   ```bash
   mysqldump -u username -p database_name > backup_$(date +%Y%m%d_%H%M%S).sql
   ```

2. **التحقق من .env**: تأكد من أن ملف `.env` يحتوي على بيانات قاعدة البيانات الصحيحة:
   ```bash
   cat .env | grep DB_
   ```

3. **الأذونات**: تأكد من أن Laravel لديه أذونات الكتابة:
   ```bash
   chmod -R 775 storage bootstrap/cache
   chown -R www-data:www-data storage bootstrap/cache
   ```

4. **البيئة**: تأكد من أنك في بيئة الإنتاج:
   ```bash
   php artisan env
   # أو
   cat .env | grep APP_ENV
   ```

## 🚀 سكريبت سريع (كل الأوامر معاً)

```bash
#!/bin/bash
# تشغيل Migrations على السيرفر

# 1. الانتقال للمجلد
cd /var/www/wedoo_admin_panel

# 2. جلب التحديثات
git pull origin main

# 3. تحديث Composer (إذا لزم الأمر)
composer install --no-dev --optimize-autoloader

# 4. تشغيل Migrations
    php artisan migrate --force

# 5. مسح Cache
php artisan config:clear
php artisan cache:clear
php artisan route:clear

# 6. إعادة بناء Cache
php artisan config:cache
php artisan route:cache

echo "✅ تم تشغيل Migrations بنجاح!"
```

## 📝 مثال كامل للتنفيذ

```bash
# 1. الاتصال بالسيرفر
ssh user@free-styel.store

# 2. الانتقال للمجلد
cd /var/www/wedoo_admin_panel

# 3. التحقق من Git
git status
git pull origin main

# 4. التحقق من Migration
ls database/migrations/2025_01_21_000001_create_craftsman_task_types_table.php

# 5. تشغيل Migration
php artisan migrate --force

# 6. التحقق من النجاح
php artisan tinker
>>> Schema::hasTable('craftsman_task_types')
>>> exit

# 7. مسح Cache
php artisan config:clear
php artisan cache:clear

# 8. إعادة بناء Cache
php artisan config:cache
php artisan route:cache

echo "✅ تم!"
```

## 🔍 استكشاف الأخطاء

### خطأ: "Migration table not found"
```bash
# إنشاء جدول migrations إذا لم يكن موجوداً
php artisan migrate:install
```

### خطأ: "Class not found"
```bash
# تحديث autoloader
composer dump-autoload
```

### خطأ: "Permission denied"
```bash
# إصلاح الأذونات
sudo chown -R www-data:www-data storage bootstrap/cache
sudo chmod -R 775 storage bootstrap/cache
```

### خطأ: "Connection refused"
```bash
# التحقق من إعدادات قاعدة البيانات
php artisan tinker
>>> DB::connection()->getPdo();
```

## ✅ التحقق النهائي

بعد تشغيل Migration، تحقق من:

1. **الجدول موجود:**
   ```bash
   php artisan tinker
   >>> DB::table('craftsman_task_types')->get();
   ```

2. **العلاقات تعمل:**
   ```bash
   php artisan tinker
   >>> $user = App\Models\User::find(1);
   >>> $user->taskTypes();
   ```

3. **API يعمل:**
   ```bash
   curl https://free-styel.store/api/task-types/index?category_id=1
   ```

