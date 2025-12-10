#!/bin/bash

# سكريبت تشغيل Migrations على السيرفر الخارجي
# استخدام: bash run_migrations.sh

echo "🚀 بدء تشغيل Migrations على السيرفر..."

# الانتقال إلى مجلد Laravel
cd /var/www/wedoo_laravel/wedoo_admin_panel || cd /var/www/wedoo_admin_panel || cd wedoo_admin_panel

echo "📂 المجلد الحالي: $(pwd)"

# التحقق من وجود artisan
if [ ! -f "artisan" ]; then
    echo "❌ خطأ: لم يتم العثور على ملف artisan"
    echo "تأكد من أنك في المجلد الصحيح"
    exit 1
fi

# جلب آخر التحديثات من GitHub
echo "📥 جلب آخر التحديثات من GitHub..."
git pull origin main

# التحقق من وجود Migration الجديدة
if [ ! -f "database/migrations/2025_01_21_000001_create_craftsman_task_types_table.php" ]; then
    echo "⚠️  تحذير: لم يتم العثور على Migration الجديدة"
    echo "تأكد من أنك قمت بسحب آخر التحديثات"
fi

# التحقق من حالة Migrations
echo "📊 التحقق من حالة Migrations..."
php artisan migrate:status

# عمل نسخة احتياطية (اختياري)
echo "💾 هل تريد عمل نسخة احتياطية؟ (y/n)"
read -r backup_choice
if [ "$backup_choice" = "y" ]; then
    DB_NAME=$(grep DB_DATABASE .env | cut -d '=' -f2)
    DB_USER=$(grep DB_USERNAME .env | cut -d '=' -f2)
    BACKUP_FILE="backup_$(date +%Y%m%d_%H%M%S).sql"
    echo "📦 عمل نسخة احتياطية..."
    mysqldump -u "$DB_USER" -p "$DB_NAME" > "$BACKUP_FILE"
    echo "✅ تم حفظ النسخة الاحتياطية في: $BACKUP_FILE"
fi

# تشغيل Migrations
echo "🔄 تشغيل Migrations..."
php artisan migrate --force

# التحقق من النجاح
if [ $? -eq 0 ]; then
    echo "✅ تم تشغيل Migrations بنجاح!"
    
    # مسح Cache
    echo "🧹 مسح Cache..."
    php artisan config:clear
    php artisan cache:clear
    php artisan route:clear
    php artisan view:clear
    
    # إعادة بناء Cache
    echo "⚡ إعادة بناء Cache..."
    php artisan config:cache
    php artisan route:cache
    
    # التحقق من الجدول
    echo "🔍 التحقق من الجدول الجديد..."
    php artisan tinker --execute="echo Schema::hasTable('craftsman_task_types') ? '✅ الجدول موجود' : '❌ الجدول غير موجود';"
    
    echo ""
    echo "🎉 تم بنجاح! Migration الجديدة تم تشغيلها."
else
    echo "❌ فشل تشغيل Migrations"
    exit 1
fi

