import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:hive/hive.dart';

class IntervalsView extends StatefulWidget {
  const IntervalsView({Key? key}) : super(key: key);

  @override
  State<IntervalsView> createState() => _IntervalsViewState();
}

class _IntervalsViewState extends State<IntervalsView> {
  var appBox = Hive.box('app_box');
  var sanitaryItems = {};

  void saveSanitaryTypes() {
    appBox.put('sanitaryTypes', sanitaryItems);
  }

  @override
  void initState() {
    super.initState();
    sanitaryItems = appBox.get('sanitaryTypes');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.editIntervals,
        ),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            for (var sanitaryItem in sanitaryItems.keys) ...[
              ListTile(
                title: Text(sanitaryItem),
                trailing: Text(
                  sanitaryItems[sanitaryItem]! % 1 != 0
                      ? AppLocalizations.of(context)!
                          .nHours(sanitaryItems[sanitaryItem])
                      : AppLocalizations.of(context)!
                          .nHours(sanitaryItems[sanitaryItem].toInt()),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      var currInterval = sanitaryItems[sanitaryItem] ?? 4.0;
                      return AlertDialog(
                        title: Text(AppLocalizations.of(context)!
                            .itemInterval(sanitaryItem)),
                        content: SpinBox(
                          decimals: 1,
                          min: 0.5,
                          max: 10.0,
                          step: 0.5,
                          value: currInterval,
                          onChanged: (value) {
                            setState(() {
                              currInterval = value;
                            });
                          },
                        ),
                        actions: [
                          TextButton(
                            child:
                                Text(AppLocalizations.of(context)!.cancelUpper),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          TextButton(
                            child:
                                Text(AppLocalizations.of(context)!.saveUpper),
                            onPressed: () {
                              setState(() {
                                sanitaryItems[sanitaryItem] = currInterval;
                                saveSanitaryTypes();
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
