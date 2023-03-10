import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:share_plus/share_plus.dart';

class ExportHelper {
  static void exportSavedData(BuildContext context) async {
    var dateBox = Hive.box('date_box');
    var appBox = Hive.box('app_box');
    var dateBoxDays = dateBox.keys.toList();
    List<String> jsonDateList = [];

    File exportedFile;
    exportedFile =
        File('${(await Directory.systemTemp.createTemp()).path}/Tyd.json');
    try {
      for (var date in dateBoxDays) {
        var jsonEncodedData = jsonEncode(dateBox.get(date));
        jsonEncodedData =
            '${jsonEncodedData.substring(0, 1)}"date":"$date",${jsonEncodedData.substring(1, jsonEncodedData.length)}';
        jsonDateList.add(jsonEncodedData);
      }
      var jsonMedicines = '"medicines": ${jsonEncode(appBox.get('medicines'))}';
      var jsonPeriodSymptoms =
          '"periodSymptoms": ${jsonEncode(appBox.get('periodSymptoms'))}';
      var jsonPmsSymptoms =
          '"pmsSymptoms": ${jsonEncode(appBox.get('pmsSymptoms'))}';
      var jsonSanitaryTypes =
          '"sanitaryTypes": ${jsonEncode(appBox.get('sanitaryTypes'))}';
      var jsonTamponSizes =
          '"tamponSizes": ${jsonEncode(appBox.get('tamponSizes'))}';

      var jsonSettings =
          '"settings": {$jsonMedicines,$jsonPeriodSymptoms,$jsonPmsSymptoms,$jsonSanitaryTypes,$jsonTamponSizes}';

      exportedFile = await exportedFile.writeAsString(
          '{"data":$jsonDateList,$jsonSettings,"environment":{"application_id":"com.lakoliu.tyd"}}');
      Share.shareXFiles([XFile(exportedFile.path)]);
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.failedExport),
            content: Text(e.toString()),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK')),
            ],
          );
        },
      );
    }
  }
}
