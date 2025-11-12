import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const String _languageKey = 'selected_language';
  static const Locale arabicLocale = Locale('ar', '');
  static const Locale frenchLocale = Locale('fr', '');
  
  // Default language is Arabic
  static const Locale defaultLocale = arabicLocale;

  /// Get the saved language locale
  static Future<Locale> getSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey);
      
      if (languageCode == null) {
        return defaultLocale;
      }
      
      switch (languageCode) {
        case 'ar':
          return arabicLocale;
        case 'fr':
          return frenchLocale;
        default:
          return defaultLocale;
      }
    } catch (e) {
      print('Error getting saved locale: $e');
      return defaultLocale;
    }
  }

  /// Save the selected language
  static Future<void> saveLocale(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, locale.languageCode);
    } catch (e) {
      print('Error saving locale: $e');
    }
  }

  /// Get language name for display
  static String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
        return 'العربية';
      case 'fr':
        return 'Français';
      default:
        return 'العربية';
    }
  }

  /// Get all supported locales
  static List<Locale> getSupportedLocales() {
    return [arabicLocale, frenchLocale];
  }
}

