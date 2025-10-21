import 'package:dio/dio.dart';
import 'package:dio_web_adapter/dio_web_adapter.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';

class ApiService {
  static final Dio _dio = Dio();
  
  static void init() {
    _dio.options.baseUrl = ApiConfig.baseUrl;
    _dio.options.connectTimeout = Duration(seconds: 30);
    _dio.options.receiveTimeout = Duration(seconds: 30);
    
    // إضافة web adapter للـ Flutter Web
    if (kIsWeb) {
      _dio.httpClientAdapter = WebAdapter();
    }
    
    // إضافة interceptors
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers.addAll(ApiConfig.headers);
        print('Request: ${options.method} ${options.uri}');
        print('Headers: ${options.headers}');
        print('Data: ${options.data}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        print('Response: ${response.statusCode} ${response.requestOptions.uri}');
        print('Response Data: ${response.data}');
        handler.next(response);
      },
      onError: (error, handler) {
        print('Error: ${error.message}');
        print('Error Response: ${error.response?.data}');
        handler.next(error);
      },
    ));
  }
  
  static Future<Response> post(String path, {Map<String, dynamic>? data}) async {
    try {
      return await _dio.post(path, data: data);
    } catch (e) {
      print('API Error: $e');
      rethrow;
    }
  }
  
  static Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } catch (e) {
      print('API Error: $e');
      rethrow;
    }
  }
  
  static Future<Response> put(String path, {Map<String, dynamic>? data}) async {
    try {
      return await _dio.put(path, data: data);
    } catch (e) {
      print('API Error: $e');
      rethrow;
    }
  }
  
  static Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } catch (e) {
      print('API Error: $e');
      rethrow;
    }
  }
}
