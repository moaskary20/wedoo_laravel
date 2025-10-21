import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import 'dart:js' as js;
import '../config/api_config.dart';

class JsApiService {
  static Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? data}) async {
    if (!kIsWeb) {
      throw Exception('JsApiService is only for web platform');
    }
    
    try {
      final url = '${ApiConfig.baseUrl}$path';
      
      print('JS API Request: POST $url');
      print('JS API Data: $data');
      
      // استخدام JavaScript interop
      final result = await js.context.callMethod('apiProxy.post', [
        url,
        data,
        <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'WedooApp/1.0 (Flutter Web)',
          'Origin': 'https://free-styel.store',
        }
      ]);
      
      print('JS API Response: $result');
      return Map<String, dynamic>.from(result);
    } catch (e) {
      print('JS API Error: $e');
      rethrow;
    }
  }
  
  static Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? queryParameters}) async {
    if (!kIsWeb) {
      throw Exception('JsApiService is only for web platform');
    }
    
    try {
      final url = '${ApiConfig.baseUrl}$path';
      
      print('JS API Request: GET $url');
      print('JS API Query Parameters: $queryParameters');
      
      // استخدام JavaScript interop
      final result = await js.context.callMethod('apiProxy.get', [
        url,
        <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'WedooApp/1.0 (Flutter Web)',
          'Origin': 'https://free-styel.store',
        }
      ]);
      
      print('JS API Response: $result');
      return Map<String, dynamic>.from(result);
    } catch (e) {
      print('JS API Error: $e');
      rethrow;
    }
  }
}
