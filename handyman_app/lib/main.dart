import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'screens/login_screen.dart';
import 'services/api_service.dart';
import 'package:flutter/foundation.dart';

void main() {
  // فقط للـ mobile platforms
  if (!kIsWeb) {
    HttpOverrides.global = MyHttpOverrides();
  }
  ApiService.init();
  runApp(const HandymanApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

class HandymanApp extends StatelessWidget {
  const HandymanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Handyman App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Cairo',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Cairo'),
          displayMedium: TextStyle(fontFamily: 'Cairo'),
          displaySmall: TextStyle(fontFamily: 'Cairo'),
          headlineLarge: TextStyle(fontFamily: 'Cairo'),
          headlineMedium: TextStyle(fontFamily: 'Cairo'),
          headlineSmall: TextStyle(fontFamily: 'Cairo'),
          titleLarge: TextStyle(fontFamily: 'Cairo'),
          titleMedium: TextStyle(fontFamily: 'Cairo'),
          titleSmall: TextStyle(fontFamily: 'Cairo'),
          bodyLarge: TextStyle(fontFamily: 'Cairo'),
          bodyMedium: TextStyle(fontFamily: 'Cairo'),
          bodySmall: TextStyle(fontFamily: 'Cairo'),
          labelLarge: TextStyle(fontFamily: 'Cairo'),
          labelMedium: TextStyle(fontFamily: 'Cairo'),
          labelSmall: TextStyle(fontFamily: 'Cairo'),
        ),
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

