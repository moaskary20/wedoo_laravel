import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import 'web_api_service.dart';
import 'fallback_api_service.dart';
import 'proxy_api_service.dart';
import 'js_api_service.dart';

class ApiService {
  static final Dio _dio = Dio();
  
  static void init() {
    if (kIsWeb) {
      WebApiService.init();
      return;
    }
    
    _dio.options.baseUrl = ApiConfig.baseUrl;
    _dio.options.connectTimeout = Duration(seconds: 30);
    _dio.options.receiveTimeout = Duration(seconds: 30);
    
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
    if (kIsWeb) {
      try {
        // محاولة WebApiService أولاً
        return await WebApiService.post(path, data: data);
      } catch (e) {
        print('WebApiService failed, trying FallbackApiService: $e');
        try {
          // استخدام FallbackApiService كبديل
          final result = await FallbackApiService.post(path, data: data);
          return Response(
            data: result,
            statusCode: 200,
            requestOptions: RequestOptions(path: path),
          );
        } catch (fallbackError) {
          print('FallbackApiService also failed, trying ProxyApiService: $fallbackError');
          try {
            // استخدام ProxyApiService كحل أخير
            final result = await ProxyApiService.post(path, data: data);
            return Response(
              data: result,
              statusCode: 200,
              requestOptions: RequestOptions(path: path),
            );
          } catch (proxyError) {
            print('ProxyApiService also failed, trying JsApiService: $proxyError');
            try {
              // استخدام JsApiService كحل أخير
              final result = await JsApiService.post(path, data: data);
              return Response(
                data: result,
                statusCode: 200,
                requestOptions: RequestOptions(path: path),
              );
            } catch (jsError) {
              print('JsApiService also failed: $jsError');
              rethrow;
            }
          }
        }
      }
    }
    
    try {
      return await _dio.post(path, data: data);
    } catch (e) {
      print('API Error: $e');
      rethrow;
    }
  }
  
  static Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    if (kIsWeb) {
      try {
        // محاولة WebApiService أولاً
        return await WebApiService.get(path, queryParameters: queryParameters);
      } catch (e) {
        print('WebApiService failed, trying FallbackApiService: $e');
        try {
          // استخدام FallbackApiService كبديل
          final result = await FallbackApiService.get(path, queryParameters: queryParameters);
          return Response(
            data: result,
            statusCode: 200,
            requestOptions: RequestOptions(path: path),
          );
        } catch (fallbackError) {
          print('FallbackApiService also failed, trying ProxyApiService: $fallbackError');
          try {
            // استخدام ProxyApiService كحل أخير
            final result = await ProxyApiService.get(path, queryParameters: queryParameters);
            return Response(
              data: result,
              statusCode: 200,
              requestOptions: RequestOptions(path: path),
            );
          } catch (proxyError) {
            print('ProxyApiService also failed, trying JsApiService: $proxyError');
            try {
              // استخدام JsApiService كحل أخير
              final result = await JsApiService.get(path, queryParameters: queryParameters);
              return Response(
                data: result,
                statusCode: 200,
                requestOptions: RequestOptions(path: path),
              );
            } catch (jsError) {
              print('JsApiService also failed: $jsError');
              rethrow;
            }
          }
        }
      }
    }
    
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
