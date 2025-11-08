import 'package:flutter/material.dart';
import 'package:home_care/Config/colors_config.dart';

var lightTheme = ThemeData();
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
