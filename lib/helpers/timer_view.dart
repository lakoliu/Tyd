import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:swatch_generator/swatch_generator.dart';

import '../views/components/bottom_nav_bar.dart';

class TimerView extends StatefulWidget {
  const TimerView({Key? key}) : super(key: key);

  @override
  State<TimerView> createState() => _TimerViewState();
}

class _TimerViewState extends State<TimerView> {
  var appBox = Hive.box('app_box');
  final _stopWatchTimer = StopWatchTimer();
  var _radioSelected = 1;
  late DateTime startTime;
  late DateTime stopTime;

  // TODO Temporary (replace with saved values)
  var timerMinutes = 1;

  void startStop({DateTime? startingTime}) {
    if (_stopWatchTimer.isRunning) {
      setState(() {
        _stopWatchTimer.onStopTimer();
        _stopWatchTimer.onResetTimer();
      });
    } else {
      _stopWatchTimer.clearPresetTime();
      setState(() {
        _stopWatchTimer.onStartTimer();
      });
    }
  }

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

  void stopTimer(DateTime stoppingTime) {
    if (_stopWatchTimer.isRunning) {
      setState(() {
        _stopWatchTimer.onStopTimer();
      });
      _stopWatchTimer.clearPresetTime();
      _stopWatchTimer.onResetTimer();
      stopTime = stoppingTime;
    }
  }
  
  DateTime toDateTime(TimeOfDay timeOfDay) {
    var now = DateTime.now();
    return DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
  }

  void showCustomTimePicker(BuildContext context) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      confirmText: 'START',
      helpText: 'SELECT START TIME',
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
    if (selectedTime != null) {
      startTimer(toDateTime(selectedTime));
    }
  }


  @override
  void initState() {
    super.initState();
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
                    onChanged: (int? value) {
                      setState(() {
                        _radioSelected = value!;
                      });
                    },
                  ),
                  const Text('Tampon'),
                  Radio(
                    activeColor: Theme.of(context).primaryColor,
                    groupValue: _radioSelected,
                    value: 2,
                    onChanged: (int? value) {
                      setState(() {
                        _radioSelected = value!;
                      });
                    },
                  ),
                  const Text('Pad'),
                  Radio(
                    activeColor: Theme.of(context).primaryColor,
                    groupValue: _radioSelected,
                    value: 3,
                    onChanged: (int? value) {
                      setState(() {
                        _radioSelected = value!;
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
                  onPressed: () => stopTimer(DateTime.now()),
                  child: const Text('Stop'),
                ),
              ] else ...[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor
                  ),
                  onPressed: () => showCustomTimePicker(context),
                  child: const Text('Start'),
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