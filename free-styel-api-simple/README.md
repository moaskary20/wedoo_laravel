# Free-styel.store Simple API Endpoints

هذا المجلد يحتوي على ملفات API بسيطة (PHP) مصممة للعمل مع `https://free-styel.store/`.
تم تصميم هذه الملفات لتجنب مشاكل قاعدة البيانات (MySQL) على الخادم البعيد،
لذلك تستخدم بيانات ثابتة (Hardcoded Data) بدلاً من الاتصال بقاعدة بيانات.

## 🚀 كيفية النشر (Deployment Instructions)

لجعل هذه الـ API endpoints تعمل على `https://free-styel.store/`، اتبع الخطوات التالية:

1. **الاتصال بالخادم:**
   استخدم SSH أو FTP للاتصال بالخادم الخاص بك (root@vmi2704354).

2. **إنشاء مجلد `api`:**
   تأكد من وجود مجلد `api` في المسار الرئيسي لموقعك (عادةً `public_html` أو `www` أو `public` في Laravel).
   إذا لم يكن موجوداً، قم بإنشائه:
   ```bash
   mkdir -p /var/www/wedoo_laravel/public/api
   ```

3. **إنشاء المجلدات الفرعية:**
   داخل مجلد `api`، قم بإنشاء المجلدات التالية:
   ```bash
   mkdir -p /var/www/wedoo_laravel/public/api/craftsman
   mkdir -p /var/www/wedoo_laravel/public/api/task-types
   mkdir -p /var/www/wedoo_laravel/public/api/orders
   ```

4. **رفع ملفات PHP:**
   قم برفع ملفات PHP من هذا المجلد (`free-styel-api-simple/`) إلى المجلدات المقابلة على الخادم:

   - **`craftsman/count.php`**:
     المسار على الخادم: `/var/www/wedoo_laravel/public/api/craftsman/count.php`
     (استبدل الملف الموجود أو ارفعه إذا لم يكن موجوداً)

   - **`task-types/index.php`**:
     المسار على الخادم: `/var/www/wedoo_laravel/public/api/task-types/index.php`
     (استبدل الملف الموجود أو ارفعه إذا لم يكن موجوداً)

   - **`orders/create.php`**:
     المسار على الخادم: `/var/www/wedoo_laravel/public/api/orders/create.php`
     (استبدل الملف الموجود أو ارفعه إذا لم يكن موجوداً)

   - **`orders/list.php`**:
     المسار على الخادم: `/var/www/wedoo_laravel/public/api/orders/list.php`
     (استبدل الملف الموجود أو ارفعه إذا لم يكن موجوداً)

5. **تأكيد الصلاحيات (Permissions):**
   تأكد من أن ملفات PHP لديها الصلاحيات الصحيحة ليتمكن الخادم من قراءتها وتنفيذها (عادةً 644 أو 755).
   ```bash
   chmod 644 /var/www/wedoo_laravel/public/api/craftsman/count.php
   chmod 644 /var/www/wedoo_laravel/public/api/task-types/index.php
   chmod 644 /var/www/wedoo_laravel/public/api/orders/create.php
   chmod 644 /var/www/wedoo_laravel/public/api/orders/list.php
   ```

6. **اختبار الـ API:**
   بعد الرفع، يمكنك اختبار الـ API باستخدام `curl` أو متصفح الويب:
   ```bash
   curl -X GET "https://free-styel.store/api/craftsman/count.php?category_id=5"
   curl -X GET "https://free-styel.store/api/task-types/index.php?category_id=5"
   ```
   يجب أن تحصل على استجابة JSON بنجاح.

## 🎯 الميزات

- **`craftsman/count.php`**
  - المسار: `https://free-styel.store/api/craftsman/count.php`
  - الوظيفة: عرض عدد الحرفيين لكل فئة
  - **بدون قاعدة بيانات** - يستخدم بيانات ثابتة

- **`task-types/index.php`**
  - المسار: `https://free-styel.store/api/task-types/index.php`
  - الوظيفة: عرض أنواع المهام لكل فئة
  - **بدون قاعدة بيانات** - يستخدم بيانات ثابتة

- **`orders/create.php`**
  - المسار: `https://free-styel.store/api/orders/create.php`
  - الوظيفة: إنشاء طلب خدمة جديد
  - **بدون قاعدة بيانات** - يحاكي عملية الإنشاء ويعيد بيانات ثابتة

- **`orders/list.php`**
  - المسار: `https://free-styel.store/api/orders/list.php`
  - الوظيفة: عرض قائمة طلبات الخدمة
  - **بدون قاعدة بيانات** - يعيد قائمة طلبات ثابتة

---