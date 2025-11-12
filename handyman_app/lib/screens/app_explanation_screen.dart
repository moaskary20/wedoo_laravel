import 'package:flutter/material.dart';
import '../services/language_service.dart';
import 'conversations_screen.dart';
import 'package:handyman_app/l10n/app_localizations.dart';

class AppExplanationScreen extends StatefulWidget {
  const AppExplanationScreen({super.key});

  @override
  State<AppExplanationScreen> createState() => _AppExplanationScreenState();
}

class _AppExplanationScreenState extends State<AppExplanationScreen> {
  Locale _currentLocale = LanguageService.defaultLocale;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocale();
  }

  Future<void> _loadCurrentLocale() async {
    final locale = await LanguageService.getSavedLocale();
    if (mounted) {
      setState(() {
        _currentLocale = locale;
      });
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
            l10n.appExplanation,
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
        body: Stack(
          children: [
            // Main content
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // First Card - How to create a request
                  _buildExplanationCard(
                    l10n.howToCreateRequest,
                    l10n.learnHowToCreate,
                    Icons.build,
                    Colors.blue,
                    () => _showCreateRequestTutorial(),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Second Card - How to choose the right craftsman
                  _buildExplanationCard(
                    l10n.howToChooseCraftsman,
                    l10n.tipsForChoosing,
                    Icons.person_search,
                    Colors.green,
                    () => _showCraftsmanSelectionTutorial(),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Additional explanation cards
                  _buildExplanationCard(
                    l10n.howToCommunicate,
                    l10n.communicationMethods,
                    Icons.chat,
                    Colors.orange,
                    () => _showCommunicationTutorial(),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  _buildExplanationCard(
                    l10n.rateService,
                    l10n.howToRate,
                    Icons.star,
                    Colors.purple,
                    () => _showRatingTutorial(),
                  ),
                  
                  const SizedBox(height: 100), // Space for floating button
                ],
              ),
            ),
            
            // Floating Help Button
            Positioned(
              left: 20,
              top: 100,
              child: _buildFloatingHelpButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanationCard(String title, String description, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFffe480),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 30,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            
            // Arrow icon
            Icon(
              Icons.arrow_back_ios,
              color: Colors.grey[600],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateRequestTutorial() {
    final l10n = AppLocalizations.of(context)!;
    _showTutorialDialog(
      l10n.howToCreateRequest,
      [
        l10n.step1ChooseService,
        l10n.step2FillDetails,
        l10n.step3SetBudget,
        l10n.step4AttachPhotos,
        l10n.step5SendRequest,
        l10n.step6WaitResponse,
      ],
    );
  }

  void _showCraftsmanSelectionTutorial() {
    final l10n = AppLocalizations.of(context)!;
    _showTutorialDialog(
      l10n.howToChooseCraftsman,
      [
        l10n.step1ReviewRatings,
        l10n.step2ComparePrices,
        l10n.step3CheckExperience,
        l10n.step4ReadComments,
        l10n.step5CheckAvailability,
        l10n.step6CommunicateBefore,
      ],
    );
  }

  void _showCommunicationTutorial() {
    final l10n = AppLocalizations.of(context)!;
    _showTutorialDialog(
      l10n.howToCommunicate,
      [
        l10n.step1UseMessaging,
        l10n.step2SetAppointment,
        l10n.step3DiscussDetails,
        l10n.step4CheckWarranty,
        l10n.step5KeepRecords,
        l10n.step6RateAfterWork,
      ],
    );
  }

  void _showRatingTutorial() {
    final l10n = AppLocalizations.of(context)!;
    _showTutorialDialog(
      l10n.rateService,
      [
        l10n.step1RateQuality,
        l10n.step2RatePunctuality,
        l10n.step3RateProfessionalism,
        l10n.step4WriteComment,
        l10n.step5AttachWorkPhotos,
        l10n.step6HelpOthers,
      ],
    );
  }

  void _showTutorialDialog(String title, List<String> steps) {
    final l10n = AppLocalizations.of(context)!;
    final isRtl = _currentLocale.languageCode == 'ar';
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: AlertDialog(
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: steps.map((step) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: const Color(0xFFfec901),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '•',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          step,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  l10n.close,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFloatingHelpButton() {
    final l10n = AppLocalizations.of(context)!;
    
    return GestureDetector(
      onTap: () {
        openSupportChat(context);
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.8),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.message,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(height: 2),
            Text(
              l10n.help,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
