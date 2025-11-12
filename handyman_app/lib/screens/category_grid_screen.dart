import 'package:flutter/material.dart';
import 'category_detail_screen.dart';
import '../services/language_service.dart';
import 'package:handyman_app/l10n/app_localizations.dart';

class CategoryGridScreen extends StatelessWidget {
  const CategoryGridScreen({super.key});

  // Static list of 18 categories with translation keys
  static const List<Map<String, dynamic>> _categories = [
    {
      'id': 1,
      'nameKey': 'homeMaintenance',
      'icon': 'home_repair',
      'color': Colors.blue,
    },
    {
      'id': 2,
      'nameKey': 'cleaningServices',
      'icon': 'cleaning_services',
      'color': Colors.green,
    },
    {
      'id': 3,
      'nameKey': 'transportation',
      'icon': 'local_shipping',
      'color': Colors.orange,
    },
    {
      'id': 4,
      'nameKey': 'carServices',
      'icon': 'directions_car',
      'color': Colors.red,
    },
    {
      'id': 5,
      'nameKey': 'emergencyServices',
      'icon': 'emergency',
      'color': Colors.redAccent,
    },
    {
      'id': 6,
      'nameKey': 'familyServices',
      'icon': 'family_restroom',
      'color': Colors.purple,
    },
    {
      'id': 7,
      'nameKey': 'technicalServices',
      'icon': 'computer',
      'color': Colors.blueGrey,
    },
    {
      'id': 8,
      'nameKey': 'gardenServices',
      'icon': 'yard',
      'color': Colors.lightGreen,
    },
    {
      'id': 9,
      'nameKey': 'variousCrafts',
      'icon': 'handyman',
      'color': Colors.brown,
    },
    {
      'id': 10,
      'nameKey': 'elevatorsSolar',
      'icon': 'solar_power',
      'color': const Color(0xFFfec901),
    },
    {
      'id': 11,
      'nameKey': 'educationServices',
      'icon': 'school',
      'color': Colors.indigo,
    },
    {
      'id': 12,
      'nameKey': 'eventsCelebrations',
      'icon': 'celebration',
      'color': Colors.pink,
    },
    {
      'id': 13,
      'nameKey': 'travelTourism',
      'icon': 'flight',
      'color': Colors.cyan,
    },
    {
      'id': 14,
      'nameKey': 'officeServices',
      'icon': 'business',
      'color': Colors.grey,
    },
    {
      'id': 15,
      'nameKey': 'shoppingServices',
      'icon': 'shopping_cart',
      'color': Colors.teal,
    },
    {
      'id': 16,
      'nameKey': 'corporateServices',
      'icon': 'business_center',
      'color': Colors.deepPurple,
    },
    {
      'id': 17,
      'nameKey': 'specialNeeds',
      'icon': 'accessibility',
      'color': Colors.deepOrange,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Localizations.localeOf(context).languageCode == 'ar';
    
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            l10n.services,
            style: const TextStyle(
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
            final l10n = AppLocalizations.of(context)!;
            return _buildCategoryCard(context, category, l10n);
          },
        ),
      ),
      ),
    );
  }

  String _getCategoryName(AppLocalizations l10n, String nameKey) {
    switch (nameKey) {
      case 'homeMaintenance': return l10n.homeMaintenance;
      case 'cleaningServices': return l10n.cleaningServices;
      case 'transportation': return l10n.transportation;
      case 'carServices': return l10n.carServices;
      case 'emergencyServices': return l10n.emergencyServices;
      case 'familyServices': return l10n.familyServices;
      case 'technicalServices': return l10n.technicalServices;
      case 'gardenServices': return l10n.gardenServices;
      case 'variousCrafts': return l10n.variousCrafts;
      case 'elevatorsSolar': return l10n.elevatorsSolar;
      case 'educationServices': return l10n.educationServices;
      case 'eventsCelebrations': return l10n.eventsCelebrations;
      case 'travelTourism': return l10n.travelTourism;
      case 'officeServices': return l10n.officeServices;
      case 'shoppingServices': return l10n.shoppingServices;
      case 'corporateServices': return l10n.corporateServices;
      case 'specialNeeds': return l10n.specialNeeds;
      default: return '';
    }
  }

  Widget _buildCategoryCard(BuildContext context, Map<String, dynamic> category, AppLocalizations l10n) {
    final categoryName = _getCategoryName(l10n, category['nameKey']);
    
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CategoryDetailScreen(
              categoryName: categoryName,
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
              categoryName,
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
