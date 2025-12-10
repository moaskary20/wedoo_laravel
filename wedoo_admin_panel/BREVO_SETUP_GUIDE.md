# دليل إعداد Brevo (Sendinblue) لإرسال الإيميلات

## الخطوات المطلوبة:

### 1. إنشاء حساب Brevo
1. اذهب إلى [Brevo.com](https://www.brevo.com)
2. سجل حساب جديد أو سجل الدخول
3. بعد تسجيل الدخول، اذهب إلى **SMTP & API** من القائمة الجانبية

### 2. الحصول على بيانات SMTP من Brevo
1. في صفحة **SMTP & API**، اذهب إلى قسم **SMTP**
2. ستحتاج إلى:
   - **SMTP Server**: `smtp-relay.brevo.com`
   - **Port**: `587` (TLS) أو `465` (SSL)
   - **SMTP Login**: هذا هو إيميل Brevo الخاص بك أو API Key
   - **SMTP Password**: هذا هو SMTP Key (ليس API Key)

### 3. إنشاء SMTP Key
1. في صفحة **SMTP & API**، اذهب إلى **SMTP**
2. اضغط على **Generate new SMTP key**
3. اختر اسم للـ key (مثلاً: "WeDoo App")
4. انسخ الـ **SMTP Key** (هذا هو الـ password)

### 4. إعداد الإيميل المرسل
1. في Brevo، اذهب إلى **Senders & IP**
2. أضف إيميل المرسل (Sender Email) - يجب أن يكون إيميلك المسجل في Brevo
3. قم بتفعيل الإيميل (Verification)

### 5. إضافة الإعدادات في .env
أضف هذه الإعدادات في ملف `.env` على السيرفر:

```env
# Mail Configuration
MAIL_MAILER=brevo
MAIL_DRIVER=brevo

# Brevo SMTP Settings
BREVO_SMTP_HOST=smtp-relay.brevo.com
BREVO_SMTP_PORT=587
BREVO_SMTP_USERNAME=your-email@example.com
BREVO_SMTP_PASSWORD=your-smtp-key-here
BREVO_ENCRYPTION=tls

# From Address (يجب أن يكون نفس الإيميل المسجل في Brevo)
BREVO_FROM_EMAIL=noreply@wedoo.com
BREVO_FROM_NAME=WeDoo

# أو استخدم الإعدادات العامة
MAIL_FROM_ADDRESS=noreply@wedoo.com
MAIL_FROM_NAME=WeDoo
```

### 6. إعدادات إضافية في .env
```env
# App URL (مهم للإيميلات)
APP_URL=https://free-styel.store

# Mail Settings
MAIL_HOST=smtp-relay.brevo.com
MAIL_PORT=587
MAIL_USERNAME=your-email@example.com
MAIL_PASSWORD=your-smtp-key-here
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=noreply@wedoo.com
MAIL_FROM_NAME=WeDoo
```

## ملاحظات مهمة:

1. **SMTP Key vs API Key**: 
   - استخدم **SMTP Key** وليس API Key
   - SMTP Key يبدأ عادة بـ `xsmtpib-...`

2. **Port Settings**:
   - استخدم `587` مع `tls` (موصى به)
   - أو `465` مع `ssl`

3. **Sender Verification**:
   - يجب أن يكون الإيميل المرسل (`MAIL_FROM_ADDRESS`) مفعّل في Brevo
   - اذهب إلى **Senders & IP** وقم بتفعيل الإيميل

4. **Testing**:
   - بعد الإعداد، اختبر إرسال إيميل من التطبيق
   - تحقق من الـ logs في `storage/logs/laravel.log`

## اختبار الإعداد:

بعد إضافة الإعدادات في `.env`:

```bash
# على السيرفر
cd /var/www/wedoo_laravel/wedoo_admin_panel

# مسح Cache
php artisan config:clear
php artisan cache:clear

# إعادة بناء Config
php artisan config:cache

# اختبار إرسال إيميل (اختياري)
php artisan tinker
>>> Mail::raw('Test email', function($msg) { $msg->to('your-email@example.com')->subject('Test'); });
```

## استكشاف الأخطاء:

### إذا لم يصل الإيميل:
1. تحقق من الـ logs: `tail -f storage/logs/laravel.log`
2. تأكد من أن SMTP Key صحيح
3. تأكد من أن Sender Email مفعّل في Brevo
4. تحقق من أن Port و Encryption صحيحين

### أخطاء شائعة:
- **"Authentication failed"**: تحقق من SMTP Key
- **"Connection timeout"**: تحقق من Port و Encryption
- **"Sender not verified"**: فعّل الإيميل في Brevo

## معلومات إضافية:

- **Brevo Free Plan**: يسمح بإرسال 300 إيميل يومياً
- **Brevo Paid Plans**: تبدأ من $25/شهر لإرسال 20,000 إيميل
- **Documentation**: [Brevo SMTP Documentation](https://developers.brevo.com/docs/send-emails-with-smtp)

