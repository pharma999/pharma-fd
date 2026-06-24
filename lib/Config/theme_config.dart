import 'package:flutter/material.dart';
import 'package:home_care/Config/colors_config.dart';
import 'package:home_care/Config/colors_coning.dart';

var lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    primary: kPrimary,
    onPrimary: kSurface,
    surface: kBackground,
    onSurface: kTextDark,
    primaryContainer: kPrimaryLight,
    onPrimaryContainer: kPrimaryDark,
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(fontSize: 32, fontFamily: 'Poppins', fontWeight: FontWeight.w800, color: kPrimary),
    headlineMedium: TextStyle(fontSize: 28, fontFamily: 'Poppins', fontWeight: FontWeight.w700, color: kTextDark),
    headlineSmall: TextStyle(fontSize: 20, fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: kTextDark),
    bodyLarge: TextStyle(fontSize: 16, fontFamily: 'Poppins', fontWeight: FontWeight.w500, color: kTextDark),
    bodyMedium: TextStyle(fontSize: 14, fontFamily: 'Poppins', fontWeight: FontWeight.w400, color: kTextMedium),
    labelLarge: TextStyle(fontSize: 14, fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: kTextDark),
    labelMedium: TextStyle(fontSize: 12, fontFamily: 'Poppins', fontWeight: FontWeight.w400, color: kTextMedium),
    labelSmall: TextStyle(fontSize: 10, fontFamily: 'Poppins', fontWeight: FontWeight.w300, color: kTextLight),
  ),
);
var darkTheme = ThemeData(
  inputDecorationTheme: InputDecorationTheme(
    fillColor: dBackgroundColor,
    filled: true,
  ),

  brightness: Brightness.dark,
  useMaterial3: true,
  appBarTheme: AppBarTheme(backgroundColor: dContainerColor),
  colorScheme: ColorScheme.dark(
    primary: dPrimaryColor,
    onPrimary: dBackgroundColor,
    surface: dBackgroundColor,
    onSurface: dOnContainerColor,
    primaryContainer: dContainerColor,
    onPrimaryContainer: dOnContainerColor,
  ),

  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 32,
      color: dPrimaryColor,
      fontFamily: "Poppins",
      fontWeight: FontWeight.w800,
    ),
    headlineMedium: TextStyle(
      fontSize: 30,
      color: dOnBackGroundColor,
      fontFamily: "Poppins",
      fontWeight: FontWeight.w600,
    ),
    headlineSmall: TextStyle(
      fontSize: 20,
      color: dOnContainerColor,
      fontFamily: "Poppins",
      fontWeight: FontWeight.w600,
    ),

    labelLarge: TextStyle(
      fontSize: 15,
      color: dOnContainerColor,
      fontFamily: "Poppins",
      fontWeight: FontWeight.w600,
    ),

    labelMedium: TextStyle(
      fontSize: 12,
      color: dOnContainerColor,
      fontFamily: "Poppins",
      fontWeight: FontWeight.w400,
    ),

    labelSmall: TextStyle(
      fontSize: 10,
      color: dOnBackGroundColor,
      fontFamily: "Poppins",
      fontWeight: FontWeight.w300,
    ),

    bodyLarge: TextStyle(
      fontSize: 18,
      color: dOnBackGroundColor,
      fontFamily: "Poppins",
      fontWeight: FontWeight.w500,
    ),

    bodyMedium: TextStyle(
      fontSize: 15,
      color: dOnBackGroundColor,
      fontFamily: "Poppins",
      fontWeight: FontWeight.w500,
    ),
  ),
);
