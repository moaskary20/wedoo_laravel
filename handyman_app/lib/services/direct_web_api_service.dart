import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';

class DirectWebApiService {
  static Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? data}) async {
    if (!kIsWeb) {
      throw Exception('DirectWebApiService is only for web platform');
    }
    
    try {
      final url = '${ApiConfig.baseUrl}$path';
      
      print('Direct Web API Request: POST $url');
      print('Direct Web API Data: $data');
      
      // استخدام fetch API مباشرة بدون RequestInit
      final response = await html.window.fetch(
        url,
        {
          'method': 'POST',
          'headers': {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'User-Agent': 'WedooApp/1.0 (Flutter Web)',
            'Origin': 'https://free-styel.store',
          },
          'body': jsonEncode(data),
          'mode': 'cors',
          'credentials': 'include'
        },
      );
      
      print('Direct Web API Response Status: ${response.status}');
      
      if (response.status == 200) {
        final result = await response.json();
        print('Direct Web API Response Data: $result');
        return result;
      } else {
        final errorText = await response.text();
        print('Direct Web API Error Response: $errorText');
        throw Exception('HTTP ${response.status}: $errorText');
      }
    } catch (e) {
      print('Direct Web API Error: $e');
      rethrow;
    }
  }
  
  static Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? queryParameters}) async {
    if (!kIsWeb) {
      throw Exception('DirectWebApiService is only for web platform');
    }
    
    try {
      final url = '${ApiConfig.baseUrl}$path';
      
      print('Direct Web API Request: GET $url');
      
      // استخدام fetch API مباشرة بدون RequestInit
      final response = await html.window.fetch(
        url,
        {
          'method': 'GET',
          'headers': {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'User-Agent': 'WedooApp/1.0 (Flutter Web)',
            'Origin': 'https://free-styel.store',
          },
          'mode': 'cors',
          'credentials': 'include'
        },
      );
      
      print('Direct Web API Response Status: ${response.status}');
      
      if (response.status == 200) {
        final result = await response.json();
        print('Direct Web API Response Data: $result');
        return result;
      } else {
        final errorText = await response.text();
        print('Direct Web API Error Response: $errorText');
        throw Exception('HTTP ${response.status}: $errorText');
      }
    } catch (e) {
      print('Direct Web API Error: $e');
      rethrow;
    }
  }
}
