import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:tyd/day_data.dart';

class TamponSizeView extends StatefulWidget {
  const TamponSizeView({Key? key}) : super(key: key);

  @override
  State<TamponSizeView> createState() => _TamponSizeViewState();
}

class _TamponSizeViewState extends State<TamponSizeView> {
  var appBox = Hive.box('app_box');
  var dateBox = Hive.box('date_box');
  final String currDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  var addSizeText = '';
  var sizeList = [];

  void saveSizes() {
    appBox.put('tamponSizes', sizeList);
  }

  void emptySnack() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    var snackBar = const SnackBar(
      content: Text('Size cannot be blank.'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  bool sizeUsedToday(String selectedSize) {
    if (dateBox.get(currDate) != null) {
      DayData currDayData = dateBox.get(currDate);
      var historyList = currDayData.timerData;
      for (var listItem in historyList) {
        if (listItem.size == selectedSize) {
          return true;
        }
      }
    }

    return false;
  }

  @override
  void initState() {
    super.initState();
    sizeList = appBox.get('tamponSizes').toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Tampon Sizes',
        ),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            for (var i = 1; i < sizeList.length; i++) ...[
              ListTile(
                title: Text(
                  sizeList[i],
                  style: const TextStyle(
                    fontSize: 25.0,
                  ),
                ),
                trailing: const Icon(Icons.edit),
                onTap: () {
                  // currSizeName necessary to prevent "out of range" error
                  var currSizeName = sizeList[i];
                  addSizeText = currSizeName;
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Edit Size'),
                        content: TextFormField(
                          enabled: !sizeUsedToday(sizeList[i]),
                          initialValue: currSizeName,
                          textCapitalization: TextCapitalization.words,
                          onChanged: (value) {
                            addSizeText = value;
                          },
                        ),
                        actionsAlignment: MainAxisAlignment.spaceEvenly,
                        actions: [
                          TextButton(
                            child: const Text("CANCEL"),
                            onPressed:  () {
                              Navigator.pop(context);
                              addSizeText = '';
                            },
                          ),
                          TextButton(
                            child: const Text("DELETE"),
                            onPressed:  () {
                              setState(() {
                                if (!sizeUsedToday(sizeList[i])) {
                                  Navigator.pop(context);
                                  sizeList.removeAt(i);
                                  saveSizes();
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Can\'t Delete'),
                                        content: const Text('This size is being used in today\'s tampon timer.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              });
                              addSizeText = '';
                            },
                          ),
                          TextButton(
                            child: const Text("SAVE"),
                            onPressed:  () {
                              setState(() {
                                if (addSizeText.isNotEmpty) {
                                  if (sizeList[i] != addSizeText && sizeList.contains(addSizeText)) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('That size already exists.'),
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
                                    sizeList[i] = addSizeText;
                                    Navigator.pop(context);
                                    saveSizes();
                                  }
                                } else {
                                  emptySnack();
                                }
                              });
                              addSizeText = '';
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
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Add New Size'),
                      content: TextField(
                        textCapitalization: TextCapitalization.words,
                        onChanged: (value) {
                          addSizeText = value;
                        },
                      ),
                      actionsAlignment: MainAxisAlignment.spaceEvenly,
                      actions: [
                        TextButton(
                          child: const Text("CANCEL"),
                          onPressed:  () {
                            Navigator.pop(context);
                            addSizeText = '';
                          },
                        ),
                        TextButton(
                          child: const Text("SAVE"),
                          onPressed:  () {
                            setState(() {
                              if (addSizeText.isNotEmpty) {
                                if (sizeList.contains(addSizeText)) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('That size already exists.'),
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
                                  sizeList.add(addSizeText);
                                  saveSizes();
                                  Navigator.pop(context);
                                }
                              } else {
                                emptySnack();
                              }
                            });
                            addSizeText = '';
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
