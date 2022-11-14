import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';

class MedicinesView extends StatefulWidget {
  const MedicinesView({Key? key}) : super(key: key);

  @override
  State<MedicinesView> createState() => _MedicinesViewState();
}

class _MedicinesViewState extends State<MedicinesView> {
  var appBox = Hive.box('app_box');
  var addMedicineText = '';
  var medicineList = [];

  void saveMedicines() {
    appBox.put('medicines', medicineList);
  }

  void emptySnack() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    var snackBar = SnackBar(
      content: Text(AppLocalizations.of(context)!.medicineBlank),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void initState() {
    super.initState();
    medicineList = appBox.get('medicines').toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.editMedicines,
        ),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            for (var i = 0; i < medicineList.length; i++) ...[
              ListTile(
                title: Text(
                  medicineList[i],
                  style: const TextStyle(
                    fontSize: 25.0,
                  ),
                ),
                trailing: const Icon(Icons.edit),
                onTap: () {
                  // currMedicineName necessary to prevent "out of range" error
                  var currMedicineName = medicineList[i];
                  addMedicineText = currMedicineName;
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(AppLocalizations.of(context)!.editMedicine),
                        content: TextFormField(
                          initialValue: currMedicineName,
                          textCapitalization: TextCapitalization.words,
                          onChanged: (value) {
                            addMedicineText = value;
                          },
                        ),
                        actionsAlignment: MainAxisAlignment.spaceEvenly,
                        actions: [
                          TextButton(
                            child:
                                Text(AppLocalizations.of(context)!.cancelUpper),
                            onPressed: () {
                              Navigator.pop(context);
                              addMedicineText = '';
                            },
                          ),
                          TextButton(
                            child:
                                Text(AppLocalizations.of(context)!.deleteUpper),
                            onPressed: () {
                              setState(() {
                                Navigator.pop(context);
                                medicineList.removeAt(i);
                                saveMedicines();
                              });
                              addMedicineText = '';
                            },
                          ),
                          TextButton(
                            child:
                                Text(AppLocalizations.of(context)!.saveUpper),
                            onPressed: () {
                              setState(() {
                                if (addMedicineText.isNotEmpty) {
                                  if (medicineList[i] != addMedicineText &&
                                      medicineList.contains(addMedicineText)) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(
                                              AppLocalizations.of(context)!
                                                  .medicineExists),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: Text(
                                                  AppLocalizations.of(context)!
                                                      .okUpper),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  } else {
                                    medicineList[i] = addMedicineText;
                                    Navigator.pop(context);
                                    saveMedicines();
                                  }
                                } else {
                                  emptySnack();
                                }
                              });
                              addMedicineText = '';
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
            ListTile(
              title: Text(
                AppLocalizations.of(context)!.addDotDot,
                style: const TextStyle(
                  fontSize: 25.0,
                ),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(AppLocalizations.of(context)!.addMedicine),
                      content: TextField(
                        textCapitalization: TextCapitalization.words,
                        onChanged: (value) {
                          addMedicineText = value;
                        },
                      ),
                      actionsAlignment: MainAxisAlignment.spaceEvenly,
                      actions: [
                        TextButton(
                          child:
                              Text(AppLocalizations.of(context)!.cancelUpper),
                          onPressed: () {
                            Navigator.pop(context);
                            addMedicineText = '';
                          },
                        ),
                        TextButton(
                          child: Text(AppLocalizations.of(context)!.saveUpper),
                          onPressed: () {
                            setState(() {
                              if (addMedicineText.isNotEmpty) {
                                if (medicineList.contains(addMedicineText)) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(
                                            AppLocalizations.of(context)!
                                                .medicineExists),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text(
                                                AppLocalizations.of(context)!
                                                    .okUpper),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                } else {
                                  medicineList.add(addMedicineText);
                                  saveMedicines();
                                  Navigator.pop(context);
                                }
                              } else {
                                emptySnack();
                              }
                            });
                            addMedicineText = '';
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
