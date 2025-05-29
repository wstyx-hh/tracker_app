import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  static const String _preferredLocaleKey = 'preferred_locale';
  SharedPreferences? _prefs;
  
  final List<Locale> supportedLocales = [
    const Locale('en'), // English
    const Locale('ru'), // Russian
  ];

  final Map<String, String> languageNames = {
    'en': 'English',
    'ru': 'Русский',
  };

  Locale _currentLocale = const Locale('en'); // Set English as default

  LocaleProvider() {
    _loadSavedLocale();
  }

  Locale get currentLocale => _currentLocale;

  Future<void> _loadSavedLocale() async {
    _prefs = await SharedPreferences.getInstance();
    final savedLocale = _prefs?.getString(_preferredLocaleKey);
    if (savedLocale != null) {
      _currentLocale = Locale(savedLocale);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) return;
    
    _currentLocale = locale;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setString(_preferredLocaleKey, locale.languageCode);
    notifyListeners();
  }
}