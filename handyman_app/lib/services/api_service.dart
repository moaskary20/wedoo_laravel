import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import 'simple_api_service.dart';

class ApiService {
  static final Dio _dio = Dio();
  
  static void init() {
    if (kIsWeb) {
      // للويب، استخدم SimpleApiService
      SimpleApiService.init();
      return;
    }
    
    _dio.options.baseUrl = ApiConfig.baseUrl;
    _dio.options.connectTimeout = Duration(seconds: 30);
    _dio.options.receiveTimeout = Duration(seconds: 30);
    
    // إضافة interceptors
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        options.headers.addAll(ApiConfig.headers);
        
        // Add authentication token if available
        try {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('access_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        } catch (e) {
          print('Error getting auth token: $e');
        }
        
        print('🚀 Mobile API Request: ${options.method} ${options.uri}');
        print('📦 Mobile API Data: ${options.data}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        print('✅ Mobile API Response: ${response.statusCode} ${response.requestOptions.uri}');
        print('📦 Mobile API Response Data: ${response.data}');
        handler.next(response);
      },
      onError: (error, handler) {
        print('❌ Mobile API Error: ${error.message}');
        print('📦 Mobile API Error Response: ${error.response?.data}');
        handler.next(error);
      },
    ));
  }
  
  static Future<Response> post(String path, {Map<String, dynamic>? data}) async {
    if (kIsWeb) {
      print('🌐 Web Platform: استخدام SimpleApiService');
      return await SimpleApiService.post(path, data: data);
    }
    
    try {
      print('📱 Mobile Platform: استخدام Dio مباشرة');
      return await _dio.post(path, data: data);
    } catch (e) {
      print('❌ Mobile API Error: $e');
      rethrow;
    }
  }
  
  static Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    if (kIsWeb) {
      print('🌐 Web Platform: استخدام SimpleApiService');
      return await SimpleApiService.get(path, queryParameters: queryParameters);
    }
    
    try {
      print('📱 Mobile Platform: استخدام Dio مباشرة');
      return await _dio.get(path, queryParameters: queryParameters);
    } catch (e) {
      print('❌ Mobile API Error: $e');
      rethrow;
    }
  }

  static Future<Response> put(String path, {Map<String, dynamic>? data}) async {
    if (kIsWeb) {
      print('🌐 Web Platform: استخدام SimpleApiService');
      return await SimpleApiService.put(path, data: data);
    }
    
    try {
      print('📱 Mobile Platform: استخدام Dio مباشرة');
      return await _dio.put(path, data: data);
    } catch (e) {
      print('❌ Mobile API Error: $e');
      rethrow;
    }
  }

  static Future<Response> delete(String path) async {
    if (kIsWeb) {
      print('🌐 Web Platform: استخدام SimpleApiService');
      return await SimpleApiService.delete(path);
    }
    
    try {
      print('📱 Mobile Platform: استخدام Dio مباشرة');
      return await _dio.delete(path);
    } catch (e) {
      print('❌ Mobile API Error: $e');
      rethrow;
    }
  }
}