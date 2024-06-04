import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// same colors :
// seach box
// main title and description
class MyAppColors {
  static const lightTextColor = Color(0xFF000000);
  static const lightBackgroundColor = Color(0xFFFFFFFF);
  static const lightContainerColor = Color(0xFFA792F9);
  static const lightBackgroundMenu = Color(0xFFF9F8FF);
  static const lightFloatingBackgroundColor = Color(0xFF2F1A1A);
  static const lightFloatingIconColor = Color(0xFFFFFCFC);

  static const darkTextColor = Color(0xFFF4F4F4);
  static const darkBackgroundColor = Color(0xFF231717);
  static final darkContainerColor = const Color(0xFFA792F9).withOpacity(0.2);
  static const darkBackgroundMenu = Color(0xFF424048);
  static const darkFloatingBackgroundColor = Color(0xFFFFFFFF);
  static const darkFloatingIconColor = Color(0xFF150B0B);
}

class MyAppThemes {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: MyAppColors.lightTextColor),
    ),
    scaffoldBackgroundColor: MyAppColors.lightBackgroundColor,
    primaryColor: MyAppColors.lightContainerColor,
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: MyAppColors.lightFloatingBackgroundColor,
    ),
    colorScheme: const ColorScheme.light(
        onPrimary: MyAppColors.lightBackgroundMenu,
        onSecondary: MyAppColors.lightFloatingIconColor),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: MyAppColors.darkTextColor),
    ),
    scaffoldBackgroundColor: MyAppColors.darkBackgroundColor,
    primaryColor: MyAppColors.darkContainerColor,
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: MyAppColors.darkFloatingBackgroundColor,
    ),
    colorScheme: const ColorScheme.dark(
        onPrimary: MyAppColors.darkBackgroundMenu,
        onSecondary: MyAppColors.darkFloatingIconColor),
  );
}

// save theme class

class ThemeService {
  static const String _themeModeKey = 'themeMode';

  Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString(_themeModeKey);
    if (themeModeString == null) {
      return ThemeMode.system;
    }
    return ThemeMode.values.firstWhere(
      (mode) => mode.toString() == themeModeString,
    );
  }

  Future<void> saveThemeMode(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, themeMode.toString());
  }
}
