import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:swatch_generator/swatch_generator.dart';

import '../day_data.dart';
import '../timer_data.dart';
import '../views/components/bottom_nav_bar.dart';

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
  late DateTime startTime;
  late DateTime stopTime;
  var timerMinutes = 4.0 * 60.0;


  void startTimer(DateTime startingTime) {
    if (!_stopWatchTimer.isRunning) {
      startTime = startingTime;
      var timeDifference = DateTime.now().difference(startingTime).inMinutes;
      _stopWatchTimer.setPresetMinuteTime(timeDifference);
      setState(() {
        _stopWatchTimer.onStartTimer();
      });
    }
  }

  void updateDayData() {
    dateBox.put(currDate, currDayData);
  }

  void stopTimer(DateTime stoppingTime) {
    if (_stopWatchTimer.isRunning) {
      setState(() {
        _stopWatchTimer.onStopTimer();
      });
      _stopWatchTimer.clearPresetTime();
      _stopWatchTimer.onResetTimer();
      stopTime = stoppingTime;
      setState(() {
        currDayData.timerData.add(TimerData(typeSelected, startTime, stopTime, '-'));
      });
      updateDayData();
    }
  }
  
  DateTime toDateTime(TimeOfDay timeOfDay) {
    var now = DateTime.now();
    return DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
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
                  Hive.box('app_box').get('accentColor') ?? Colors.pink[300]
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (startOrStop == 'START') {
      if (selectedTime != null) {
        startTimer(toDateTime(selectedTime));
      }
    } else {
      if (selectedTime != null) {
        stopTimer(toDateTime(selectedTime));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    timerMinutes = appBox.get('tamponTimer');
    if (dateBox.get(currDate) != null) {
      setState(() {
        currDayData = dateBox.get(currDate);
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
              const SizedBox(height: 50.0,),
              StreamBuilder<int>(
                stream: _stopWatchTimer.rawTime,
                initialData: _stopWatchTimer.rawTime.value,
                builder: (context, snap) {
                  final value = snap.data!;
                  final displayTime = StopWatchTimer.getDisplayTime(
                      value, milliSecond: false);
                  // Save for future indicator: var progress = 100 - (value / (timerMinutes * 60 * 1000) * 100);
                  return Text(
                    displayTime,
                    style: TextStyle(
                      fontSize: 75.0,
                      color: Theme.of(context).primaryColor,
                    ),
                  );
                }
              ),
              const SizedBox(height: 10.0,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Radio(
                    activeColor: Theme.of(context).primaryColor,
                    groupValue: _radioSelected,
                    value: 1,
                    onChanged: _stopWatchTimer.isRunning ? null : (int? value) {
                      setState(() {
                        _radioSelected = value!;
                        typeSelected = 'Tampon';
                        timerMinutes = appBox.get('tamponTimer');
                      });
                    },
                  ),
                  const Text('Tampon'),
                  Radio(
                    activeColor: Theme.of(context).primaryColor,
                    groupValue: _radioSelected,
                    value: 2,
                    onChanged: _stopWatchTimer.isRunning ? null : (int? value) {
                      setState(() {
                        _radioSelected = value!;
                        typeSelected = 'Pad';
                        timerMinutes = appBox.get('padTimer');
                      });
                    },
                  ),
                  const Text('Pad'),
                  Radio(
                    activeColor: Theme.of(context).primaryColor,
                    groupValue: _radioSelected,
                    value: 3,
                    onChanged: _stopWatchTimer.isRunning ? null : (int? value) {
                      setState(() {
                        _radioSelected = value!;
                        typeSelected = 'Cup';
                        timerMinutes = appBox.get('cupTimer');
                      });
                    },
                  ),
                  const Text('Cup'),
                ],
              ),
              const SizedBox(height: 20.0,),
              if (_stopWatchTimer.isRunning) ...[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor
                  ),
                  onPressed: () {
                    stopTimer(DateTime.now());
                    startTimer(DateTime.now());
                  },
                  child: const Text('Just Changed'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor
                  ),
                  onPressed: () => showCustomTimePicker(context, 'STOP'),
                  child: const Text('Stop'),
                ),
              ] else ...[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor
                  ),
                  onPressed: () => showCustomTimePicker(context, 'START'),
                  child: const Text('Start'),
                ),
              ],
              const SizedBox(height: 20.0,),
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
                      for (var historyItem in currDayData.timerData) ...[
                        // rowSpacer,
                        TableRow(
                          children: [
                            Text(
                              historyItem.type,
                            ),
                            Text(
                              historyItem.size,
                            ),
                            Text(
                              timeFormatter.format(historyItem.startTime),
                            ),
                            Text(
                              timeFormatter.format(historyItem.stopTime),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.edit, size: 20.0,),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  // child: Column(
                  //   children: getAllRows(),
                  // ),
                )
              ),
              // TODO Show a toast notification that you will be notified in X hours to change your X
            ],
          ),
        ),
      ),
      bottomNavigationBar: bottomNavBar(context, 2),
    );
  }
}

