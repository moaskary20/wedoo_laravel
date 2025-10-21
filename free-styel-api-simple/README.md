# API Endpoints for free-styel.store (Simple Version)

## الملفات المطلوب رفعها إلى https://free-styel.store/

### 1. إنشاء مجلدات API:
```
https://free-styel.store/api/
├── craftsman/
│   └── count.php
├── task-types/
│   └── index.php
└── orders/
    ├── create.php
    └── list.php
```

### 2. رفع الملفات:

#### أ) craftsman/count.php
- المسار: `https://free-styel.store/api/craftsman/count.php`
- الوظيفة: عرض عدد الحرفيين لكل فئة
- **بدون قاعدة بيانات** - يستخدم sبيانات ثابتة

#### ب) task-types/index.php  
- المسار: `https://free-styel.store/api/task-types/index.php`
- الوظيفة: عرض أنواع المهام لكل فئة
- **بدون قاعدة بيانات** - يستخدم بيانات ثابتة

#### ج) orders/create.php
- المسار: `https://free-styel.store/api/orders/create.php`
- الوظيفة: إنشاء طلبات جديدة
- **بدون قاعدة بيانات** - يحفظ في الذاكرة فقط

#### د) orders/list.php
- المسار: `https://free-styel.store/api/orders/list.php`
- الوظيفة: عرض قائمة الطلبات
- **بدون قاعدة بيانات** - يعرض بيانات ثابتة

### 3. اختبار الـ API:

بعد رفع الملفات، يمكن اختبارها:

```bash
# اختبار عدد الحرفيين
curl -X GET "https://free-styel.store/api/craftsman/count.php?category_id=5"

# اختبار أنواع المهام
curl -X GET "https://free-styel.store/api/task-types/index.php?category_id=5"

# اختبار قائمة الطلبات
curl -X GET "https://free-styel.store/api/orders/list.php?user_id=1"
```

### 4. تحديث التطبيق:

بعد رفع الملفات، سيتم تحديث `api_config.dart` تلقائياً لاستخدام `https://free-styel.store/`.

## ملاحظات مهمة:

1. **جميع الملفات بدون قاعدة بيانات** - تستخدم بيانات ثابتة
2. جميع الملفات تحتوي على CORS headers للسماح بالوصول من التطبيق
3. الملفات تستخدم JSON responses
4. البيانات حالياً هي بيانات تجريبية (sample data)
5. **لا توجد أخطاء قاعدة بيانات** - الملفات تعمل بدون MySQL

## الملفات الجاهزة للرفع:

```
/media/mohamed/3E16609616605147/wedoo2/free-styel-api-simple/
├── craftsman/
│   └── count.php
├── task-types/
│   └── index.php
├── orders/
│   ├── create.php
│   └── list.php
└── README.md
```
