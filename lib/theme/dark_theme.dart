import 'package:flutter/material.dart';

final darkWeatherTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF23254A),
  cardColor: const Color(0xFF282B58),
  colorScheme: ColorScheme.dark(
    background: const Color(0xFF23254A),
    primary: const Color(0xFFFF4D6D), // accent đỏ
    surface: const Color(0xFF282B58),
    onSurface: Colors.white,
    onPrimary: Colors.white,
    error: Colors.redAccent,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF23254A),
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 22,
      color: Colors.white,
      letterSpacing: 1.1,
    ),
  ),
cardTheme: CardThemeData(
  color: const Color(0xFF282B58),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(22)),
    side: BorderSide(color: Colors.white24, width: 1.2),
  ),
  elevation: 0,
  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
  shadowColor: Colors.transparent,
),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      color: Colors.white,
      fontSize: 56,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.5,
    ),
    headlineMedium: TextStyle(
      color: Colors.white,
      fontSize: 28,
      fontWeight: FontWeight.bold,
    ),
    titleMedium: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    bodyMedium: TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    labelLarge: TextStyle(
      color: Color(0xFFFF4D6D), // accent đỏ cho max temp
      fontWeight: FontWeight.w600,
      fontSize: 16,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF2E2F53),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    hintStyle: const TextStyle(
      color: Colors.white70,
      fontStyle: FontStyle.italic,
    ),
  ),
  iconTheme: const IconThemeData(
    color: Colors.white,
    size: 26,
  ),
  listTileTheme: const ListTileThemeData(
    tileColor: Color(0xFF282B58),
    textColor: Colors.white,
    iconColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
    selectedTileColor: Color(0x26FF4D6D),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFFFF4D6D),
    foregroundColor: Colors.white,
  ),
  useMaterial3: true,
);