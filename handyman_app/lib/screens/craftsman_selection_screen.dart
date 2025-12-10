import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../services/language_service.dart';
import 'package:handyman_app/l10n/app_localizations.dart';
import 'conversations_screen.dart';

class CraftsmanSelectionScreen extends StatefulWidget {
  final int orderId;
  final int categoryId;
  final String categoryName;
  final Map<String, dynamic>? locationData;

  const CraftsmanSelectionScreen({
    super.key,
    required this.orderId,
    required this.categoryId,
    required this.categoryName,
    this.locationData,
  });

  @override
  State<CraftsmanSelectionScreen> createState() => _CraftsmanSelectionScreenState();
}

class _CraftsmanSelectionScreenState extends State<CraftsmanSelectionScreen> {
  List<Map<String, dynamic>> _craftsmen = [];
  bool _isLoading = true;
  String? _errorMessage;
  int? _selectedCraftsmanId;
  bool _isInviting = false;
  Locale _currentLocale = LanguageService.defaultLocale;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocale();
    _fetchCraftsmen();
  }

  Future<void> _loadCurrentLocale() async {
    final locale = await LanguageService.getSavedLocale();
    if (mounted) {
      setState(() {
        _currentLocale = locale;
      });
    }
  }

  Future<Map<String, String>?> _buildAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null || token.isEmpty) return null;
    final headers = Map<String, String>.from(ApiConfig.headers);
    headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  Future<void> _fetchCraftsmen() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final headers = await _buildAuthHeaders();
      if (headers == null) {
        throw Exception('User is not authenticated. Please log in again.');
      }

      // Build query parameters
      final queryParams = <String, String>{
        'category_id': widget.categoryId.toString(),
        'limit': '20', // Get up to 20 craftsmen
      };

      // Add location filters if available
      if (widget.locationData != null) {
        if (widget.locationData!['governorate'] != null) {
          queryParams['governorate'] = widget.locationData!['governorate'].toString();
        }
        if (widget.locationData!['city'] != null) {
          queryParams['city'] = widget.locationData!['city'].toString();
        }
        if (widget.locationData!['district'] != null) {
          queryParams['district'] = widget.locationData!['district'].toString();
        }
      }

      final uri = Uri.parse(ApiConfig.craftsmanNearby).replace(queryParameters: queryParams);

      print('Fetching craftsmen from: $uri');

      final response = await http.get(uri, headers: headers).timeout(
        const Duration(seconds: 30),
      );

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> raw = data['data'] ?? [];
          setState(() {
            _craftsmen = raw
                .map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item))
                .toList();
            _isLoading = false;
          });
          print('Fetched ${_craftsmen.length} craftsmen');
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch craftsmen');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error fetching craftsmen: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _inviteCraftsman(int craftsmanId) async {
    setState(() {
      _isInviting = true;
      _selectedCraftsmanId = craftsmanId;
    });

    try {
      final headers = await _buildAuthHeaders();
      if (headers == null) {
        throw Exception('User is not authenticated. Please log in again.');
      }

      final response = await http.post(
        Uri.parse(ApiConfig.orderInvite(widget.orderId)),
        headers: headers,
        body: jsonEncode({'craftsman_id': craftsmanId}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // Show success message
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_localizedText(
                'تم إرسال الدعوة للصنايعي بنجاح',
                'Invitation envoyée à l\'artisan avec succès',
              )),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          // Navigate back to orders screen
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else {
          throw Exception(data['message'] ?? 'Failed to invite craftsman');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error inviting craftsman: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_localizedText("خطأ", "Erreur")}: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isInviting = false;
        });
      }
    }
  }

  String _localizedText(String arabic, String french) {
    return _currentLocale.languageCode == 'ar' ? arabic : french;
  }

  Future<void> _openChat(int craftsmanId, String craftsmanName) async {
    try {
      // Get craftsman data from the list
      final craftsman = _craftsmen.firstWhere(
        (c) => c['id'] == craftsmanId,
        orElse: () => {},
      );

      if (craftsman.isEmpty) {
        throw Exception('Craftsman not found');
      }

      // Prepare craftsman data for chat
      final craftsmanData = {
        'id': craftsmanId,
        'name': craftsmanName,
        'craftsman_id': craftsmanId,
        'order_id': widget.orderId,
        'service': widget.categoryName,
        'specialization': widget.categoryName,
        'avatar': craftsman['avatar'],
      };

      // Open chat using the existing function
      if (mounted) {
        openCraftsmanChat(context, craftsmanData);
      }
    } catch (e) {
      print('Error opening chat: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_localizedText("خطأ", "Erreur")}: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRtl = _currentLocale.languageCode == 'ar';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFfec901),
        appBar: AppBar(
          title: Text(
            _localizedText('اختر صنايعي', 'Choisir un artisan'),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          backgroundColor: Colors.blue,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              )
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _fetchCraftsmen,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: Text(_localizedText('إعادة المحاولة', 'Réessayer')),
                        ),
                      ],
                    ),
                  )
                : _craftsmen.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.person_off,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _localizedText(
                                'لا يوجد صنايعيون متاحون في هذه الفئة حالياً',
                                'Aucun artisan disponible dans cette catégorie pour le moment',
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _fetchCraftsmen,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              child: Text(_localizedText('تحديث', 'Actualiser')),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          // Header
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            color: Colors.blue,
                            child: Text(
                              _localizedText(
                                'اختر صنايعي من القائمة التالية',
                                'Choisissez un artisan dans la liste suivante',
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          // Craftsmen List
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _craftsmen.length,
                              itemBuilder: (context, index) {
                                final craftsman = _craftsmen[index];
                                final isSelected = _selectedCraftsmanId == craftsman['id'];
                                final isInviting = _isInviting && isSelected;

                                return _buildCraftsmanCard(craftsman, isSelected, isInviting);
                              },
                            ),
                          ),
                        ],
                      ),
      ),
    );
  }

  Widget _buildCraftsmanCard(
    Map<String, dynamic> craftsman,
    bool isSelected,
    bool isInviting,
  ) {
    final name = craftsman['name']?.toString() ?? 'صنايعي';
    final rating = (craftsman['rating'] as num?)?.toDouble() ?? 0.0;
    final ratingCount = (craftsman['rating_count'] as num?)?.toInt() ?? 0;
    final distanceLabel = craftsman['distance_label']?.toString() ?? '';
    final governorate = craftsman['governorate']?.toString() ?? '';
    final city = craftsman['city']?.toString() ?? '';
    final district = craftsman['district']?.toString() ?? '';
    final craftsmanId = craftsman['id'] as int?;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: isInviting || craftsmanId == null
            ? null
            : () {
                setState(() {
                  _selectedCraftsmanId = craftsmanId;
                });
              },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue.withValues(alpha: 0.1),
                    child: Text(
                      name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Name and Rating
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.orange, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (ratingCount > 0) ...[
                              const SizedBox(width: 4),
                              Text(
                                '($ratingCount)',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Action Buttons
                  if (craftsmanId != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Chat Button
                        IconButton(
                          onPressed: isInviting
                              ? null
                              : () => _openChat(craftsmanId, name),
                          icon: const Icon(Icons.chat, color: Colors.green),
                          tooltip: _localizedText('الدردشة', 'Chat'),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.green.withValues(alpha: 0.1),
                            padding: const EdgeInsets.all(8),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Select/Invite Button
                        ElevatedButton(
                          onPressed: isInviting
                              ? null
                              : () => _inviteCraftsman(craftsmanId),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected ? Colors.green : Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                          ),
                          child: isInviting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  _localizedText('اختر', 'Choisir'),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Location Info
              if (distanceLabel.isNotEmpty || governorate.isNotEmpty)
                Row(
                  children: [
                    const Icon(Icons.place, color: Colors.redAccent, size: 18),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        distanceLabel.isNotEmpty
                            ? distanceLabel
                            : [governorate, city, district]
                                .where((s) => s.isNotEmpty)
                                .join(', '),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

