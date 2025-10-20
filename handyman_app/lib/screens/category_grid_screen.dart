import 'package:flutter/material.dart';
import 'category_detail_screen.dart';

class CategoryGridScreen extends StatelessWidget {
  const CategoryGridScreen({super.key});

  // Static list of 18 categories with Arabic titles
  static const List<Map<String, dynamic>> _categories = [
    {
      'id': 1,
      'name': 'Home Maintenance',
      'nameAr': 'خدمات صيانة المنازل',
      'icon': 'home_repair',
      'color': Colors.blue,
    },
    {
      'id': 2,
      'name': 'Cleaning Services',
      'nameAr': 'خدمات التنظيف',
      'icon': 'cleaning_services',
      'color': Colors.green,
    },
    {
      'id': 3,
      'name': 'Transportation',
      'nameAr': 'النقل والخدمات اللوجستية',
      'icon': 'local_shipping',
      'color': Colors.orange,
    },
    {
      'id': 4,
      'name': 'Car Services',
      'nameAr': 'خدمات السيارات',
      'icon': 'directions_car',
      'color': Colors.red,
    },
    {
      'id': 5,
      'name': 'Emergency Services',
      'nameAr': 'خدمات طارئة (عاجلة)',
      'icon': 'emergency',
      'color': Colors.redAccent,
    },
    {
      'id': 6,
      'name': 'Family Services',
      'nameAr': 'خدمات الأسر والعائلات',
      'icon': 'family_restroom',
      'color': Colors.purple,
    },
    {
      'id': 7,
      'name': 'Technical Services',
      'nameAr': 'خدمات تقنية',
      'icon': 'computer',
      'color': Colors.blueGrey,
    },
    {
      'id': 8,
      'name': 'Garden Services',
      'nameAr': 'خدمات الحديقة',
      'icon': 'yard',
      'color': Colors.lightGreen,
    },
    {
      'id': 9,
      'name': 'Various Crafts',
      'nameAr': 'حرف وخدمات متنوعة',
      'icon': 'handyman',
      'color': Colors.brown,
    },
    {
      'id': 10,
      'name': 'Elevators & Solar',
      'nameAr': 'المصاعد والألواح الشمسية',
      'icon': 'solar_power',
      'color': const Color(0xFFfec901),
    },
    {
      'id': 11,
      'name': 'Education Services',
      'nameAr': 'خدمات التعليم والدروس الخصوصية',
      'icon': 'school',
      'color': Colors.indigo,
    },
    {
      'id': 12,
      'name': 'Events & Celebrations',
      'nameAr': 'خدمات المناسبات والإحتفالات',
      'icon': 'celebration',
      'color': Colors.pink,
    },
    {
      'id': 13,
      'name': 'Travel & Tourism',
      'nameAr': 'خدمات السفر والسياحة',
      'icon': 'flight',
      'color': Colors.cyan,
    },
    {
      'id': 14,
      'name': 'Office Services',
      'nameAr': 'خدمات المكاتب والمستندات',
      'icon': 'business',
      'color': Colors.grey,
    },
    {
      'id': 15,
      'name': 'Shopping Services',
      'nameAr': 'خدمات التسوق',
      'icon': 'shopping_cart',
      'color': Colors.teal,
    },
    {
      'id': 16,
      'name': 'Corporate Services',
      'nameAr': 'خدمات للمؤسسات والشركات',
      'icon': 'business_center',
      'color': Colors.deepPurple,
    },
    {
      'id': 17,
      'name': 'Special Needs',
      'nameAr': 'خدمات ذوي الإحتياجات الخاصة',
      'icon': 'accessibility',
      'color': Colors.deepOrange,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'الصنايع',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 20,
            childAspectRatio: 0.85,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            return _buildCategoryCard(context, category);
          },
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, Map<String, dynamic> category) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CategoryDetailScreen(
              categoryName: category['nameAr'],
              categoryIcon: category['icon'],
              categoryColor: category['color'],
              categoryId: category['id'],
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Yellow circle with icon
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFfec901),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                _getIconData(category['icon']),
                size: 35,
                color: category['color'],
              ),
            ),
            const SizedBox(height: 12),
            // Category name below the circle
            Text(
              category['nameAr'],
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'home_repair':
        return Icons.home_repair_service;
      case 'cleaning_services':
        return Icons.cleaning_services;
      case 'local_shipping':
        return Icons.local_shipping;
      case 'directions_car':
        return Icons.directions_car;
      case 'emergency':
        return Icons.emergency;
      case 'family_restroom':
        return Icons.family_restroom;
      case 'computer':
        return Icons.computer;
      case 'yard':
        return Icons.yard;
      case 'handyman':
        return Icons.handyman;
      case 'solar_power':
        return Icons.solar_power;
      case 'school':
        return Icons.school;
      case 'celebration':
        return Icons.celebration;
      case 'flight':
        return Icons.flight;
      case 'business':
        return Icons.business;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'business_center':
        return Icons.business_center;
      case 'accessibility':
        return Icons.accessibility;
      default:
        return Icons.build;
    }
  }

}
