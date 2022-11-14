import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;

import '../day_data.dart';
import '../timer_data.dart';


class ImportHelper {

  static Future<File> localFile(String filePath) async {
    return File(filePath);
  }

  static void getJsonData(BuildContext context, PlatformFile file) async {
    var appBox = Hive.box('app_box');
    var dateBox = Hive.box('date_box');
    final File fileData = await localFile(file.path!);
    String fileAsString = '';
    dynamic importedJson;

    try {
      fileAsString = await fileData.readAsString();
      importedJson = json.decode(fileAsString);
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.unsupportedFile),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.okUpper)),
            ],
          );
        },
      );
    }

    try {
      if (importedJson?['environment']?['application_id'] == 'com.lakoliu.tyd') {

        for (var item in importedJson['data']) {
          var date = item['date'];
          var dayData = DayData();
          dayData.period = item['period'];
          dayData.pms = item['pms'];
          dayData.bleeding = item['bleeding'];
          dayData.pain = item['pain'];
          dayData.periodSymptoms = List<String>.from(item['periodSymptoms']);
          dayData.periodMedsTaken = List<List<String>>.from(item['periodMedsTaken']);
          dayData.periodNotes = item['periodNotes'];
          dayData.pmsSymptoms = List<String>.from(item['pmsSymptoms']);
          dayData.pmsMedsTaken = List<List<String>>.from(item['pmsMedsTaken']);
          dayData.pmsNotes = item['pmsNotes'];
          // dayData.timerData = List<TimerData>.from(item['timerData']);

          dateBox.put(date, dayData);
        }
        appBox.put('medicines', List<String>.from(importedJson['settings']['medicines']));
        appBox.put('periodSymptoms', List<String>.from(importedJson['settings']['periodSymptoms']));
        appBox.put('pmsSymptoms', List<String>.from(importedJson['settings']['pmsSymptoms']));
        appBox.put('sanitaryTypes', Map<String, double>.from(importedJson['settings']['sanitaryTypes']));
        appBox.put('tamponSizes', List<String>.from(importedJson['settings']['tamponSizes']));
      } else if (importedJson?['environment']?['application_id'] == 'com.clue.android') {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.bleedingDataChange),
              content: Text(AppLocalizations.of(context)!.bleedingDataChangeDetails),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.cancelUpper),
                ),
                TextButton(
                  onPressed: () {
                    for (var item in importedJson['data']) {
                      var date = item['day'].substring(0,10);
                      var dayData = DayData();
                      var bleeding = item['period'];
                      // if on period
                      if(bleeding != null && bleeding != 'spotting') {
                        dayData.period = true;
                        switch (bleeding) {
                          case ('light'): dayData.bleeding = 0.3;
                          break;
                          case('medium'): dayData.bleeding = 0.6;
                          break;
                          case('heavy'): dayData.bleeding = 0.9;
                          break;
                        }

                        if (item['pain'] != null) {
                          for (var painType in item['pain']) {
                            var painTypeCapitalized = toBeginningOfSentenceCase(painType);
                            if (painTypeCapitalized != null) {
                              if (appBox.get('periodSymptoms').contains(painTypeCapitalized)) {
                                dayData.periodSymptoms.add(painTypeCapitalized);
                              }
                            }
                          }
                        }
                      } else if (item['pain'] != null) { // if not on period
                        for (var painType in item['pain']) {
                          var painTypeCapitalized = toBeginningOfSentenceCase(painType);
                          if (painTypeCapitalized != null) {
                            if (appBox.get('pmsSymptoms').contains(painTypeCapitalized)) {
                              dayData.pmsSymptoms.add(painTypeCapitalized);
                            }
                          }
                        }
                      }
                      dateBox.put(date, dayData);
                    }
                    Navigator.pop(context);
                  },
                  child: Text(AppLocalizations.of(context)!.importUpper),
                ),
              ],
            );
          },
        );

      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.unsupportedFile),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(AppLocalizations.of(context)!.okUpper)),
              ],
            );
          },
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.failedImport),
            content: Text(e.toString()),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.okUpper)),
            ],
          );
        },
      );
    }
    // If data comes from the Clue app

  }
}