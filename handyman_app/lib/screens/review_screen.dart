import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../services/language_service.dart';
import 'package:handyman_app/l10n/app_localizations.dart';

class ReviewScreen extends StatefulWidget {
  final String orderId;
  final String? craftsmanName;
  final String? orderTitle;
  final Map<String, dynamic>? existingReview;

  const ReviewScreen({
    super.key,
    required this.orderId,
    this.craftsmanName,
    this.orderTitle,
    this.existingReview,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isLoading = false;
  bool _isSubmitting = false;
  Locale _currentLocale = LanguageService.defaultLocale;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocale();
    _loadExistingReview();
  }

  Future<void> _loadCurrentLocale() async {
    final locale = await LanguageService.getSavedLocale();
    if (mounted) {
      setState(() {
        _currentLocale = locale;
      });
    }
  }

  void _loadExistingReview() {
    if (widget.existingReview != null) {
      setState(() {
        _selectedRating = widget.existingReview!['rating'] ?? 0;
        _commentController.text = widget.existingReview!['comment'] ?? '';
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

  Future<void> _submitReview() async {
    if (_selectedRating == 0) {
      _showErrorSnackBar('الرجاء اختيار تقييم');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final headers = await _buildAuthHeaders();
      if (headers == null) {
        _showErrorSnackBar('يرجى تسجيل الدخول أولاً');
        return;
      }

      final response = await http.post(
        Uri.parse(ApiConfig.reviewsCreate),
        headers: headers,
        body: jsonEncode({
          'order_id': int.parse(widget.orderId),
          'rating': _selectedRating,
          'comment': _commentController.text.trim(),
        }),
      ).timeout(const Duration(seconds: 30));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['success'] == true) {
          _showSuccessSnackBar('تم إرسال التقييم بنجاح');
          if (mounted) {
            Navigator.of(context).pop(true); // Return true to indicate success
          }
        } else {
          _showErrorSnackBar(responseData['message'] ?? 'فشل في إرسال التقييم');
        }
      } else {
        _showErrorSnackBar(responseData['message'] ?? 'خطأ في الخادم');
      }
    } catch (e) {
      _showErrorSnackBar('خطأ في الاتصال: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
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
            widget.existingReview != null ? 'تعديل التقييم' : 'تقييم الصنايعي',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20,
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
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Order Info Card
                    if (widget.orderTitle != null || widget.craftsmanName != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.orderTitle != null) ...[
                              Text(
                                'الطلب: ${widget.orderTitle}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            if (widget.craftsmanName != null)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.person,
                                    size: 20,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'الصنايعي: ${widget.craftsmanName}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 30),

                    // Rating Section
                    Text(
                      'التقييم',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildRatingStars(),

                    const SizedBox(height: 30),

                    // Comment Section
                    Text(
                      'التعليق (اختياري)',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _commentController,
                        maxLines: 6,
                        decoration: InputDecoration(
                          hintText: 'اكتب تعليقك هنا...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitReview,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          disabledBackgroundColor: Colors.grey,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                widget.existingReview != null
                                    ? 'تحديث التقييم'
                                    : 'إرسال التقييم',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildRatingStars() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          final starIndex = index + 1;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedRating = starIndex;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Icon(
                starIndex <= _selectedRating
                    ? Icons.star
                    : Icons.star_border,
                size: 50,
                color: starIndex <= _selectedRating
                    ? Colors.amber
                    : Colors.grey[400],
              ),
            ),
          );
        }),
      ),
    );
  }
}

