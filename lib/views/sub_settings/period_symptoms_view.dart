import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class PeriodSymptomsView extends StatefulWidget {
  const PeriodSymptomsView({Key? key}) : super(key: key);

  @override
  State<PeriodSymptomsView> createState() => _PeriodSymptomsViewState();
}

class _PeriodSymptomsViewState extends State<PeriodSymptomsView> {
  var appBox = Hive.box('app_box');
  var addSymptomText = '';
  var symptomList = [];

  void saveSymptoms() {
    appBox.put('periodSymptoms', symptomList);
  }

  void emptySnack() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    var snackBar = const SnackBar(
      content: Text('Symptom cannot be blank.'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void initState() {
    super.initState();
    symptomList = appBox.get('periodSymptoms').toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Period Symptoms',
        ),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            for (var i = 0; i < symptomList.length; i++) ...[
              ListTile(
                title: Text(
                  symptomList[i],
                  style: const TextStyle(
                    fontSize: 25.0,
                  ),
                ),
                trailing: const Icon(Icons.edit),
                onTap: () {
                  // currSymptomName necessary to prevent "out of range" error
                  var currSymptomName = symptomList[i];
                  addSymptomText = currSymptomName;
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Edit Symptom'),
                        content: TextFormField(
                          initialValue: currSymptomName,
                          textCapitalization: TextCapitalization.words,
                          onChanged: (value) {
                            addSymptomText = value;
                          },
                        ),
                        actionsAlignment: MainAxisAlignment.spaceEvenly,
                        actions: [
                          TextButton(
                            child: const Text("CANCEL"),
                            onPressed:  () {
                              Navigator.pop(context);
                              addSymptomText = '';
                            },
                          ),
                          TextButton(
                            child: const Text("DELETE"),
                            onPressed:  () {
                              setState(() {
                                Navigator.pop(context);
                                symptomList.removeAt(i);
                                saveSymptoms();
                              });
                              addSymptomText = '';
                            },
                          ),
                          TextButton(
                            child: const Text("SAVE"),
                            onPressed:  () {
                              setState(() {
                                if (addSymptomText.isNotEmpty) {
                                  if (symptomList[i] != addSymptomText && symptomList.contains(addSymptomText)) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('That symptom already exists.'),
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
                                    symptomList[i] = addSymptomText;
                                    Navigator.pop(context);
                                    saveSymptoms();
                                  }
                                } else {
                                  emptySnack();
                                }
                              });
                              addSymptomText = '';
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
                      title: const Text('Add New Symptom'),
                      content: TextField(
                        textCapitalization: TextCapitalization.words,
                        onChanged: (value) {
                          addSymptomText = value;
                        },
                      ),
                      actionsAlignment: MainAxisAlignment.spaceEvenly,
                      actions: [
                        TextButton(
                          child: const Text("CANCEL"),
                          onPressed:  () {
                            Navigator.pop(context);
                            addSymptomText = '';
                          },
                        ),
                        TextButton(
                          child: const Text("SAVE"),
                          onPressed:  () {
                            setState(() {
                              if (addSymptomText.isNotEmpty) {
                                if (symptomList.contains(addSymptomText)) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('That symptom already exists.'),
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
                                  symptomList.add(addSymptomText);
                                  saveSymptoms();
                                  Navigator.pop(context);
                                }
                              } else {
                                emptySnack();
                              }
                            });
                            addSymptomText = '';
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
