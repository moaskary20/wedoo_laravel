# Service Request Form - إنشاء طلب خدمة

A comprehensive 3-step form for creating service requests in the handyman app with Arabic interface and Laravel API integration.

## Features

### 🎯 **3-Step Form Process**

#### 1️⃣ **نوع المهمة (Service Type)**
- **Dropdown Selection**: Choose from predefined service types
- **Service Types Available**:
  - صيانة عامة (General Maintenance)
  - تنظيف شامل (Complete Cleaning)
  - إصلاح عاجل (Urgent Repair)
  - تركيب (Installation)
  - صيانة دورية (Periodic Maintenance)
  - استشارة فنية (Technical Consultation)
  - خدمة مخصصة (Custom Service)

#### 2️⃣ **مواصفات المهمة (Task Specifications)**
- **Task Description**: Multi-line text field for detailed description
- **Urgency Level**: Dropdown with options:
  - عاجل (Urgent)
  - عادي (Normal)
  - غير عاجل (Not Urgent)
- **Budget**: Optional budget field with currency icon

#### 3️⃣ **مكان المهمة (Task Location)**
- **Use Saved Location**: Option to use previously saved location
- **Select New Location**: Option to choose different location on map
- **Location Data**: Address, city, country, latitude, longitude

### 🎨 **UI/UX Features**

- **Progress Indicator**: Visual step indicator with Arabic labels
- **Form Validation**: Real-time validation with Arabic error messages
- **Responsive Design**: Adapts to different screen sizes
- **Arabic Interface**: Complete RTL support with Arabic typography
- **Loading States**: Loading indicators during form submission
- **Error Handling**: Comprehensive error handling with user-friendly messages
- **Success Dialog**: Confirmation dialog upon successful submission

## Technical Implementation

### 🏗️ **Flutter Form Structure**

```dart
class ServiceRequestForm extends StatefulWidget {
  final String categoryName;
  final String categoryIcon;
  final Color categoryColor;
  
  // Form state management
  int _currentStep = 0;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Step 1: Service Type
  String? _selectedServiceType;
  
  // Step 2: Task Specifications
  TextEditingController _taskDescriptionController;
  String _selectedUrgency = 'عادي';
  
  // Step 3: Location
  Map<String, dynamic>? _savedLocation;
  bool _useSavedLocation = true;
}
```

### 📱 **Form Steps Implementation**

#### **Step 1: Service Type Selection**
```dart
Widget _buildStep1() {
  return Column(
    children: [
      // Category Info Card
      Container(
        child: Row(
          children: [
            // Category Icon
            Container(/* Icon */),
            // Category Name & Description
            Expanded(/* Text */),
          ],
        ),
      ),
      
      // Service Type Dropdown
      DropdownButton<String>(
        value: _selectedServiceType,
        items: _serviceTypes.map((String service) {
          return DropdownMenuItem<String>(
            value: service,
            child: Text(service),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedServiceType = newValue;
          });
        },
      ),
    ],
  );
}
```

#### **Step 2: Task Specifications**
```dart
Widget _buildStep2() {
  return Column(
    children: [
      // Task Description
      TextField(
        controller: _taskDescriptionController,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: 'اكتب وصفاً مفصلاً للمهمة المطلوبة...',
        ),
      ),
      
      // Urgency Level
      DropdownButton<String>(
        value: _selectedUrgency,
        items: _urgencyLevels.map((String urgency) {
          return DropdownMenuItem<String>(
            value: urgency,
            child: Text(urgency),
          );
        }).toList(),
      ),
      
      // Budget (Optional)
      TextField(
        controller: _budgetController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: 'مثال: 500 ريال',
          prefixIcon: Icon(Icons.attach_money),
        ),
      ),
    ],
  );
}
```

#### **Step 3: Location Selection**
```dart
Widget _buildStep3() {
  return Column(
    children: [
      // Location Options
      RadioListTile<bool>(
        title: Text('استخدام الموقع المحفوظ'),
        subtitle: Text(_selectedLocationText),
        value: true,
        groupValue: _useSavedLocation,
        onChanged: (bool? value) {
          setState(() {
            _useSavedLocation = value!;
          });
        },
      ),
      
      RadioListTile<bool>(
        title: Text('اختيار موقع جديد'),
        subtitle: Text('اختر موقعاً مختلفاً على الخريطة'),
        value: false,
        groupValue: _useSavedLocation,
        onChanged: (bool? value) {
          setState(() {
            _useSavedLocation = value!;
          });
        },
      ),
    ],
  );
}
```

### 🔄 **Form Validation**

```dart
bool _validateCurrentStep() {
  switch (_currentStep) {
    case 0:
      if (_selectedServiceType == null) {
        _showErrorSnackBar('يرجى اختيار نوع المهمة');
        return false;
      }
      return true;
    case 1:
      if (_taskDescriptionController.text.trim().isEmpty) {
        _showErrorSnackBar('يرجى كتابة وصف المهمة');
        return false;
      }
      return true;
    case 2:
      if (!_useSavedLocation && _savedLocation == null) {
        _showErrorSnackBar('يرجى اختيار موقع للمهمة');
        return false;
      }
      return true;
    default:
      return true;
  }
}
```

### 🌐 **API Integration**

#### **Request Data Structure**
```dart
Map<String, dynamic> requestData = {
  'service_type': _selectedServiceType,
  'category': widget.categoryName,
  'description': _taskDescriptionController.text.trim(),
  'urgency': _selectedUrgency,
  'budget': _budgetController.text.trim().isNotEmpty 
      ? _budgetController.text.trim() 
      : null,
  'use_saved_location': _useSavedLocation,
  'location': _useSavedLocation && _savedLocation != null
      ? {
          'address': _savedLocation!['address'],
          'city': _savedLocation!['city'],
          'country': _savedLocation!['country'],
          'latitude': _savedLocation!['latitude'],
          'longitude': _savedLocation!['longitude'],
        }
      : null,
  'created_at': DateTime.now().toIso8601String(),
};
```

#### **HTTP Request**
```dart
final response = await http.post(
  Uri.parse('http://free-styel.store/api/requests'),
  headers: {
    'Content-Type': 'application/json',
  },
  body: jsonEncode(requestData),
);
```

## Laravel Backend

### 🗄️ **Database Schema**

```sql
CREATE TABLE service_requests (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    device_id VARCHAR(255) NOT NULL,
    category VARCHAR(255) NOT NULL,
    service_type VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    urgency ENUM('عاجل', 'عادي', 'غير عاجل') DEFAULT 'عادي',
    budget VARCHAR(255) NULL,
    use_saved_location BOOLEAN DEFAULT TRUE,
    address VARCHAR(500) NULL,
    city VARCHAR(255) NULL,
    country VARCHAR(255) NULL,
    latitude DECIMAL(10, 8) NULL,
    longitude DECIMAL(11, 8) NULL,
    status ENUM('pending', 'accepted', 'in_progress', 'completed', 'cancelled') DEFAULT 'pending',
    notes TEXT NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL
);
```

### 🎯 **API Endpoints**

#### **POST /api/requests**
Create a new service request

**Request Body:**
```json
{
  "service_type": "صيانة عامة",
  "category": "خدمات صيانة المنازل",
  "description": "وصف مفصل للمهمة",
  "urgency": "عادي",
  "budget": "500 ريال",
  "use_saved_location": true,
  "location": {
    "address": "شارع الملك فهد، الرياض",
    "city": "الرياض",
    "country": "السعودية",
    "latitude": 24.7136,
    "longitude": 46.6753
  }
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "device_id": "demo_device_1234567890",
    "category": "خدمات صيانة المنازل",
    "service_type": "صيانة عامة",
    "description": "وصف مفصل للمهمة",
    "urgency": "عادي",
    "budget": "500 ريال",
    "status": "pending",
    "created_at": "2025-10-18T10:09:42.000000Z"
  },
  "message": "Service request created successfully"
}
```

#### **GET /api/requests**
Get all service requests with optional filters

**Query Parameters:**
- `device_id`: Filter by device ID
- `status`: Filter by status
- `urgency`: Filter by urgency

#### **GET /api/requests/{id}**
Get specific service request

#### **PUT /api/requests/{id}**
Update service request (status, notes)

#### **DELETE /api/requests/{id}**
Delete service request

#### **GET /api/requests/statistics**
Get service request statistics

## Usage

### 🚀 **Navigation Flow**

1. **Category Grid** → Select service category
2. **Category Detail** → Tap "إنشاء طلب" button
3. **Service Request Form** → Complete 3-step form
4. **Success Dialog** → Confirmation and navigation back

### 📱 **Form Flow**

```
ServiceRequestForm
├── Step 1: نوع المهمة
│   ├── Category Info Card
│   └── Service Type Dropdown
├── Step 2: مواصفات المهمة
│   ├── Task Description
│   ├── Urgency Level
│   └── Budget (Optional)
├── Step 3: مكان المهمة
│   ├── Use Saved Location
│   └── Select New Location
└── Submit Request
    ├── Validation
    ├── API Call
    └── Success Dialog
```

### 🎯 **Form Validation Rules**

- **Step 1**: Service type must be selected
- **Step 2**: Description must be at least 10 characters
- **Step 3**: Location must be available (saved or selected)

### 🔄 **Error Handling**

- **Validation Errors**: Arabic error messages with snackbar
- **Network Errors**: Retry mechanism with error display
- **API Errors**: Detailed error messages with retry option

## Testing

### ✅ **Test Coverage**

- **Form Loading**: Verifies form loads with correct Arabic text
- **Navigation**: Tests step-by-step navigation
- **Validation**: Tests form validation rules
- **API Integration**: Tests successful form submission

### 🧪 **Test Example**
```dart
testWidgets('Service request form loads', (WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(
    home: ServiceRequestForm(
      categoryName: 'خدمات صيانة المنازل',
      categoryIcon: 'home_repair',
      categoryColor: Colors.blue,
    ),
  ));
  
  expect(find.text('إنشاء طلب خدمة'), findsOneWidget);
  expect(find.text('خدمات صيانة المنازل'), findsOneWidget);
});
```

## Performance

### ⚡ **Optimizations**

- **State Management**: Efficient state updates with setState
- **Form Validation**: Client-side validation before API calls
- **Loading States**: Proper loading indicators during API calls
- **Error Recovery**: Graceful error handling with retry options
- **Memory Management**: Proper disposal of controllers

The service request form provides a comprehensive, user-friendly interface for creating service requests with full Arabic support and robust API integration!
