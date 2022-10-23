import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:vula/helpers/update_stats.dart';
import 'package:vula/views/components/bottom_nav_bar.dart';
import 'package:vula/views/home_view.dart';

import 'history_view.dart';

class StatsView extends StatefulWidget {
  const StatsView({Key? key}) : super(key: key);

  @override
  State<StatsView> createState() => _StatsViewState();
}

class _StatsViewState extends State<StatsView> {
  var appBox = Hive.box('app_box');

  var selectedPeriodDay = 1;

  Widget printUnknown() {
    return const Text(
      'unknown',
      style: TextStyle(
        fontSize: 20.0,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  String printWithDays(int value) {
    var dayString = value == 1 ? 'day' : 'days';
    return '$value $dayString';
  }

  @override
  void initState() {
    super.initState();
    updateSecondaryStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Statistics',
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    'Last period: ',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (appBox.get('lastPeriod') != null) ...[
                    Text(
                      '${appBox.get('lastPeriod')}',
                      style: const TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                  ] else ...[
                    printUnknown()
                  ],
                ],
              ),
              const SizedBox(height: 15.0,),
              Row(
                children: [
                  const Text(
                    'Average period: ',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (appBox.get('averagePeriod') != null) ...[
                    Text(
                      printWithDays(appBox.get('averagePeriod')),
                      style: const TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                  ] else ...[
                    printUnknown()
                  ],
                ],
              ),
              const SizedBox(height: 15.0,),
              Row(
                children: [
                  const Text(
                    'Average cycle: ',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (appBox.get('averageCycle') != null) ...[
                    Text(
                      printWithDays(appBox.get('averageCycle')),
                      style: const TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                  ] else ...[
                    printUnknown()
                  ],
                ],
              ),
              if (appBox.get('longestPeriod') != null) ...[
                Row(
                  children: [
                    const Text(
                      'Avg. bleeding on day',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10.0,),
                    DropdownButton(
                      value: selectedPeriodDay,
                      items: List<int>.generate(appBox.get('longestPeriod'), (k) => k + 1)
                          .map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString()),
                        );
                      }).toList(), // TODO one item for every day of longest period
                      onChanged: (int? value) {
                        if (value != null) {
                          setState(() {
                            selectedPeriodDay = value;
                          });
                        }
                      },
                    ),
                    const Text(
                      ':',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 7.0,),
                    if (appBox.get('averageBleedingByDay') != null) ...[
                      Text(
                        (appBox.get('averageBleedingByDay')[selectedPeriodDay] * 10).toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                    ] else ...[
                      printUnknown()
                    ],
                  ],
                ),
              ] else ...[
                const SizedBox(height: 15.0,),
              ],
              Row(
                children: [
                  const Text(
                    'Total period days: ',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (appBox.get('totalPeriodDays') != null) ...[
                    Text(
                      printWithDays(appBox.get('totalPeriodDays')),
                      style: const TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                  ] else ...[
                    printUnknown()
                  ],
                ],
              ),
              const SizedBox(height: 15.0,),
              Row(
                children: [
                  const Text(
                    'Total days tracked: ',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (appBox.get('totalDaysTracked') != null) ...[
                    Text(
                      printWithDays(appBox.get('totalDaysTracked')),
                      style: const TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                  ] else ...[
                    printUnknown()
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: bottomNavBar(context, 3)
    );
  }
}
