import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:swatch_generator/swatch_generator.dart';

import '../day_data.dart';
import '../helpers/notification_service.dart';
import '../timer_data.dart';
import 'components/bottom_nav_bar.dart';

class TimerView extends StatefulWidget {
  const TimerView({Key? key}) : super(key: key);

  @override
  State<TimerView> createState() => _TimerViewState();
}

class _TimerViewState extends State<TimerView> {
  var appBox = Hive.box('app_box');
  var dateBox = Hive.box('date_box');

  final _stopWatchTimer = StopWatchTimer();
  final DateFormat timeFormatter = DateFormat.jm();
  final String currDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final TableRow rowSpacer = const TableRow(children: [
    SizedBox(
      height: 15,
    ),
    SizedBox(
      height: 15,
    ),
    SizedBox(
      height: 15,
    ),
    SizedBox(
      height: 15,
    ),
    SizedBox(
      height: 15,
    ),
  ]);

  var currDayData = DayData();
  var _radioSelected = 1;
  var typeSelected = 'Tampon';
  var sizeSelected = '-';
  late DateTime startTime;
  late DateTime stopTime;
  var timerMinutes = 4.0 * 60.0;
  List<TimerData> historyList = [];
  var dropDownDisabled = false;

  void saveDayData() {
    dateBox.put(currDate, currDayData);
  }

  void saveHistoryList() {
    currDayData.timerData = historyList;
    saveDayData();
  }

  void startTimer(DateTime startingTime) {
    if (!_stopWatchTimer.isRunning) {
      startTime = startingTime;
      var timeDifference = DateTime.now().difference(startingTime).inMinutes;
      _stopWatchTimer.setPresetMinuteTime(timeDifference);
      // TODO NotificationService().showTimedSanitaryChangeReminder(typeSelected, startTime.add(const Duration(minutes: 240)));
      setState(() {
        _stopWatchTimer.onStartTimer();
      });
      notificationTimerSnack();
    }
  }

  void stopTimer(DateTime stoppingTime) {
    if (_stopWatchTimer.isRunning) {
      setState(() {
        _stopWatchTimer.onStopTimer();
      });
      _stopWatchTimer.clearPresetTime();
      _stopWatchTimer.onResetTimer();
      stopTime = stoppingTime;
      // TODO NotificationService().cancelPendingNotifications();
      setState(() {
        historyList.add(TimerData(typeSelected, startTime, stopTime, sizeSelected));
      });
      saveHistoryList();
    }
  }

  DateTime toDateTime(TimeOfDay timeOfDay) {
    var now = DateTime.now();
    return DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
  }

  void notificationTimerSnack() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    var verb = typeSelected == 'Cup' ? 'empty' : 'change';
    var notifyDateTime = startTime.add(Duration(minutes: timerMinutes.toInt()));

    if (DateTime.now().isBefore(notifyDateTime)) {
      var notifyTime = timeFormatter.format(notifyDateTime);
      var snackBar = SnackBar(
        content: Text(
            'You will be notified at $notifyTime to $verb your ${typeSelected.toLowerCase()}.'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void showCustomTimePicker(BuildContext context, String startOrStop) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      confirmText: startOrStop,
      helpText: 'SELECT $startOrStop TIME',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: SwatchGenerator.fromColor(
                  Hive.box('app_box').get('accentColor') ?? Colors.pink[300]),
            ),
          ),
          child: child!,
        );
      },
    );
    if (selectedTime != null) {
      if (startOrStop == 'START') {
          startTimer(toDateTime(selectedTime));
      } else {
          stopTimer(toDateTime(selectedTime));
      }
    }
  }

  void showTimeEditPicker(BuildContext context, String startOrStop, int i, void Function(void Function()) newState) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialEntryMode: TimePickerEntryMode.input,
      initialTime: TimeOfDay.fromDateTime(startOrStop == 'START' ? historyList[i].startTime : historyList[i].stopTime),
      confirmText: 'SAVE',
      helpText: 'SELECT $startOrStop TIME',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: SwatchGenerator.fromColor(
                  Hive.box('app_box').get('accentColor') ?? Colors.pink[300]),
            ),
          ),
          child: child!,
        );
      },
    );
    if (selectedTime != null) {
      if (startOrStop == 'START') {
        newState(() {
          setState(() {
            historyList[i].startTime = toDateTime(selectedTime);
          });
        });

      } else {
        newState(() {
          setState(() {
            historyList[i].stopTime = toDateTime(selectedTime);
          });
        });
      }
    }
  }

  List<String> getSanitaryList() {
    List<String> sanitaryList = [];
    for (var sanitaryItem in appBox.get('sanitaryTypes').keys) {
      sanitaryList.add(sanitaryItem.toString());
    }
    return sanitaryList;
  }

  Widget showHistoryEditDialog(BuildContext context, int i) {
    return StatefulBuilder(builder: (context, newSetState) {
      return AlertDialog(
        title: const Text('Edit Entry'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 10.0,
            ),
            Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: const {
                0: FractionColumnWidth(.5),
                1: FractionColumnWidth(.5),
              },
              children: [
                TableRow(
                  children: [
                    const Text('Type'),
                    DropdownButton(
                      isExpanded: true,
                      value: historyList[i].type,
                      items: getSanitaryList()
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        newSetState(() {
                          setState(() {
                            if (value != null) {
                              historyList[i].type = value;
                            }
                            if (value != 'Tampon') {
                              historyList[i].size = '-';
                            }
                            saveHistoryList();
                          });
                        });
                      },
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    const Text('Size'),
                    DropdownButton(
                      isExpanded: true,
                      value: historyList[i].size,
                      items: appBox.get('tamponSizes')
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: historyList[i].type != 'Tampon'
                          ? null
                          : (String? value) {
                              newSetState(() {
                                setState(() {
                                  if (value != null) {
                                    historyList[i].size = value;
                                    saveHistoryList();
                                  }
                                });
                              });
                            },
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    const Text('Start'),
                    ElevatedButton(
                      onPressed: () {
                        showTimeEditPicker(context, 'START', i, newSetState);
                      },
                      child:
                          Text(timeFormatter.format(historyList[i].startTime)),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    const Text('Stop'),
                    ElevatedButton(
                      onPressed: () {
                        showTimeEditPicker(context, 'STOP', i, newSetState);
                      },
                      child:
                          Text(timeFormatter.format(historyList[i].stopTime)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("DELETE"),
                    content: Text("Delete this entry?"),
                    actions: [
                      TextButton(
                        child: Text("CANCEL"),
                        onPressed:  () {
                          Navigator.pop(context);
                        },
                      ),
                      TextButton(
                        child: Text("DELETE"),
                        onPressed:  () {
                          Navigator.pop(context);
                          setState(() {
                            historyList.removeAt(i);
                            saveHistoryList();
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: const Text('DELETE'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('CLOSE'),
          ),
        ],
      );
    });
  }

  @override
  void initState() {
    super.initState();
    timerMinutes = appBox.get('sanitaryTypes')['Tampon'] * 60;
    if (dateBox.get(currDate) != null) {
      setState(() {
        currDayData = dateBox.get(currDate);
        historyList = currDayData.timerData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20.0,
              ),
              StreamBuilder<int>(
                  stream: _stopWatchTimer.rawTime,
                  initialData: _stopWatchTimer.rawTime.value,
                  builder: (context, snap) {
                    final value = snap.data!;
                    final displayTime = StopWatchTimer.getDisplayTime(value,
                        milliSecond: false);
                    // Save for future indicator: var progress = 100 - (value / (timerMinutes * 60 * 1000) * 100);
                    return Text(
                      displayTime,
                      style: TextStyle(
                        fontSize: 75.0,
                        color: Theme.of(context).primaryColor,
                      ),
                    );
                  }),
              const SizedBox(
                height: 10.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Radio(
                    activeColor: Theme.of(context).primaryColor,
                    groupValue: _radioSelected,
                    value: 1,
                    onChanged: _stopWatchTimer.isRunning
                        ? null
                        : (int? value) {
                            setState(() {
                              _radioSelected = value!;
                              typeSelected = 'Tampon';
                              timerMinutes = appBox.get('sanitaryTypes')['Tampon'] * 60;
                            });
                          },
                  ),
                  const Text('Tampon'),
                  Radio(
                    activeColor: Theme.of(context).primaryColor,
                    groupValue: _radioSelected,
                    value: 2,
                    onChanged: _stopWatchTimer.isRunning
                        ? null
                        : (int? value) {
                            setState(() {
                              _radioSelected = value!;
                              typeSelected = 'Pad';
                              sizeSelected = '-';
                              timerMinutes = appBox.get('sanitaryTypes')['Pad'] * 60;
                            });
                          },
                  ),
                  const Text('Pad'),
                  Radio(
                    activeColor: Theme.of(context).primaryColor,
                    groupValue: _radioSelected,
                    value: 3,
                    onChanged: _stopWatchTimer.isRunning
                        ? null
                        : (int? value) {
                            setState(() {
                              _radioSelected = value!;
                              typeSelected = 'Cup';
                              sizeSelected = '-';
                              timerMinutes = appBox.get('sanitaryTypes')['Cup'] * 60;
                            });
                          },
                  ),
                  const Text('Cup'),
                  Radio(
                    activeColor: Theme.of(context).primaryColor,
                    groupValue: _radioSelected,
                    value: 4,
                    onChanged: _stopWatchTimer.isRunning
                        ? null
                        : (int? value) {
                      setState(() {
                        _radioSelected = value!;
                        typeSelected = 'Underwear';
                        sizeSelected = '-';
                        timerMinutes = appBox.get('sanitaryTypes')['Underwear'] * 60;
                      });
                    },
                  ),
                  const Text('Underwear'),
                ],
              ),
              // const Text('Test'),
              if (_radioSelected == 1) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Size'),
                    const SizedBox(width: 15.0,),
                    DropdownButton(
                      value: sizeSelected,
                      items: appBox.get('tamponSizes')
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: _stopWatchTimer.isRunning ? null : (String? value) {
                        if (value != null) {
                          setState(() {
                            sizeSelected = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10.0,
                ),
              ] else ...[
                const SizedBox(
                  height: 20.0,
                ),
              ],
              if (_stopWatchTimer.isRunning) ...[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor),
                  onPressed: () {
                    stopTimer(DateTime.now());
                    startTimer(DateTime.now());
                  },
                  child: const Text('Just Changed'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor),
                  onPressed: () => showCustomTimePicker(context, 'STOP'),
                  child: const Text('Stop'),
                ),
              ] else ...[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor),
                  onPressed: () => showCustomTimePicker(context, 'START'),
                  child: const Text('Start'),
                ),
              ],
              const SizedBox(
                height: 20.0,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    columnWidths: const {
                      0: FractionColumnWidth(.2),
                      1: FractionColumnWidth(.15),
                      2: FractionColumnWidth(.25),
                      3: FractionColumnWidth(.25),
                      4: FractionColumnWidth(.1)
                    },
                    children: [
                      const TableRow(
                        children: [
                          Text(
                            'Type',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Size',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Start',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Stop',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Edit',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      rowSpacer,
                      for (var i = 0; i < historyList.length; i++) ...[
                        // rowSpacer,
                        TableRow(
                          children: [
                            Text(
                              historyList[i].type,
                            ),
                            Text(
                              historyList[i].size,
                            ),
                            Text(
                              timeFormatter.format(historyList[i].startTime),
                            ),
                            Text(
                              timeFormatter.format(historyList[i].stopTime),
                            ),
                            IconButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return showHistoryEditDialog(context, i);
                                    });
                              },
                              icon: const Icon(
                                Icons.edit,
                                size: 20.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  // child: Column(
                  //   children: getAllRows(),
                  // ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: bottomNavBar(context, 2),
    );
  }
}
