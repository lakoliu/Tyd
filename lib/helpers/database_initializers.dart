import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:vula/helpers/constants.dart';

void initializeDatabase() {
  var appBox = Hive.box('app_box');

  if (appBox.get('onPeriod') == null) {
    appBox.put('onPeriod', false);
  }

  if (appBox.get('darkMode') == null) {
    appBox.put('darkMode', false);
  }

  if (appBox.get('accentColor') == null) {
    appBox.put('accentColorName', 'Pink');
    appBox.put('accentColor', Colors.pink[300]);
  }

  if (appBox.get('tamponSizes') == null) {
    appBox.put('tamponSizes', tamponSizes);
  }

  if (appBox.get('periodSymptoms') == null) {
    appBox.put('periodSymptoms', periodSymptoms);
  }

  if (appBox.get('pmsSymptoms') == null) {
    appBox.put('pmsSymptoms', pmsSymptoms);
  }

  if (appBox.get('medicines') == null) {
    appBox.put('medicines', medicines);
  }

  if (appBox.get('sanitaryTypes') == null) {
    appBox.put('sanitaryTypes', sanitaryTypes);
  }
}
