#!/bin/bash

# ==========================================
# سكريبت إصلاح ملف .env التالف
# ==========================================

echo "=========================================="
echo "إصلاح ملف .env التالف"
echo "=========================================="

cd /var/www/wedoo_laravel/wedoo_admin_panel || exit 1

# 1. نسخ احتياطي لملف .env
echo "1. إنشاء نسخة احتياطية من .env..."
cp .env .env.backup.$(date +%Y%m%d_%H%M%S)
echo "✓ تم إنشاء النسخة الاحتياطية"

# 2. البحث عن السطور الخاطئة
echo ""
echo "2. البحث عن السطور الخاطئة في .env..."
grep -n "ErrorException\|Undefined variable\|Exception trace" .env || echo "لم يتم العثور على أخطاء واضحة"

# 3. إزالة السطور التي تحتوي على رسائل الخطأ
echo ""
echo "3. تنظيف ملف .env..."
# إزالة السطور التي تحتوي على ErrorException أو Exception trace
sed -i '/ErrorException/d' .env
sed -i '/Undefined variable/d' .env
sed -i '/Exception trace/d' .env
sed -i '/storage\/framework\/views/d' .env
sed -i '/LARAVEL.*PHP.*UNHANDLED/d' .env
sed -i '/GET https/d' .env
sed -i '/CODE.*500/d' .env
sed -i '/\$hasError.*filled/d' .env
sed -i '/\$errors->has/d' .env
sed -i '/array_filter/d' .env
sed -i '/fn.*Action/d' .env
sed -i '/data-field-wrapper/d' .env
sed -i '/fi-fo-field-wrp/d' .env

# إزالة السطور الفارغة الزائدة
sed -i '/^$/N;/^\n$/D' .env

echo "✓ تم تنظيف ملف .env"

# 4. التحقق من صحة الملف
echo ""
echo "4. التحقق من صحة ملف .env..."
if php -r "require 'vendor/autoload.php'; \$dotenv = Dotenv\Dotenv::createImmutable(__DIR__); \$dotenv->load(); echo 'OK';" 2>/dev/null; then
    echo "✓ ملف .env صحيح"
else
    echo "⚠ تحذير: قد يكون هناك مشاكل أخرى في ملف .env"
    echo "تحقق من السطور التالية:"
    grep -n "=" .env | tail -5
fi

# 5. مسح Cache
echo ""
echo "5. مسح Cache..."
php artisan config:clear 2>/dev/null || echo "⚠ فشل مسح config cache"
php artisan cache:clear 2>/dev/null || echo "⚠ فشل مسح cache"

# 6. حذف compiled views
echo ""
echo "6. حذف compiled views..."
rm -rf storage/framework/views/*
echo "✓ تم حذف compiled views"

# 7. إعادة بناء Cache
echo ""
echo "7. إعادة بناء Cache..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

echo ""
echo "=========================================="
echo "✅ تم الانتهاء!"
echo "=========================================="
echo ""
echo "الآن جرب:"
echo "php artisan config:clear"
echo ""

