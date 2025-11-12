import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'screens/login_screen.dart';
import 'services/api_service.dart';
import 'services/language_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:handyman_app/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

class HandymanApp extends StatefulWidget {
  const HandymanApp({super.key});

  @override
  State<HandymanApp> createState() => _HandymanAppState();
}

class _HandymanAppState extends State<HandymanApp> {
  Locale _locale = LanguageService.defaultLocale;

  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final savedLocale = await LanguageService.getSavedLocale();
    if (mounted) {
      setState(() {
        _locale = savedLocale;
      });
    }
  }

  void changeLocale(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
    LanguageService.saveLocale(newLocale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Handyman App',
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LanguageService.getSupportedLocales(),
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
      builder: (context, child) {
        return _LocaleProvider(
          locale: _locale,
          changeLocale: changeLocale,
          child: child!,
        );
      },
    );
  }
}

class _LocaleProvider extends InheritedWidget {
  final Locale locale;
  final Function(Locale) changeLocale;

  const _LocaleProvider({
    required this.locale,
    required this.changeLocale,
    required super.child,
  });

  static _LocaleProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_LocaleProvider>();
  }

  @override
  bool updateShouldNotify(_LocaleProvider oldWidget) {
    return locale != oldWidget.locale;
  }
}

extension LocaleExtension on BuildContext {
  void changeAppLocale(Locale newLocale) {
    final provider = _LocaleProvider.of(this);
    provider?.changeLocale(newLocale);
  }
}

