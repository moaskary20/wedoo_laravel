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
    
    // Don't set baseUrl to allow both full URLs and relative paths
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
      // إذا كان path يبدأ بـ http:// أو https://، استخدمه مباشرة
      // وإلا استخدم baseUrl + path
      final url = path.startsWith('http://') || path.startsWith('https://')
          ? path
          : '${ApiConfig.baseUrl}$path';
      
      print('📱 Mobile Platform: استخدام Dio مباشرة');
      print('   📍 Path: $path');
      print('   🌐 Full URL: $url');
      print('   📦 Data: $data');
      
      // Create new Dio instance without baseUrl to avoid conflicts
      final dio = Dio();
      dio.options.connectTimeout = Duration(seconds: 30);
      dio.options.receiveTimeout = Duration(seconds: 30);
      
      // Add headers
      final headers = Map<String, String>.from(ApiConfig.headers);
      
      // Add auth token if available
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('access_token');
        if (token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
        }
      } catch (e) {
        print('Error getting auth token: $e');
      }
      
      final response = await dio.post(
        url,
        data: data,
        options: Options(
          headers: headers,
          // Allow 400 and 422 status codes as valid responses (they may contain useful error messages)
          validateStatus: (status) {
            return status != null && status < 500; // Allow all status codes < 500
          },
        ),
      );
      
      print('✅ Mobile API: نجح POST $url');
      print('   📦 Response: ${response.statusCode}');
      return response;
    } catch (e) {
      print('❌ Mobile API Error: $e');
      if (e is DioException && e.response != null) {
        print('   📦 Error Response: ${e.response?.statusCode} - ${e.response?.data}');
      }
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