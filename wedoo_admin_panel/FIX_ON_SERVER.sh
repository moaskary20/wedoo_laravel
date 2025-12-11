#!/bin/bash

# سكريبت إصلاح مشكلة Undefined variable $errors على السيرفر
# للاستخدام: ssh root@144.91.106.22 ثم تشغيل هذا السكريبت

echo "=========================================="
echo "إصلاح مشكلة Brevo Settings على السيرفر"
echo "=========================================="

# الانتقال إلى مجلد المشروع
cd /var/www/wedoo_laravel/wedoo_admin_panel

echo "1. سحب آخر التحديثات من GitHub..."
git pull origin main

echo "2. مسح جميع الـ Cache..."
php artisan config:clear
php artisan cache:clear
php artisan view:clear
php artisan route:clear

echo "3. حذف compiled views القديمة..."
rm -rf storage/framework/views/*

echo "4. إعادة بناء Cache..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

echo "5. إصلاح الصلاحيات..."
chmod -R 775 storage bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache

echo "6. إعادة تشغيل Apache..."
systemctl restart apache2

echo "=========================================="
echo "تم الانتهاء! جرب فتح الصفحة الآن."
echo "=========================================="

