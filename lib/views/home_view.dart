import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vula/views/components/bottom_nav_bar.dart';
import 'package:vula/views/settings_view.dart';
import 'package:vula/views/stats_view.dart';
import '../views/history_view.dart';
import 'package:hive/hive.dart';
import '../helpers/update_stats.dart';
import '../day_data.dart';


class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  var appBox = Hive.box('app_box');
  var dateBox = Hive.box('date_box');

  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  var currDate = DateTime.now();
  DayData currDayData = DayData();

  var avgCycleDays = 28;

  int daysSinceStart() {
    var startDate = appBox.get('latestStartDate');
    if (startDate != null) {
      var dayDifference = currDate.difference(startDate).inDays + 1;
      return dayDifference;
    } else {
      return 0;
    }
  }

  String getNextPeriodText() {
    var averageCycle = appBox.get('averageCycle');
    var daysUntilPeriod = averageCycle - daysSinceStart();

    if (daysUntilPeriod < 1) {
      return 'You can expect your period any day now';
    } else {
      var dayText = daysUntilPeriod == 1 ? 'day' : 'days';
      return '~$daysUntilPeriod $dayText until your next period';
    }
  }

  String getCycleText() {
    var averageCycle = appBox.get('averageCycle');
    var dayText = averageCycle == 1 ? 'day' : 'days';
    return 'Your average cycle: $averageCycle $dayText';
  }

  void updateDayData() {
    dateBox.put(formatter.format(currDate), currDayData);
  }

  @override
  void initState() {
    super.initState();
    var savedDayData = dateBox.get(formatter.format(currDate));
    if (savedDayData != null) {
      currDayData = savedDayData;
    }
    updateStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'DAY',
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
              Text(
                daysSinceStart().toString(),
                // Change color to red if on period
                style: const TextStyle(
                  fontSize: 120.0,
                ),
              ),
              // TODO Don't show if currently on period
              if (appBox.get('averageCycle') != null && (dateBox.get(formatter.format(currDate)) == null || !dateBox.get(formatter.format(currDate)).period)) ...[
                Text(
                  getNextPeriodText(),
                  style: const TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
              ],
              if (appBox.get('lastPeriod') != null || appBox.get('averageCycle') != null) ...[
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Column(
                    children: [
                      if (appBox.get('lastPeriod') != null) ...[
                        Text(
                          'Last period: ${appBox.get('lastPeriod')}',
                          style: const TextStyle(
                            fontSize: 15.0,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      const SizedBox(
                        height: 10.0,
                      ),
                      if (appBox.get('averageCycle') != null) ...[
                        Text(
                          getCycleText(),
                          style: const TextStyle(
                            fontSize: 15.0,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(
                height: 10.0,
              ),
              // TODO if not PMS
              if (!currDayData.pms) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Period',
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                    Switch(
                      activeColor: appBox.get('accentColor') ?? Colors.pink[300],
                      value: currDayData.period,
                      onChanged: (bool value) {
                        setState(() {
                          currDayData.period = value;
                        });
                        updateDayData();
                        if (value) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HistoryView()
                            ),
                          );
                        } else {
                          updateStats();
                        }
                      },
                    ),
                  ],
                ),
              ],
              if (!currDayData.period && !currDayData.pms) ...[
                const SizedBox(height: 10.0,),
              ],
              if (!currDayData.period) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'PMS',
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                    Switch(
                      activeColor: appBox.get('accentColor') ?? Colors.pink[300],
                      value: currDayData.pms,
                      onChanged: (bool value) {
                        setState(() {
                          currDayData.pms = value;
                        });
                        updateDayData();
                        if (value) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HistoryView()),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
              const SizedBox(
                height: 50.0,
              ), // To push everything up a little. TODO Necessary?
            ],
          ),
        ),
      ),
      bottomNavigationBar: bottomNavBar(context, 0)
    );
  }
}
