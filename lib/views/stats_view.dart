import 'package:auto_size_text/auto_size_text.dart';
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

  AutoSizeText printNA() {
    return AutoSizeText(
      AppLocalizations.of(context)!.nA,
      maxLines: 1,
      style: TextStyle(
        fontSize: 80.0,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  String printWithDays(int value) {
    return AppLocalizations.of(context)!.nDays(value);
  }

  @override
  void initState() {
    super.initState();
    updateStats();
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 15.0,
                ),
                AutoSizeText(
                  AppLocalizations.of(context)!.lastPeriod,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                AutoSizeText(
                  appBox.get('lastPeriod') ?? AppLocalizations.of(context)!.nA,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 80.0,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(
                  height: 30.0,
                ),
                Container(
                  padding: const EdgeInsets.all(15.0),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AutoSizeText(
                        (appBox.get('averagePeriod') ??
                                AppLocalizations.of(context)!.nA)
                            .toString(),
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 80.0,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      AutoSizeText(
                        AppLocalizations.of(context)!.averagePeriod,
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30.0,
                ),
                AutoSizeText(
                  (appBox.get('averagePmsPerCycle') ??
                          AppLocalizations.of(context)!.nA)
                      .toString(),
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 80.0,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                AutoSizeText(
                  AppLocalizations.of(context)!.averagePmsPerCycle,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(
                  height: 30.0,
                ),
                if (appBox.get('longestPeriod') != null) ...[
                  Container(
                    padding: const EdgeInsets.all(15.0),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      // TODO add a gradient
                      borderRadius:
                          const BorderRadius.all(Radius.circular(20.0)),
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (appBox.get('averageBleedingByDay') != null &&
                            appBox.get('averageBleedingByDay').isNotEmpty) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                height: 60,
                                width: 60,
                                child: IconButton(
                                  padding: const EdgeInsets.all(0.0),
                                  onPressed: selectedPeriodDay == 1
                                      ? null
                                      : () {
                                          setState(() {
                                            selectedPeriodDay--;
                                          });
                                        },
                                  icon: const Icon(
                                    Icons.keyboard_arrow_left_rounded,
                                    size: 60.0,
                                  ),
                                ),
                              ),
                              AutoSizeText(
                                (appBox.get('averageBleedingByDay')[
                                            selectedPeriodDay] *
                                        10)
                                    .toStringAsFixed(1),
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 80.0,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              SizedBox(
                                height: 60,
                                width: 60,
                                child: IconButton(
                                  padding: const EdgeInsets.all(0.0),
                                  alignment: Alignment.center,
                                  onPressed: appBox
                                              .get('averageBleedingByDay')
                                              .length ==
                                          selectedPeriodDay
                                      ? null
                                      : () {
                                          setState(() {
                                            selectedPeriodDay++;
                                          });
                                        },
                                  icon: const Icon(
                                    Icons.keyboard_arrow_right_rounded,
                                    size: 60.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          printNA()
                        ],
                        AutoSizeText(
                          '${AppLocalizations.of(context)!.averageBleeding} $selectedPeriodDay',
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
                ] else ...[
                  const SizedBox(
                    width: 120,
                    child: Divider(
                      thickness: 2,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                ],
                AutoSizeText(
                  (appBox.get('averageCycle') ??
                          AppLocalizations.of(context)!.nA)
                      .toString(),
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 80.0,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                AutoSizeText(
                  AppLocalizations.of(context)!.averageCycle,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(
                  height: 50.0,
                ),
                Container(
                  padding: const EdgeInsets.all(15.0),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                    color: appBox.get('darkMode')
                        ? Colors.black
                        : Colors.grey[300],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(15.0),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20.0)),
                          color: appBox.get('darkMode')
                              ? Colors.grey[900]
                              : Colors.grey[200],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AutoSizeText(
                              AppLocalizations.of(context)!.daysUsingTyd,
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            AutoSizeText(
                              (appBox.get('totalDaysTracked') ?? '0')
                                  .toString(),
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 80.0,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(15.0),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(20.0)),
                                color: appBox.get('darkMode')
                                    ? Colors.grey[900]
                                    : Colors.grey[200],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  AutoSizeText(
                                    (appBox.get('totalPeriodDays') ?? '0')
                                        .toString(),
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 80.0,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  AutoSizeText(
                                    AppLocalizations.of(context)!
                                        .totalPeriodDays,
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 15.0,
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(15.0),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(20.0)),
                                color: appBox.get('darkMode')
                                    ? Colors.grey[900]
                                    : Colors.grey[200],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  AutoSizeText(
                                    (appBox.get('totalPmsDays') ?? '0')
                                        .toString(),
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 80.0,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  AutoSizeText(
                                    AppLocalizations.of(context)!.totalPmsDays,
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: bottomNavBar(context, 3),
    );
  }
}
