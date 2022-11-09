import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:tyd/helpers/update_stats.dart';
import 'package:tyd/views/components/bottom_nav_bar.dart';


class StatsView extends StatefulWidget {
  const StatsView({Key? key}) : super(key: key);

  @override
  State<StatsView> createState() => _StatsViewState();
}

class _StatsViewState extends State<StatsView> {
  var appBox = Hive.box('app_box');

  var selectedPeriodDay = 1;

  Widget printUnknown() {
    return Text(
      AppLocalizations.of(context)!.notEnoughData,
      style: const TextStyle(
        fontSize: 20.0,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  TextSpan unknownTextSpan() {
    return TextSpan(
      text: AppLocalizations.of(context)!.notEnoughData,
      style: const TextStyle(
        fontSize: 20.0,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.normal,
      ),
    );
  }

  String printWithDays(int value) {
    return AppLocalizations.of(context)!.nDays(value);
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
        title: Text(
          AppLocalizations.of(context)!.statistics,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                  text: AppLocalizations.of(context)!.lastPeriod,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    if (appBox.get('lastPeriod') != null) ...[
                      TextSpan(
                        text: '${appBox.get('lastPeriod')}',
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ] else ...[
                      unknownTextSpan(),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 15.0,),
              RichText(
                text: TextSpan(
                  text: AppLocalizations.of(context)!.averagePeriod,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    if (appBox.get('averagePeriod') != null) ...[
                      TextSpan(
                        text: AppLocalizations.of(context)!.nDays(appBox.get('averagePeriod')),
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ] else ...[
                      unknownTextSpan(),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 15.0,),
              RichText(
                text: TextSpan(
                  text: AppLocalizations.of(context)!.averageCycle,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    if (appBox.get('averageCycle') != null) ...[
                      TextSpan(
                        text: AppLocalizations.of(context)!.nDays(appBox.get('averageCycle')),
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ] else ...[
                      unknownTextSpan(),
                    ],
                  ],
                ),
              ),
              if (appBox.get('longestPeriod') != null) ...[
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.averageBleeding,
                      style: const TextStyle(
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
                      }).toList(),
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
              ],
              const SizedBox(height: 15.0,),
              RichText(
                text: TextSpan(
                  text: AppLocalizations.of(context)!.averagePmsPerCycle,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    if (appBox.get('averagePmsPerCycle') != null) ...[
                      TextSpan(
                        text: AppLocalizations.of(context)!.nDays(appBox.get('averagePmsPerCycle')),
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ] else ...[
                      unknownTextSpan(),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 15.0,),
              RichText(
                text: TextSpan(
                  text: AppLocalizations.of(context)!.totalPeriodDays,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    if (appBox.get('totalPeriodDays') != null) ...[
                      TextSpan(
                        text: AppLocalizations.of(context)!.nDays(appBox.get('totalPeriodDays')),
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ] else ...[
                      unknownTextSpan(),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 15.0,),
              RichText(
                text: TextSpan(
                  text: AppLocalizations.of(context)!.totalPmsDays,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    if (appBox.get('totalPmsDays') != null) ...[
                      TextSpan(
                        text: AppLocalizations.of(context)!.nDays(appBox.get('totalPmsDays')),
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ] else ...[
                      unknownTextSpan(),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 15.0,),
              RichText(
                text: TextSpan(
                  text: AppLocalizations.of(context)!.totalDaysTracked,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    if (appBox.get('totalDaysTracked') != null) ...[
                      TextSpan(
                        text: AppLocalizations.of(context)!.nDays(appBox.get('totalDaysTracked')),
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ] else ...[
                      unknownTextSpan(),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: bottomNavBar(context, 3),
    );
  }
}
