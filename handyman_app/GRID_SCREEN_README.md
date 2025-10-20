# Category Grid Screen - صنايعي

A beautiful grid view screen displaying 18 circular category icons (3 per row) with Arabic titles for the handyman services app.

## Features

### 🎯 **18 Service Categories**
1. **خدمات صيانة المنازل** - Home Maintenance Services
2. **خدمات التنظيف** - Cleaning Services  
3. **النقل والخدمات اللوجستية** - Transportation & Logistics
4. **خدمات السيارات** - Car Services
5. **خدمات طارئة (عاجلة)** - Emergency Services
6. **خدمات الأسر والعائلات** - Family Services
7. **خدمات تقنية** - Technical Services
8. **خدمات الحديقة** - Garden Services
9. **حرف وخدمات متنوعة** - Various Crafts
10. **المصاعد والألواح الشمسية** - Elevators & Solar Panels
11. **خدمات التعليم والدروس الخصوصية** - Education Services
12. **خدمات المناسبات والإحتفالات** - Events & Celebrations
13. **خدمات السفر والسياحة** - Travel & Tourism
14. **خدمات المكاتب والمستندات** - Office Services
15. **خدمات التسوق** - Shopping Services
16. **خدمات للمؤسسات والشركات** - Corporate Services
17. **خدمات ذوي الإحتياجات الخاصة** - Special Needs Services

### 🎨 **Design Features**
- **3x6 Grid Layout**: 18 circular icons arranged in 3 columns, 6 rows
- **Color-Coded Categories**: Each category has its own unique color
- **Circular Icons**: Beautiful circular containers with shadows
- **Arabic Typography**: Proper RTL support with Arabic text
- **Responsive Design**: Adapts to different screen sizes
- **Smooth Animations**: Touch feedback and navigation

### 🎯 **Category Colors**
- **Blue**: Home Maintenance
- **Green**: Cleaning Services
- **Orange**: Transportation
- **Red**: Car Services
- **Red Accent**: Emergency Services
- **Purple**: Family Services
- **Blue Grey**: Technical Services
- **Light Green**: Garden Services
- **Brown**: Various Crafts
- **Amber**: Elevators & Solar
- **Indigo**: Education Services
- **Pink**: Events & Celebrations
- **Cyan**: Travel & Tourism
- **Grey**: Office Services
- **Teal**: Shopping Services
- **Deep Purple**: Corporate Services
- **Deep Orange**: Special Needs Services

## Navigation Flow

### 📱 **App Flow**
1. **Location Screen** → Gets user location
2. **Main Screen** → Shows "صنايعي" and "محلات ومعارض" buttons
3. **Category Grid** → 18 circular category icons (3x6 grid)
4. **Category Detail** → Individual category with two action buttons:
   - **إنشاء طلب** (Create Order)
   - **اعرف سر الصنعة** (Know the Craft Secret)

### 🎯 **Category Detail Screen**
Each category leads to a detail screen with:
- **Large Category Icon**: Color-coded circular icon
- **Category Name**: Arabic title
- **Description**: "اختر الخدمة التي تريدها"
- **Two Action Buttons**:
  - **إنشاء طلب** (Create Order) - Green button
  - **اعرف سر الصنعة** (Know the Craft Secret) - Orange button

## Technical Implementation

### 🏗️ **Grid Layout**
```dart
GridView.builder(
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 3,           // 3 columns
    crossAxisSpacing: 16,        // 16px spacing between columns
    mainAxisSpacing: 16,         // 16px spacing between rows
    childAspectRatio: 1,        // Square aspect ratio
  ),
  itemCount: _categories.length, // 18 categories
  itemBuilder: (context, index) {
    return _buildCategoryCard(context, category);
  },
)
```

### 🎨 **Category Card Design**
```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(50), // Circular shape
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withValues(alpha: 0.2),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: Column(
    children: [
      // Circular icon container
      Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: categoryColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: categoryColor),
      ),
      // Arabic category name
      Text(categoryName, style: TextStyle(...)),
    ],
  ),
)
```

### 🎯 **Icon Mapping**
Each category has a specific Material Design icon:
- `home_repair` → `Icons.home_repair_service`
- `cleaning_services` → `Icons.cleaning_services`
- `local_shipping` → `Icons.local_shipping`
- `directions_car` → `Icons.directions_car`
- `emergency` → `Icons.emergency`
- `family_restroom` → `Icons.family_restroom`
- `computer` → `Icons.computer`
- `yard` → `Icons.yard`
- `handyman` → `Icons.handyman`
- `solar_power` → `Icons.solar_power`
- `school` → `Icons.school`
- `celebration` → `Icons.celebration`
- `flight` → `Icons.flight`
- `business` → `Icons.business`
- `shopping_cart` → `Icons.shopping_cart`
- `business_center` → `Icons.business_center`
- `accessibility` → `Icons.accessibility`

## Usage

### 🚀 **Navigation**
```dart
// Navigate to category grid from main screen
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => const CategoryGridScreen(),
  ),
);

// Navigate to category detail from grid
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => CategoryDetailScreen(
      categoryName: category['nameAr'],
      categoryIcon: category['icon'],
      categoryColor: category['color'],
    ),
  ),
);
```

### 📱 **Screen Structure**
```
CategoryGridScreen
├── AppBar (الصنايع)
├── GridView.builder
│   ├── CategoryCard 1 (خدمات صيانة المنازل)
│   ├── CategoryCard 2 (خدمات التنظيف)
│   ├── CategoryCard 3 (النقل والخدمات اللوجستية)
│   ├── ...
│   └── CategoryCard 17 (خدمات ذوي الإحتياجات الخاصة)
└── Navigation to CategoryDetailScreen
```

## Testing

### ✅ **Test Coverage**
- **Grid Loading**: Verifies all 18 categories load correctly
- **Arabic Text**: Confirms Arabic titles display properly
- **Navigation**: Tests navigation to category detail screen
- **Responsive Design**: Ensures proper layout on different screen sizes

### 🧪 **Test Example**
```dart
testWidgets('Category grid screen loads', (WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(
    home: CategoryGridScreen(),
  ));
  
  // Verify Arabic text appears
  expect(find.text('خدمات صيانة المنازل'), findsOneWidget);
  expect(find.text('خدمات التنظيف'), findsOneWidget);
  expect(find.text('النقل والخدمات اللوجستية'), findsOneWidget);
});
```

## Performance

### ⚡ **Optimizations**
- **Static Data**: Categories stored as static constants (no API calls)
- **Efficient Rendering**: Uses `GridView.builder` for lazy loading
- **Memory Efficient**: Minimal widget tree depth
- **Smooth Scrolling**: Optimized grid layout with proper spacing

### 📊 **Layout Metrics**
- **Grid Size**: 3 columns × 6 rows = 18 categories
- **Card Size**: 60×60px circular icons
- **Spacing**: 16px between cards
- **Aspect Ratio**: 1:1 (square cards)
- **Total Height**: ~6 rows × (card height + spacing)

The category grid screen provides an excellent user experience with beautiful Arabic labels, responsive design, and intuitive navigation to detailed category screens!
