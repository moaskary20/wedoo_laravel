# تعليمات النشر إلى https://free-styel.store/

## 🚀 خطوات النشر

### 1. رفع ملفات API المحدثة

قم برفع الملفات التالية إلى `https://free-styel.store/api/`:

#### ملفات API المطلوبة:
```
api/
├── craftsman/
│   └── count.php          # عدد الحرفيين
├── task-types/
│   └── index.php          # أنواع المهام (محدث)
├── orders/
│   ├── create.php         # إنشاء طلب
│   └── list.php           # قائمة الطلبات
```

#### المسارات على السيرفر:
- `/var/www/wedoo_laravel/public/api/craftsman/count.php`
- `/var/www/wedoo_laravel/public/api/task-types/index.php`
- `/var/www/wedoo_laravel/public/api/orders/create.php`
- `/var/www/wedoo_laravel/public/api/orders/list.php`

### 2. تحديث ملف task-types/index.php

**مهم جداً:** تأكد من رفع النسخة المحدثة من `task-types/index.php` التي تحتوي على:

```php
3 => [ // النقل والخدمات اللوجستية
    ['id' => 6, 'name' => 'نقل أثاث', ...],
    ['id' => 7, 'name' => 'نقل سريع', ...],
    ['id' => 8, 'name' => 'نقل طويل المدى', ...],
],
```

### 3. اختبار الـ API

بعد الرفع، اختبر الـ API endpoints:

```bash
# اختبار عدد الحرفيين
curl -X GET "https://free-styel.store/api/craftsman/count.php?category_id=3"

# اختبار أنواع المهام
curl -X GET "https://free-styel.store/api/task-types/index.php?category_id=3"

# اختبار قائمة الطلبات
curl -X GET "https://free-styel.store/api/orders/list.php?user_id=1"
```

### 4. النتائج المتوقعة

- **الفئة 3 (النقل والخدمات اللوجستية):**
  - عدد الحرفيين: **8 حرفي**
  - أنواع المهام: **3 أنواع** (نقل أثاث، نقل سريع، نقل طويل المدى)

- **الفئة 1 (خدمات صيانة المنازل):**
  - عدد الحرفيين: **15 حرفي**
  - أنواع المهام: **3 أنواع** (صيانة السباكة، صيانة الكهرباء، صيانة التكييف)

- **الفئة 5 (خدمات طارئة):**
  - عدد الحرفيين: **20 حرفي**
  - أنواع المهام: **5 أنواع** (صيانة مكيف، تنظيف مكيف، إصلاح مكيف، تركيب مكيف، إصلاح ثلاجة)

## ✅ التحقق من النجاح

1. **افتح التطبيق في Chrome**
2. **انتقل إلى فئة "النقل والخدمات اللوجستية"**
3. **تحقق من:**
   - عدد الحرفيين: **8 حرفي** ✅
   - أنواع المهام: **3 أنواع** ✅
   - إرسال طلب جديد ✅
   - عرض طلباتك ✅

## 🔧 استكشاف الأخطاء

إذا لم تعمل أنواع المهام:

1. **تحقق من الملف:** تأكد من أن `task-types/index.php` يحتوي على الفئة 3
2. **تحقق من الصلاحيات:** `chmod 644 /var/www/wedoo_laravel/public/api/task-types/index.php`
3. **تحقق من الـ API:** استخدم curl لاختبار الـ API مباشرة
4. **تحقق من الـ CORS:** تأكد من وجود CORS headers في الملفات

## 📁 الملفات المطلوبة للرفع

جميع الملفات موجودة في:
- `free-styel-api-simple/craftsman/count.php`
- `free-styel-api-simple/task-types/index.php`
- `free-styel-api-simple/orders/create.php`
- `free-styel-api-simple/orders/list.php`

---
**تم اختبار جميع الملفات محلياً وتعمل بشكل مثالي!** 🎉
