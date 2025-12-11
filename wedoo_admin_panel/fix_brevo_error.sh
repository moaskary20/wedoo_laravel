#!/bin/bash

# ==========================================
# سكريبت إصلاح مشكلة Undefined variable $errors
# للاستخدام على السيرفر: ssh root@144.91.106.22
# ==========================================

echo "=========================================="
echo "بدء إصلاح مشكلة Brevo Settings"
echo "=========================================="

# الانتقال إلى مجلد المشروع
cd /var/www/wedoo_laravel/wedoo_admin_panel || {
    echo "❌ خطأ: لا يمكن الوصول إلى مجلد المشروع!"
    exit 1
}

echo "✓ الانتقال إلى مجلد المشروع: $(pwd)"

# 1. سحب آخر التحديثات
echo ""
echo "1. سحب آخر التحديثات من GitHub..."
git pull origin main
if [ $? -eq 0 ]; then
    echo "✓ تم سحب التحديثات بنجاح"
else
    echo "⚠ تحذير: فشل سحب التحديثات (قد يكون الكود محدثاً بالفعل)"
fi

# 2. التحقق من الملفات المهمة
echo ""
echo "2. التحقق من الملفات المهمة..."
if [ -f "resources/views/filament/pages/brevo-settings.blade.php" ]; then
    echo "✓ ملف Blade template موجود"
else
    echo "❌ خطأ: ملف Blade template غير موجود!"
    exit 1
fi

if [ -f "app/Filament/Pages/BrevoSettings.php" ]; then
    echo "✓ ملف BrevoSettings.php موجود"
else
    echo "❌ خطأ: ملف BrevoSettings.php غير موجود!"
    exit 1
fi

# 3. مسح جميع الـ Cache
echo ""
echo "3. مسح جميع الـ Cache..."
php artisan config:clear && echo "✓ تم مسح config cache"
php artisan cache:clear && echo "✓ تم مسح application cache"
php artisan view:clear && echo "✓ تم مسح view cache"
php artisan route:clear && echo "✓ تم مسح route cache"

# 4. حذف compiled views القديمة (مهم جداً!)
echo ""
echo "4. حذف compiled views القديمة..."
if [ -d "storage/framework/views" ]; then
    rm -rf storage/framework/views/*
    echo "✓ تم حذف جميع compiled views"
else
    echo "⚠ تحذير: مجلد views غير موجود"
fi

# 5. إعادة بناء Cache
echo ""
echo "5. إعادة بناء Cache..."
php artisan config:cache && echo "✓ تم بناء config cache"
php artisan route:cache && echo "✓ تم بناء route cache"
php artisan view:cache && echo "✓ تم بناء view cache"

# 6. إصلاح الصلاحيات
echo ""
echo "6. إصلاح الصلاحيات..."
chmod -R 775 storage bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache
echo "✓ تم إصلاح الصلاحيات"

# 7. إعادة تشغيل Apache
echo ""
echo "7. إعادة تشغيل Apache..."
if systemctl is-active --quiet apache2; then
    systemctl restart apache2
    echo "✓ تم إعادة تشغيل Apache"
else
    echo "⚠ تحذير: Apache غير نشط"
    systemctl start apache2
    echo "✓ تم تشغيل Apache"
fi

# 8. التحقق من حالة Apache
echo ""
echo "8. التحقق من حالة Apache..."
systemctl status apache2 --no-pager -l | head -10

# 9. التحقق من آخر خطأ في Laravel
echo ""
echo "9. آخر 5 أسطر من Laravel log..."
if [ -f "storage/logs/laravel.log" ]; then
    tail -5 storage/logs/laravel.log
else
    echo "⚠ لا يوجد ملف log"
fi

echo ""
echo "=========================================="
echo "✅ تم الانتهاء من الإصلاح!"
echo "=========================================="
echo ""
echo "الآن جرب فتح الصفحة:"
echo "https://free-styel.store/admin/brevo-settings"
echo ""
echo "إذا استمرت المشكلة، تحقق من:"
echo "tail -f storage/logs/laravel.log"
echo "tail -f /var/log/apache2/error.log"
echo ""

