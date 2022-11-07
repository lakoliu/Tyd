import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';

class PmsSymptomsView extends StatefulWidget {
  const PmsSymptomsView({Key? key}) : super(key: key);

  @override
  State<PmsSymptomsView> createState() => _PmsSymptomsViewState();
}

class _PmsSymptomsViewState extends State<PmsSymptomsView> {
  var appBox = Hive.box('app_box');
  var addSymptomText = '';
  var symptomList = [];

  void saveSymptoms() {
    appBox.put('pmsSymptoms', symptomList);
  }

  void emptySnack() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    var snackBar = SnackBar(
      content: Text(AppLocalizations.of(context)!.symptomBlank),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void initState() {
    super.initState();
    symptomList = appBox.get('pmsSymptoms').toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            AppLocalizations.of(context)!.editPmsSymptoms,
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
                        title: Text(AppLocalizations.of(context)!.editSymptom),
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
                            child: Text(AppLocalizations.of(context)!.cancelUpper),
                            onPressed:  () {
                              Navigator.pop(context);
                              addSymptomText = '';
                            },
                          ),
                          TextButton(
                            child: Text(AppLocalizations.of(context)!.deleteUpper),
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
                            child: Text(AppLocalizations.of(context)!.saveUpper),
                            onPressed:  () {
                              setState(() {
                                if (addSymptomText.isNotEmpty) {
                                  if (symptomList[i] != addSymptomText && symptomList.contains(addSymptomText)) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(AppLocalizations.of(context)!.symptomExists),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: Text(AppLocalizations.of(context)!.okUpper),
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
                      title: Text(AppLocalizations.of(context)!.addSymptom),
                      content: TextField(
                        textCapitalization: TextCapitalization.words,
                        onChanged: (value) {
                          addSymptomText = value;
                        },
                      ),
                      actionsAlignment: MainAxisAlignment.spaceEvenly,
                      actions: [
                        TextButton(
                          child: Text(AppLocalizations.of(context)!.cancelUpper),
                          onPressed:  () {
                            Navigator.pop(context);
                            addSymptomText = '';
                          },
                        ),
                        TextButton(
                          child: Text(AppLocalizations.of(context)!.saveUpper),
                          onPressed:  () {
                            setState(() {
                              if (addSymptomText.isNotEmpty) {
                                if (symptomList.contains(addSymptomText)) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(AppLocalizations.of(context)!.symptomExists),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: Text(AppLocalizations.of(context)!.okUpper),
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
