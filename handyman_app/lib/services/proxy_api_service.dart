import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:html' as html;
import '../config/api_config.dart';

class ProxyApiService {
  static Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? data}) async {
    if (!kIsWeb) {
      throw Exception('ProxyApiService is only for web platform');
    }
    
    try {
      // استخدام fetch API مباشرة
      final url = '${ApiConfig.baseUrl}$path';
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'WedooApp/1.0 (Flutter Web)',
        'Origin': 'https://free-styel.store',
      };
      
      print('Proxy Request: POST $url');
      print('Proxy Headers: $headers');
      print('Proxy Data: $data');
      
      // استخدام fetch API مباشرة
      final response = await html.window.fetch(
        url,
        html.RequestInit(
          method: 'POST',
          headers: headers,
          body: jsonEncode(data),
          mode: html.RequestMode.cors,
          credentials: html.RequestCredentials.include,
        ),
      );
      
      print('Proxy Response: ${response.status}');
      
      if (response.status == 200) {
        final responseText = await response.text();
        print('Proxy Response Body: $responseText');
        return jsonDecode(responseText);
      } else {
        final errorText = await response.text();
        throw Exception('HTTP ${response.status}: $errorText');
      }
    } catch (e) {
      print('Proxy Error: $e');
      rethrow;
    }
  }
  
  static Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? queryParameters}) async {
    if (!kIsWeb) {
      throw Exception('ProxyApiService is only for web platform');
    }
    
    try {
      // استخدام fetch API مباشرة
      final url = '${ApiConfig.baseUrl}$path';
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'WedooApp/1.0 (Flutter Web)',
        'Origin': 'https://free-styel.store',
      };
      
      print('Proxy Request: GET $url');
      print('Proxy Headers: $headers');
      
      // استخدام fetch API مباشرة
      final response = await html.window.fetch(
        url,
        html.RequestInit(
          method: 'GET',
          headers: headers,
          mode: html.RequestMode.cors,
          credentials: html.RequestCredentials.include,
        ),
      );
      
      print('Proxy Response: ${response.status}');
      
      if (response.status == 200) {
        final responseText = await response.text();
        print('Proxy Response Body: $responseText');
        return jsonDecode(responseText);
      } else {
        final errorText = await response.text();
        throw Exception('HTTP ${response.status}: $errorText');
      }
    } catch (e) {
      print('Proxy Error: $e');
      rethrow;
    }
  }
}
