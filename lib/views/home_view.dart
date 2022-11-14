import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:tyd/views/components/bottom_nav_bar.dart';

import '../day_data.dart';
import '../helpers/update_stats.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  var appBox = Hive.box('app_box');
  var dateBox = Hive.box('date_box');

  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  final DateFormat monthDayFormatter = DateFormat('MMM d');
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
      return AppLocalizations.of(context)!.anyDayNow;
    } else {
      // var dayText = daysUntilPeriod == 1 ? 'day' : 'days';
      // return '~$daysUntilPeriod $dayText until your next period';
      return AppLocalizations.of(context)!.nDaysUntilPeriod(daysUntilPeriod);
    }
  }

  String getCycleText() {
    var averageCycle = appBox.get('averageCycle');
    // var dayText = averageCycle == 1 ? 'day' : 'days';
    // return '$averageCycle $dayText';
    return AppLocalizations.of(context)!.nDays(averageCycle);
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.day,
                  style: const TextStyle(
                    fontSize: 20.0,
                  ),
                ),
                Text(
                  daysSinceStart().toString(),
                  // Change color to red if on period
                  style: TextStyle(
                    fontSize: 120.0,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                if (appBox.get('averageCycle') != null &&
                    (dateBox.get(formatter.format(currDate)) == null ||
                        !dateBox.get(formatter.format(currDate)).period)) ...[
                  Text(
                    getNextPeriodText(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                ],
                if (appBox.get('lastPeriod') != null ||
                    appBox.get('averageCycle') != null ||
                    currDayData.period) ...[
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Column(
                      children: [
                        if (currDayData.period) ...[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.periodStarted,
                                style: const TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                // TODO Localization
                                appBox.get('latestStartDate') != null
                                    ? monthDayFormatter
                                        .format(appBox.get('latestStartDate'))
                                    : 'Calculating...',
                                style: const TextStyle(
                                  fontSize: 15.0,
                                ),
                              ),
                            ],
                          ),
                          if (appBox.get('averageCycle') != null) ...[
                            const SizedBox(
                              height: 10.0,
                            ),
                          ],
                        ] else ...[
                          if (appBox.get('lastPeriod') != null) ...[
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${AppLocalizations.of(context)!.lastPeriod}: ',
                                  style: const TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  // TODO Localization
                                  appBox.get('lastPeriod'),
                                  style: const TextStyle(
                                    fontSize: 15.0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (appBox.get('averageCycle') != null) ...[
                            const SizedBox(
                              height: 10.0,
                            ),
                          ],
                        ],
                        if (appBox.get('averageCycle') != null) ...[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.yourAverageCycle,
                                style: const TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                getCycleText(),
                                style: const TextStyle(
                                  fontSize: 15.0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(
                  height: 10.0,
                ),
                Table(
                  defaultColumnWidth: const FixedColumnWidth(70),
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    if (!currDayData.pms) ...[
                      TableRow(
                        children: [
                          AutoSizeText(
                            AppLocalizations.of(context)!.period,
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 20.0,
                            ),
                          ),
                          Switch(
                            activeColor: Theme.of(context).primaryColor,
                            value: currDayData.period,
                            onChanged: (bool value) {
                              setState(() {
                                currDayData.period = value;
                              });
                              updateDayData();
                              updateStats();
                              if (value) {
                                Navigator.pushReplacementNamed(
                                    context, 'historyView');
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                    if (!currDayData.period) ...[
                      TableRow(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.pms,
                            style: const TextStyle(
                              fontSize: 20.0,
                            ),
                          ),
                          Switch(
                            activeColor: Theme.of(context).primaryColor,
                            value: currDayData.pms,
                            onChanged: (bool value) {
                              setState(() {
                                currDayData.pms = value;
                              });
                              updateDayData();
                              if (value) {
                                Navigator.pushReplacementNamed(
                                    context, 'historyView');
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                const SizedBox(
                  height: 50.0,
                ), // To push everything up a little.
              ],
            ),
          ),
        ),
        bottomNavigationBar: bottomNavBar(context, 0),
      ),
    );
  }
}
