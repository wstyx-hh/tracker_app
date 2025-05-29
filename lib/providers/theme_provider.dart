import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  int _selectedThemeIndex = 0;
  int get selectedThemeIndex => _selectedThemeIndex;

  static const List<String> themeNames = [
    'Electric Blue',
    'Royal Purple',
    'Emerald',
    'Sunset Orange',
    'Hot Pink',
    'Lime',
    'Ruby Red',
  ];

  static const List<Color> themeColors = [
    Color(0xFF00B4FF), // Electric Blue - более яркий и насыщенный синий
    Color(0xFF8A2BE2), // Royal Purple - насыщенный фиолетовый
    Color(0xFF00E676), // Emerald - яркий изумрудный
    Color(0xFFFF5722), // Sunset Orange - насыщенный оранжевый
    Color(0xFFFF1493), // Hot Pink - яркий розовый
    Color(0xFFCDDC39), // Lime - лаймовый
    Color(0xFFFF1744), // Ruby Red - яркий рубиновый
  ];

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _selectedThemeIndex = prefs.getInt('selectedThemeIndex') ?? 0;
    notifyListeners();
  }

  void toggleTheme(bool isDark) async {
    _isDarkMode = isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
    notifyListeners();
  }

  void setTheme(int index) async {
    if (index >= 0 && index < themeColors.length) {
      _selectedThemeIndex = index;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('selectedThemeIndex', index);
      notifyListeners();
    }
  }

  Color get primaryColor => themeColors[_selectedThemeIndex];

  ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
        ).copyWith(
          primary: primaryColor,
          secondary: primaryColor,
          tertiary: primaryColor.withOpacity(0.7),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shadowColor: primaryColor.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          iconTheme: IconThemeData(color: primaryColor),
        ),
        navigationBarTheme: NavigationBarThemeData(
          elevation: 4,
          backgroundColor: Colors.white,
          indicatorColor: primaryColor.withOpacity(0.15),
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return TextStyle(
                color: primaryColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              );
            }
            return const TextStyle(
              color: Colors.black54,
              fontSize: 13,
            );
          }),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
        ),
        iconTheme: IconThemeData(
          color: primaryColor,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return primaryColor;
            }
            return null;
          }),
          trackColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return primaryColor.withOpacity(0.5);
            }
            return null;
          }),
        ),
      );

  ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.dark,
        ).copyWith(
          primary: primaryColor,
          secondary: primaryColor,
          tertiary: primaryColor.withOpacity(0.7),
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardTheme: CardThemeData(
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: const Color(0xFF1E1E1E),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
        ),
        navigationBarTheme: NavigationBarThemeData(
          elevation: 4,
          backgroundColor: const Color(0xFF1E1E1E),
          indicatorColor: primaryColor.withOpacity(0.15),
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return TextStyle(
                color: primaryColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              );
            }
            return const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            );
          }),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 4,
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2C2C2C),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
        ),
        iconTheme: IconThemeData(
          color: primaryColor,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return primaryColor;
            }
            return null;
          }),
          trackColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return primaryColor.withOpacity(0.5);
            }
            return null;
          }),
        ),
      );
}