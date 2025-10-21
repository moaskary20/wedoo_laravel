import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';

class JsFlutterApiService {
  static Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? data}) async {
    if (!kIsWeb) {
      throw Exception('JsFlutterApiService is only for web platform');
    }
    
    try {
      final url = '${ApiConfig.baseUrl}$path';
      
      print('JS Flutter API Request: POST $url');
      print('JS Flutter API Data: $data');
      
      // استخدام JavaScript مباشرة
      final result = await html.window.flutterApi.post(url, data);
      
      print('JS Flutter API Response: $result');
      return result;
    } catch (e) {
      print('JS Flutter API Error: $e');
      rethrow;
    }
  }
  
  static Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? queryParameters}) async {
    if (!kIsWeb) {
      throw Exception('JsFlutterApiService is only for web platform');
    }
    
    try {
      final url = '${ApiConfig.baseUrl}$path';
      
      print('JS Flutter API Request: GET $url');
      
      // استخدام JavaScript مباشرة
      final result = await html.window.flutterApi.get(url);
      
      print('JS Flutter API Response: $result');
      return result;
    } catch (e) {
      print('JS Flutter API Error: $e');
      rethrow;
    }
  }
}
