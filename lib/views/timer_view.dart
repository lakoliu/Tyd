import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:swatch_generator/swatch_generator.dart';
import 'package:tyd/helpers/stopwatch_helper.dart';

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
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  final StopwatchHelper stopwatchHelper = StopwatchHelper();
  final _stopWatchTimer = StopwatchHelper().stopWatchTimer;
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
      stopwatchHelper.startTime = startingTime;
      var timeDifference = DateTime.now().difference(startingTime).inMinutes;
      _stopWatchTimer.setPresetMinuteTime(timeDifference);

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
      NotificationService().cancelPendingNotifications();
      setState(() {
        historyList.add(TimerData(stopwatchHelper.typeSelected, stopwatchHelper.startTime, stopTime, stopwatchHelper.sizeSelected));
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
    var notifyDateTime = stopwatchHelper.startTime.add(Duration(minutes: timerMinutes.toInt()));

    if (DateTime.now().isBefore(notifyDateTime)) {
      var notifyTime = timeFormatter.format(notifyDateTime);
      SnackBar? snackBar;
      switch (stopwatchHelper.typeSelected) {
        case 'Tampon':
          {
            snackBar = SnackBar(
              content: Text(
                AppLocalizations.of(context)!.changeTampon(notifyTime),
              ),
            );
          }
          break;
        case 'Pad':
          {
            snackBar = SnackBar(
              content: Text(
                AppLocalizations.of(context)!.changePad(notifyTime),
              ),
            );
          }
          break;
        case 'Cup':
          {
            snackBar = SnackBar(
              content: Text(
                AppLocalizations.of(context)!.emptyCup(notifyTime),
              ),
            );
          }
          break;
        case 'Underwear':
          {
            snackBar = SnackBar(
              content: Text(
                AppLocalizations.of(context)!.changeUnderwear(notifyTime),
              ),
            );
          }
          break;
      }
      if (snackBar != null) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }

      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()?.requestPermission();

      NotificationService().showTimedSanitaryChangeReminder(stopwatchHelper.typeSelected, notifyDateTime);
    }
  }

  void showCustomTimePicker(BuildContext context, String startOrStop) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      confirmText: startOrStop == 'START' ? AppLocalizations.of(context)!.startUpper : AppLocalizations.of(context)!.stopUpper,
      helpText: startOrStop == 'START' ? AppLocalizations.of(context)!.selectStart : AppLocalizations.of(context)!.selectStop,
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
      confirmText: AppLocalizations.of(context)!.saveUpper,
      helpText: startOrStop == 'START' ? AppLocalizations.of(context)!.selectStart : AppLocalizations.of(context)!.selectStop,
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
        title: Text(AppLocalizations.of(context)!.editEntry),
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
                    Text(AppLocalizations.of(context)!.type),
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
                            if (value != AppLocalizations.of(context)!.tampon) {
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
                    Text(AppLocalizations.of(context)!.size),
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
                      onChanged: historyList[i].type != 'Tampon' && historyList[i].type != AppLocalizations.of(context)!.tampon
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
                    Text(AppLocalizations.of(context)!.start),
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
                    Text(AppLocalizations.of(context)!.stop),
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
                    title: Text(AppLocalizations.of(context)!.deleteUpper),
                    content: Text(AppLocalizations.of(context)!.deleteEntry),
                    actions: [
                      TextButton(
                        child: Text(AppLocalizations.of(context)!.cancelUpper),
                        onPressed:  () {
                          Navigator.pop(context);
                        },
                      ),
                      TextButton(
                        child: Text(AppLocalizations.of(context)!.deleteUpper),
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
            child: Text(AppLocalizations.of(context)!.deleteUpper),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.closeUpper),
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
            mainAxisAlignment: historyList.isEmpty ? MainAxisAlignment.center : MainAxisAlignment.start,
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
              Wrap(
                alignment: WrapAlignment.spaceAround,
                direction: Axis.horizontal,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Radio(
                        activeColor: Theme.of(context).primaryColor,
                        groupValue: stopwatchHelper.radioSelected,
                        value: 1,
                        onChanged: _stopWatchTimer.isRunning
                            ? null
                            : (int? value) {
                          setState(() {
                            stopwatchHelper.radioSelected = value!;
                            stopwatchHelper.typeSelected = 'Tampon';
                            timerMinutes = appBox.get('sanitaryTypes')['Tampon'] * 60;
                          });
                        },
                      ),
                      Text(AppLocalizations.of(context)!.tampon),
                    ],
                  ),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Radio(
                        activeColor: Theme.of(context).primaryColor,
                        groupValue: stopwatchHelper.radioSelected,
                        value: 2,
                        onChanged: _stopWatchTimer.isRunning
                            ? null
                            : (int? value) {
                          setState(() {
                            stopwatchHelper.radioSelected = value!;
                            stopwatchHelper.typeSelected = 'Pad';
                            stopwatchHelper.sizeSelected = '-';
                            timerMinutes = appBox.get('sanitaryTypes')['Pad'] * 60;
                          });
                        },
                      ),
                      Text(AppLocalizations.of(context)!.pad),
                    ],
                  ),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Radio(
                        activeColor: Theme.of(context).primaryColor,
                        groupValue: stopwatchHelper.radioSelected,
                        value: 3,
                        onChanged: _stopWatchTimer.isRunning
                            ? null
                            : (int? value) {
                          setState(() {
                            stopwatchHelper.radioSelected = value!;
                            stopwatchHelper.typeSelected = 'Cup';
                            stopwatchHelper.sizeSelected = '-';
                            timerMinutes = appBox.get('sanitaryTypes')['Cup'] * 60;
                          });
                        },
                      ),
                      Text(AppLocalizations.of(context)!.cup),
                    ],
                  ),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Radio(
                        activeColor: Theme.of(context).primaryColor,
                        groupValue: stopwatchHelper.radioSelected,
                        value: 4,
                        onChanged: _stopWatchTimer.isRunning
                            ? null
                            : (int? value) {
                          setState(() {
                            stopwatchHelper.radioSelected = value!;
                            stopwatchHelper.typeSelected = 'Underwear';
                            stopwatchHelper.sizeSelected = '-';
                            timerMinutes = appBox.get('sanitaryTypes')['Underwear'] * 60;
                          });
                        },
                      ),
                      Text(AppLocalizations.of(context)!.underwear)
                    ],
                  ),
                ],
              ),
              // const Text('Test'),
              if (stopwatchHelper.radioSelected == 1) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppLocalizations.of(context)!.size),
                    const SizedBox(width: 15.0,),
                    DropdownButton(
                      value: stopwatchHelper.sizeSelected,
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
                            stopwatchHelper.sizeSelected = value;
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
                  child: Text(AppLocalizations.of(context)!.justChanged),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor),
                  onPressed: () => showCustomTimePicker(context, 'STOP'),
                  child: Text(AppLocalizations.of(context)!.stop),
                ),
              ] else ...[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor),
                  onPressed: () => showCustomTimePicker(context, 'START'),
                  child: Text(AppLocalizations.of(context)!.start),
                ),
              ],
              const SizedBox(
                height: 20.0,
              ),
              if (historyList.isNotEmpty) ...[
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
                        TableRow(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.type,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              AppLocalizations.of(context)!.size,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              AppLocalizations.of(context)!.start,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              AppLocalizations.of(context)!.stop,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              AppLocalizations.of(context)!.edit,
                              style: const TextStyle(
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
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: bottomNavBar(context, 2),
    );
  }
}
