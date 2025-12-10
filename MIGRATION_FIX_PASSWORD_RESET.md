# حل مشكلة Migration: password_reset_tokens

## المشكلة
```
SQLSTATE[42S01]: Base table or view already exists: 1050 
Table 'password_reset_tokens' already exists
```

## السبب
الجدول `password_reset_tokens` موجود بالفعل من migration أخرى (`0001_01_01_000000_create_users_table.php`)، لكن migration جديدة (`2025_11_28_131937_create_password_reset_tokens_table.php`) تحاول إنشاء نفس الجدول مرة أخرى.

## الحل المطبق ✅
تم تعديل migration `2025_11_28_131937_create_password_reset_tokens_table.php` للتحقق من وجود الجدول أولاً قبل إنشائه:

```php
if (!Schema::hasTable('password_reset_tokens')) {
    Schema::create('password_reset_tokens', function (Blueprint $table) {
        // ...
    });
}
```

## خطوات التشغيل على السيرفر

### الطريقة 1: تشغيل Migration مباشرة
```bash
cd /var/www/wedoo_laravel/wedoo_admin_panel
git pull origin main
php artisan migrate --force
```

### الطريقة 2: تخطي Migration معينة (إذا استمرت المشكلة)
```bash
# تخطي migration معينة
php artisan migrate --path=database/migrations/2025_01_21_000001_create_craftsman_task_types_table.php --force

# أو تشغيل جميع migrations عدا المحددة
php artisan migrate --force --pretend  # للتحقق أولاً
```

### الطريقة 3: حذف Migration من جدول migrations (إذا تم تشغيلها بالفعل)
```bash
# الدخول إلى MySQL
mysql -u username -p database_name

# حذف السجل من جدول migrations
DELETE FROM migrations WHERE migration = '2025_11_28_131937_create_password_reset_tokens_table';

# ثم تشغيل migration مرة أخرى
php artisan migrate --force
```

## التحقق من النجاح

```bash
# التحقق من حالة Migrations
php artisan migrate:status

# التحقق من وجود الجدول
php artisan tinker
>>> Schema::hasTable('password_reset_tokens')
# يجب أن يعيد: true
>>> exit
```

## ملاحظات مهمة

1. **لا تقم بحذف الجدول** `password_reset_tokens` إذا كان يحتوي على بيانات مهمة
2. **النسخة الاحتياطية**: دائماً اعمل نسخة احتياطية قبل تشغيل migrations
3. **التحقق**: استخدم `--pretend` أولاً لمعرفة ما سيحدث دون تنفيذ

## حلول بديلة

### إذا أردت تحديث بنية الجدول الموجود:
يمكنك إنشاء migration جديدة لتعديل الجدول:

```bash
php artisan make:migration update_password_reset_tokens_table
```

ثم في migration الجديدة:
```php
public function up(): void
{
    Schema::table('password_reset_tokens', function (Blueprint $table) {
        // إضافة أو تعديل الأعمدة
    });
}
```

---

**تم الإصلاح**: ✅ Migration الآن تتحقق من وجود الجدول قبل إنشائه

