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

  if (appBox.get('tamponTimer') == null) {
    appBox.put('tamponTimer', 4.0);
  }

  if (appBox.get('padTimer') == null) {
    appBox.put('padTimer', 4.0);
  }

  if (appBox.get('cupTimer') == null) {
    appBox.put('cupTimer', 4.0);
  }
}
