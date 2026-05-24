import 'package:flutter/material.dart';

const _seed = Color(0xFF1A3C5E); // deep navy blue

final appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: _seed,
    brightness: Brightness.light,
  ),
  appBarTheme: AppBarTheme(
    centerTitle: true,
    elevation: 0,
    backgroundColor: ColorScheme.fromSeed(seedColor: _seed).primaryContainer,
    foregroundColor: ColorScheme.fromSeed(seedColor: _seed).onPrimaryContainer,
  ),
  cardTheme: CardThemeData(
    elevation: 1,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: Colors.grey.shade200),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      minimumSize: const Size.fromHeight(52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size.fromHeight(52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    filled: true,
    fillColor: Colors.grey.shade50,
  ),
  sliderTheme: const SliderThemeData(
    showValueIndicator: ShowValueIndicator.onDrag,
  ),
  dividerTheme: DividerThemeData(
    color: Colors.grey.shade200,
    space: 1,
  ),
  checkboxTheme: CheckboxThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  ),
);
