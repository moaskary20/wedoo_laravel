# إصلاح ملف .env التالف - تعليمات يدوية

## المشكلة
ملف `.env` يحتوي على رسالة خطأ بدلاً من متغيرات البيئة، مما يمنع Laravel من تحميله.

## الحل السريع

### على السيرفر، نفذ هذه الأوامر:

```bash
cd /var/www/wedoo_laravel/wedoo_admin_panel

# 1. نسخ احتياطي
cp .env .env.backup

# 2. فتح الملف للتحرير
nano .env
```

### في محرر nano:

1. اضغط `Ctrl + W` للبحث
2. ابحث عن: `ErrorException`
3. احذف جميع السطور التي تحتوي على:
   - `ErrorException`
   - `Undefined variable`
   - `Exception trace`
   - `storage/framework/views`
   - أي نص يشبه رسالة الخطأ

4. احفظ الملف: `Ctrl + O` ثم `Enter`
5. اخرج: `Ctrl + X`

### أو استخدم sed لإزالة السطور تلقائياً:

```bash
cd /var/www/wedoo_laravel/wedoo_admin_panel

# نسخ احتياطي
cp .env .env.backup

# إزالة السطور الخاطئة
sed -i '/ErrorException/d' .env
sed -i '/Undefined variable/d' .env
sed -i '/Exception trace/d' .env
sed -i '/storage\/framework\/views/d' .env
sed -i '/LARAVEL.*PHP.*UNHANDLED/d' .env
sed -i '/GET https/d' .env
sed -i '/CODE.*500/d' .env
sed -i '/\$hasError/d' .env
sed -i '/\$errors->has/d' .env
sed -i '/array_filter/d' .env
sed -i '/fn.*Action/d' .env
sed -i '/data-field-wrapper/d' .env
```

### بعد التنظيف:

```bash
# التحقق من الملف
head -20 .env

# يجب أن ترى متغيرات مثل:
# APP_NAME=...
# APP_ENV=...
# APP_KEY=...
# DB_CONNECTION=...

# إذا كان الملف صحيحاً، امسح Cache
php artisan config:clear
php artisan cache:clear
rm -rf storage/framework/views/*

# إعادة بناء Cache
php artisan config:cache
php artisan route:cache
php artisan view:cache

# إعادة تشغيل Apache
systemctl restart apache2
```

## إذا كان الملف تالفاً جداً

إذا كان ملف `.env` تالفاً جداً، يمكنك استعادة النسخة الاحتياطية أو إنشاء ملف جديد:

```bash
# إذا كان لديك نسخة احتياطية
cp .env.backup .env

# أو إنشاء ملف جديد من .env.example
cp .env.example .env

# ثم أعد ملء القيم المطلوبة
nano .env
```

## التحقق من صحة الملف

```bash
# محاولة تحميل الملف
php -r "require 'vendor/autoload.php'; \$dotenv = Dotenv\Dotenv::createImmutable(__DIR__); \$dotenv->load(); echo 'OK';"

# إذا ظهر "OK" فالملف صحيح
```

