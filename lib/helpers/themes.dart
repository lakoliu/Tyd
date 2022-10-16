import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class MyThemes {

  static final ThemeData lightTheme = ThemeData(
    primaryColor: Hive.box('app_box').get('accentColor') ?? Colors.pink[300],
    appBarTheme: Hive.box('app_box').get('accentColor') ?? Colors.pink[300],
    textSelectionTheme: const TextSelectionThemeData(
      selectionColor: Colors.grey,
      cursorColor: Color(0xff171d49),
      selectionHandleColor: Color(0xff005e91),
    ),
    backgroundColor: Colors.white,
    brightness: Brightness.light,
    highlightColor: Colors.white,
    floatingActionButtonTheme:
    FloatingActionButtonThemeData (backgroundColor: Colors.blue,focusColor: Colors.blueAccent , splashColor: Colors.lightBlue),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: Hive.box('app_box').get('accentColor') ?? Colors.pink[300],
      secondary: Colors.white,
    ),
  );
}