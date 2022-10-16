import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

void initializeDatabase() {
  var appBox = Hive.box('app_box');

  if (appBox.get('onPeriod') == null) {
    appBox.put('onPeriod', false);
  }

  if (appBox.get('accentColor') == null) {
    appBox.put('accentColorName', 'Pink');
    appBox.put('accentColor', Colors.pink[300]);
  }
}
