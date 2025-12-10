# نظام التقييمات والتعليقات - Review System Guide

## 📋 نظرة عامة

تم إضافة نظام تقييمات وتعليقات كامل يسمح للعملاء بتقييم الصنايعية بعد إتمام المهمة. النظام مربوط بالـ backend بالكامل.

## 🗄️ قاعدة البيانات

### جدول `reviews`
- `id`: معرف التقييم
- `order_id`: معرف الطلب (مرتبط بجدول orders)
- `customer_id`: معرف العميل (مرتبط بجدول users)
- `craftsman_id`: معرف الصنايعي (مرتبط بجدول users)
- `rating`: التقييم (1-5 نجوم)
- `comment`: التعليق (نص اختياري)
- `status`: حالة التقييم (pending, approved, rejected)
- `created_at`, `updated_at`: التواريخ

## 🔌 API Endpoints

### 1. إنشاء/تحديث تقييم
**POST** `/api/reviews/create`

**Headers:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Body:**
```json
{
  "order_id": 1,
  "rating": 5,
  "comment": "عمل ممتاز، أنصح به"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "order_id": 1,
    "customer_id": 2,
    "craftsman_id": 3,
    "rating": 5,
    "comment": "عمل ممتاز، أنصح به",
    "status": "approved",
    "created_at": "2025-01-20 10:30:00"
  },
  "message": "Review created successfully"
}
```

### 2. الحصول على تقييم طلب معين
**GET** `/api/reviews/order/{orderId}`

**Headers:**
```
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "order_id": 1,
    "rating": 5,
    "comment": "عمل ممتاز",
    "created_at": "2025-01-20 10:30:00"
  }
}
```

### 3. الحصول على جميع تقييمات صنايعي
**GET** `/api/reviews/craftsman/{craftsmanId}`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "rating": 5,
      "comment": "عمل ممتاز",
      "customer_name": "أحمد محمد",
      "created_at": "2025-01-20 10:30:00"
    }
  ],
  "average_rating": 4.5,
  "total_reviews": 10
}
```

### 4. التحقق من إمكانية التقييم
**GET** `/api/reviews/can-review/{orderId}`

**Response:**
```json
{
  "success": true,
  "can_review": true,
  "has_review": false,
  "is_completed": true
}
```

## 📱 استخدام في Flutter

### 1. شاشة التقييم (`review_screen.dart`)

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ReviewScreen(
      orderId: '1',
      craftsmanName: 'أحمد محمد',
      orderTitle: 'صيانة كهربائية',
      existingReview: reviewData, // اختياري
    ),
  ),
);
```

### 2. إضافة زر التقييم في شاشة الطلبات

تم تحديث `my_orders_screen.dart` لإظهار زر التقييم للطلبات المكتملة:

- يظهر زر "تقييم الصنايعي" للطلبات المكتملة
- يظهر زر "تعديل التقييم" إذا كان التقييم موجوداً
- يتم إعادة تحميل الطلبات بعد إضافة التقييم

### 3. API Config

تم إضافة endpoints في `api_config.dart`:

```dart
static const String reviewsCreate = '$baseUrl/api/reviews/create';
static String reviewsCanReview(int orderId) => '$baseUrl/api/reviews/can-review/$orderId';
static String reviewsGetByOrder(int orderId) => '$baseUrl/api/reviews/order/$orderId';
static String reviewsGetByCraftsman(int craftsmanId) => '$baseUrl/api/reviews/craftsman/$craftsmanId';
```

## 🔒 الأمان والتحقق

1. **التحقق من المستخدم**: يجب أن يكون المستخدم مسجلاً
2. **التحقق من الملكية**: يمكن للعميل تقييم طلباته فقط
3. **التحقق من الحالة**: يمكن التقييم فقط للطلبات المكتملة
4. **منع التكرار**: يمكن تحديث التقييم الموجود بدلاً من إنشاء تقييم جديد

## 📊 المميزات

✅ تقييم من 1-5 نجوم
✅ تعليق نصي اختياري
✅ إمكانية تعديل التقييم
✅ عرض التقييمات في معلومات الطلب
✅ حساب متوسط التقييمات للصنايعي
✅ واجهة مستخدم عربية كاملة

## 🚀 خطوات التشغيل

1. **تأكد من وجود Migration:**
   ```bash
   php artisan migrate
   ```

2. **التحقق من Routes:**
   ```bash
   php artisan route:list | grep reviews
   ```

3. **اختبار API:**
   ```bash
   # إنشاء تقييم
   curl -X POST "https://free-styel.store/api/reviews/create" \
     -H "Authorization: Bearer {token}" \
     -H "Content-Type: application/json" \
     -d '{"order_id": 1, "rating": 5, "comment": "ممتاز"}'
   ```

## 📝 ملاحظات

- التقييمات يتم الموافقة عليها تلقائياً (`status: approved`)
- يمكن للعميل تحديث تقييمه في أي وقت
- يتم إرجاع معلومات التقييم مع بيانات الطلب في `OrderController`
- العلاقات في Models:
  - `Order` → `hasOne(Review::class)`
  - `User` → `hasMany(Review::class, 'craftsman_id')` (craftsmanReviews)

