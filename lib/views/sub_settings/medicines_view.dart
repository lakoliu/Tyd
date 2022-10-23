import 'package:flutter/material.dart';
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
    var snackBar = const SnackBar(
      content: Text('Medicine cannot be blank.'),
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
        title: const Text(
          'Edit Medicines',
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
                        title: const Text('Edit Medicine'),
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
                            child: const Text("CANCEL"),
                            onPressed:  () {
                              Navigator.pop(context);
                              addMedicineText = '';
                            },
                          ),
                          TextButton(
                            child: const Text("DELETE"),
                            onPressed:  () {
                              setState(() {
                                Navigator.pop(context);
                                medicineList.removeAt(i);
                                saveMedicines();
                              });
                              addMedicineText = '';
                            },
                          ),
                          TextButton(
                            child: const Text("SAVE"),
                            onPressed:  () {
                              setState(() {
                                if (addMedicineText.isNotEmpty) {
                                  if (medicineList[i] != addMedicineText && medicineList.contains(addMedicineText)) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('That medicine already exists.'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text('OK'),
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
              title: const Text(
                'Add...',
                style: TextStyle(
                  fontSize: 25.0,
                ),
              ),
              onTap: () {
                // TODO AlertDialog popup with entry box and Save or Cancel options
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Add New Medicine'),
                      content: TextField(
                        textCapitalization: TextCapitalization.words,
                        onChanged: (value) {
                          addMedicineText = value;
                        },
                      ),
                      actionsAlignment: MainAxisAlignment.spaceEvenly,
                      actions: [
                        TextButton(
                          child: const Text("CANCEL"),
                          onPressed:  () {
                            Navigator.pop(context);
                            addMedicineText = '';
                          },
                        ),
                        TextButton(
                          child: const Text("SAVE"),
                          onPressed:  () {
                            setState(() {
                              if (addMedicineText.isNotEmpty) {
                                if (medicineList.contains(addMedicineText)) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('That medicine already exists.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('OK'),
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
