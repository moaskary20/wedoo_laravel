# دليل اختيار القسم والمهام للصنايعي - Craftsman Category & Task Selection Guide

## 📋 نظرة عامة

تم إضافة نظام يسمح للصنايعي باختيار القسم والمهام التي يستطيع العمل فيها عند إنشاء الحساب. الطلبات تأتي للصنايعي بناءً على القسم والمهام المختارة.

## 🗄️ قاعدة البيانات

### جدول `craftsman_task_types` (جديد)
```sql
CREATE TABLE craftsman_task_types (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    craftsman_id BIGINT NOT NULL,
    task_type_id BIGINT NOT NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    UNIQUE KEY (craftsman_id, task_type_id),
    FOREIGN KEY (craftsman_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (task_type_id) REFERENCES task_types(id) ON DELETE CASCADE
);
```

## 🔄 تدفق التسجيل للصنايعي

### 1. **شاشة اختيار نوع العضوية** (`MembershipTypeScreen`)
- المستخدم يختار "صنايعي"

### 2. **شاشة اختيار نوع الصنايعي** (`CraftsmanCategoryScreen`)
- المستخدم يختار "صنايعي" أو "محل/معرض"

### 3. **شاشة التسجيل** (`CraftsmanRegistrationScreen`) - **تم التحديث**
- إدخال الاسم، البريد الإلكتروني، كلمة المرور
- اختيار فئة عمرية
- **اختيار القسم** (قائمة منسدلة)
- **بعد اختيار القسم، تظهر قائمة المهام** (checkboxes)
- **اختيار المهام** التي يستطيع العمل فيها (يمكن اختيار أكثر من مهمة)

### 4. **شاشة اختيار الموقع** (`LocationSelectionScreen`)
- اختيار الموقع
- إرسال البيانات للـ backend

## 🔌 API Endpoints

### 1. إنشاء حساب صنايعي
**POST** `/api/auth/register`

**Body:**
```json
{
  "name": "أحمد محمد",
  "email": "ahmed@example.com",
  "phone": "01234567890",
  "password": "password123",
  "user_type": "craftsman",
  "category_id": 1,
  "task_type_ids": [1, 2, 3],
  "governorate": "تونس",
  "city": "تونس العاصمة",
  "district": "المركز"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": 1,
      "name": "أحمد محمد",
      "user_type": "craftsman",
      "category_id": 1
    },
    "access_token": "..."
  },
  "message": "Registration successful"
}
```

### 2. الحصول على المهام حسب القسم
**GET** `/api/task-types/index?category_id={id}`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name_ar": "صيانة كهربائية",
      "category_id": 1,
      "status": "active"
    }
  ]
}
```

## 📱 استخدام في Flutter

### شاشة التسجيل (`craftsman_registration_screen.dart`)

**المميزات المضافة:**
1. **قائمة منسدلة للقسم**: بعد تحميل الأقسام من API
2. **قائمة المهام**: تظهر تلقائياً بعد اختيار القسم
3. **اختيار متعدد**: يمكن اختيار أكثر من مهمة
4. **التحقق**: يجب اختيار مهمة واحدة على الأقل

**الكود:**
```dart
// عند اختيار القسم
onChanged: (value) {
  setState(() {
    _selectedCategoryId = value;
    _selectedTaskTypeIds.clear();
    _taskTypes.clear();
  });
  if (value != null) {
    _loadTaskTypes(value); // تحميل المهام
  }
}

// حفظ المهام المختارة
await prefs.setString('temp_user_task_type_ids', 
    jsonEncode(_selectedTaskTypeIds.toList()));
```

## 🔒 الأمان والتحقق

1. **التحقق من القسم**: يجب أن يكون القسم موجوداً
2. **التحقق من المهام**: يجب أن تكون المهام موجودة وتنتمي للقسم المختار
3. **الحد الأدنى**: يجب اختيار مهمة واحدة على الأقل
4. **التحقق من الملكية**: المهام يجب أن تنتمي للقسم المختار

## 📊 فلترة الطلبات

### للصنايعي (`OrderController::assigned`)

الطلبات التي تظهر للصنايعي:
1. **الطلبات المخصصة له**: `craftsman_id = user.id`
2. **الطلبات المتاحة**: 
   - `status = 'pending'`
   - `craftsman_status = 'awaiting_assignment'`
   - `craftsman_id = null`
   - `task_type_id` في قائمة المهام المختارة للصنايعي

### مثال:
```php
// Get craftsman's task type IDs
$craftsmanTaskTypeIds = $user->taskTypes()->pluck('task_types.id')->toArray();

// Filter orders by task types
$availableOrders = Order::whereIn('task_type_id', $craftsmanTaskTypeIds)
    ->where('status', 'pending')
    ->get();
```

## 🎯 العلاقات في Models

### User Model
```php
public function taskTypes()
{
    return $this->belongsToMany(TaskType::class, 'craftsman_task_types', 
        'craftsman_id', 'task_type_id')
        ->withTimestamps();
}
```

### TaskType Model
```php
public function category()
{
    return $this->belongsTo(Category::class);
}
```

## 🚀 خطوات التشغيل

1. **تشغيل Migration:**
   ```bash
   php artisan migrate
   ```

2. **التحقق من الجدول:**
   ```bash
   php artisan tinker
   >>> Schema::hasTable('craftsman_task_types')
   ```

3. **اختبار API:**
   ```bash
   # تسجيل صنايعي جديد
   curl -X POST "https://free-styel.store/api/auth/register" \
     -H "Content-Type: application/json" \
     -d '{
       "name": "صنايعي تجريبي",
       "email": "craftsman@test.com",
       "phone": "01234567890",
       "password": "password123",
       "user_type": "craftsman",
       "category_id": 1,
       "task_type_ids": [1, 2, 3],
       "governorate": "تونس",
       "city": "تونس العاصمة",
       "district": "المركز"
     }'
   ```

## 📝 ملاحظات

- الصنايعي يمكنه اختيار أكثر من مهمة في نفس القسم
- المهام يتم تحميلها تلقائياً بعد اختيار القسم
- الطلبات تأتي للصنايعي بناءً على المهام المختارة فقط
- إذا لم يختار الصنايعي أي مهمة، لن تظهر له أي طلبات متاحة
- يمكن للصنايعي تحديث المهام المختارة لاحقاً (يتطلب endpoint إضافي)

## 🔄 التحديثات المستقبلية

- إضافة endpoint لتحديث المهام المختارة
- إضافة إحصائيات عن المهام الأكثر طلباً
- إضافة توصيات للمهام بناءً على خبرة الصنايعي

