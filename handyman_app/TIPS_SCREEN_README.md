# Tips Screen - اعرف سر الصنعة

A comprehensive screen that fetches content from Laravel API endpoint `/api/tips/{category_id}` and displays it in Arabic with scrollable content and images.

## Features

### 🎯 **Content Display**
- **Arabic Interface**: Complete RTL support with Arabic typography
- **Scrollable Content**: Smooth scrolling through multiple tips
- **Image Support**: Display images if available with error handling
- **Loading States**: Loading indicators during API calls
- **Error Handling**: Comprehensive error handling with retry options

### 🎨 **UI/UX Features**
- **Header Section**: Category icon, name, and tips count
- **Tip Cards**: Beautiful cards with Arabic content
- **Progress Indicators**: Visual feedback during loading
- **Responsive Design**: Adapts to different screen sizes
- **Smooth Animations**: Touch feedback and navigation

### 📱 **Tip Card Components**
- **Tip Number**: Sequential numbering for each tip
- **Tip Title**: Arabic title with proper typography
- **Tip Description**: Detailed Arabic description
- **Tip Image**: Optional image with loading and error states
- **Tip Tags**: Categorized tags for better organization
- **Tip Metadata**: Reading time, difficulty level, and type

## Technical Implementation

### 🏗️ **Flutter Screen Structure**

```dart
class TipsScreen extends StatefulWidget {
  final String categoryName;
  final String categoryIcon;
  final Color categoryColor;
  final int categoryId;
  
  // State management
  List<Tip> _tips = [];
  bool _isLoading = true;
  String? _errorMessage;
}
```

### 📱 **Screen Layout**

```dart
Widget _buildBody() {
  if (_isLoading) return _buildLoadingState();
  if (_errorMessage != null) return _buildErrorState();
  if (_tips.isEmpty) return _buildEmptyState();
  
  return Column(
    children: [
      _buildHeader(),           // Category info
      Expanded(
        child: ListView.builder(
          itemCount: _tips.length,
          itemBuilder: (context, index) {
            return _buildTipCard(_tips[index], index);
          },
        ),
      ),
    ],
  );
}
```

### 🎯 **Tip Card Design**

```dart
Widget _buildTipCard(Tip tip, int index) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [/* Shadow */],
    ),
    child: Column(
      children: [
        // Tip Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              // Tip Number
              Container(/* Number badge */),
              // Tip Title
              Expanded(/* Title */),
              // Tip Type Badge
              Container(/* Type badge */),
            ],
          ),
        ),
        
        // Tip Content
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Description
              Text(tip.description),
              
              // Image (if available)
              if (tip.imageUrl != null)
                ClipRRect(/* Image */),
              
              // Tags (if available)
              if (tip.tags != null)
                Wrap(/* Tags */),
              
              // Footer
              Row(/* Reading time, difficulty */),
            ],
          ),
        ),
      ],
    ),
  );
}
```

### 🌐 **API Integration**

#### **HTTP Request**
```dart
Future<void> _fetchTips() async {
  final response = await http.get(
    Uri.parse('https://free-styel.store/api/tips/${widget.categoryId}'),
    headers: {'Content-Type': 'application/json'},
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['success'] == true && data['data'] != null) {
      setState(() {
        _tips = (data['data'] as List)
            .map((tip) => Tip.fromJson(tip))
            .toList();
        _isLoading = false;
      });
    }
  }
}
```

#### **Tip Model**
```dart
class Tip {
  final int id;
  final String title;
  final String description;
  final String? imageUrl;
  final String? type;
  final List<String>? tags;
  final String? readingTime;
  final String? difficulty;
  final DateTime createdAt;
  
  factory Tip.fromJson(Map<String, dynamic> json) {
    return Tip(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['image_url'],
      type: json['type'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      readingTime: json['reading_time'],
      difficulty: json['difficulty'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
```

## Laravel Backend

### 🗄️ **Database Schema**

```sql
CREATE TABLE tips (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    category_id BIGINT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    image_url VARCHAR(500) NULL,
    type VARCHAR(50) NULL,           -- نصيحة، تحذير، معلومة، تلميح
    tags JSON NULL,                  -- Array of tags
    reading_time VARCHAR(50) NULL,  -- وقت القراءة
    difficulty VARCHAR(50) NULL,     -- سهلة، متوسطة، صعبة
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
);
```

### 🎯 **API Endpoints**

#### **GET /api/tips/category/{categoryId}**
Get tips for a specific category

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "title": "نصائح لصيانة المنزل",
      "description": "من المهم القيام بصيانة دورية للمنزل...",
      "image_url": null,
      "type": "نصيحة",
      "tags": ["صيانة", "منزل", "دورية"],
      "reading_time": "3",
      "difficulty": "سهلة",
      "created_at": "2025-10-18T10:13:04.000000Z"
    }
  ],
  "message": "Tips retrieved successfully",
  "category": {
    "id": 1,
    "name": "Home Maintenance",
    "name_ar": "خدمات صيانة المنازل"
  }
}
```

#### **GET /api/tips**
Get all tips with optional filters

**Query Parameters:**
- `category_id`: Filter by category
- `type`: Filter by type
- `difficulty`: Filter by difficulty

#### **POST /api/tips**
Create a new tip

**Request Body:**
```json
{
  "category_id": 1,
  "title": "نصيحة جديدة",
  "description": "وصف النصيحة...",
  "image_url": "https://example.com/image.jpg",
  "type": "نصيحة",
  "tags": ["تاج", "مفيد"],
  "reading_time": "2",
  "difficulty": "سهلة",
  "sort_order": 1
}
```

#### **PUT /api/tips/{id}**
Update a tip

#### **DELETE /api/tips/{id}**
Delete a tip

#### **GET /api/tips/statistics**
Get tips statistics

### 🎨 **Tip Types and Colors**

- **نصيحة (Tip)**: Green badge
- **تحذير (Warning)**: Red badge
- **معلومة (Info)**: Blue badge
- **تلميح (Hint)**: Orange badge

### 🏷️ **Tip Tags System**

- **Categorized Tags**: Organize tips by topics
- **Color-coded Tags**: Blue background with blue text
- **Flexible System**: Support for multiple tags per tip

## Usage

### 🚀 **Navigation Flow**

1. **Category Grid** → Select service category
2. **Category Detail** → Tap "اعرف سر الصنعة" button
3. **Tips Screen** → View scrollable tips with images
4. **Back Navigation** → Return to category detail

### 📱 **Screen States**

#### **Loading State**
- Circular progress indicator
- "جاري تحميل النصائح..." message

#### **Error State**
- Error icon and message
- Retry button with refresh functionality
- Detailed error information

#### **Empty State**
- Lightbulb icon
- "لا توجد نصائح متاحة" message
- "سيتم إضافة نصائح لهذه الفئة قريباً" subtitle

#### **Content State**
- Header with category info
- Scrollable list of tip cards
- Each card with title, description, image, tags, and metadata

### 🎯 **Content Features**

#### **Tip Header**
- Sequential numbering (1, 2, 3...)
- Arabic title with proper typography
- Type badge with color coding

#### **Tip Content**
- Detailed Arabic description
- Optional image with loading states
- Tag system for categorization
- Reading time and difficulty level

#### **Image Handling**
- Network image loading with progress indicator
- Error state with broken image icon
- Proper aspect ratio and clipping

## Testing

### ✅ **Test Coverage**

- **Screen Loading**: Verifies screen loads with correct Arabic text
- **Navigation**: Tests navigation from category detail
- **API Integration**: Tests successful content fetching
- **Error Handling**: Tests error states and retry functionality

### 🧪 **Test Example**
```dart
testWidgets('Tips screen loads', (WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(
    home: TipsScreen(
      categoryName: 'خدمات صيانة المنازل',
      categoryIcon: 'home_repair',
      categoryColor: Colors.blue,
      categoryId: 1,
    ),
  ));
  
  expect(find.text('اعرف سر الصنعة - خدمات صيانة المنازل'), findsOneWidget);
});
```

## Performance

### ⚡ **Optimizations**

- **Lazy Loading**: ListView.builder for efficient rendering
- **Image Caching**: Network images with proper caching
- **State Management**: Efficient state updates with setState
- **Memory Management**: Proper disposal of resources
- **Error Recovery**: Graceful error handling with retry options

### 📊 **Content Metrics**

- **Tip Cards**: Responsive design with proper spacing
- **Images**: 200px height with cover fit
- **Typography**: Arabic text with proper line height (1.6)
- **Spacing**: Consistent 16px margins and 20px padding

The tips screen provides a comprehensive, user-friendly interface for displaying Arabic content with images, proper error handling, and smooth scrolling functionality!
