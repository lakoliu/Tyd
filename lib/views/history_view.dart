import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:tyd/views/components/bottom_nav_bar.dart';
import 'package:filter_list/filter_list.dart';
import 'package:tyd/helpers/constants.dart';
import 'package:intl/intl.dart';
import 'package:tyd/day_data.dart';
import 'package:hive/hive.dart';

import '../helpers/update_stats.dart';
import '../packages/calendar_timeline/calendar_timeline.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({Key? key}) : super(key: key);

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  var dateBox = Hive.box('date_box');
  var appBox = Hive.box('app_box');

  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  var currDate = DateTime.now();
  DayData currDayData = DayData();
  var numMedRows = 1;

  @override
  void initState() {
    super.initState();
    var savedDayData = dateBox.get(formatter.format(currDate));
    if (savedDayData != null) {
      currDayData = savedDayData;
    }
  }

  void updateDayData() {
    dateBox.put(formatter.format(currDate), currDayData);
  }

  void resetPage() {
    var savedDayData = dateBox.get(formatter.format(currDate));
    if (savedDayData != null) {
      currDayData = savedDayData;
    }
  }

  DateTime getFirstCalendarDate() {
    DateTime? earliestDate = appBox.get('earliestDate');
    if (earliestDate != null) {
      // If the earliest date was within the last year, add a year of runway
      // Otherwise, add two months of runway
      if (DateTime.now().difference(earliestDate).inDays < 365) {
        return earliestDate.add(const Duration(days: -365));
      } else {
        return earliestDate.add(const Duration(days: -60));
      }
    } else {
      // If there is no earliest date, just start one year earlier.
      return DateTime.now().add(const Duration(days: -365));
    }
  }

  void openAddRemoveDialog(
      {required List<String> listData,
      required List<String> selectedList,
      required String dataField}) async {
    await FilterListDialog.display<String>(
      context,
      listData: listData,
      selectedListData: selectedList,
      choiceChipLabel: (symptoms) => symptoms,
      validateSelectedItem: (list, val) => list!.contains(val),
      hideHeader: true,
      hideSelectedTextCount: true,
      themeData: FilterListThemeData(
        context,
        choiceChipTheme: ChoiceChipThemeData(
          selectedBackgroundColor: Theme.of(context).primaryColor,
          backgroundColor: appBox.get('darkMode', defaultValue: false) ? Colors.grey[700] : Colors.grey[200],
        ),
        controlButtonBarTheme: ControlButtonBarThemeData(
          context,
          controlButtonTheme: ControlButtonThemeData(
            textStyle: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
            primaryButtonBackgroundColor: Theme.of(context).primaryColor,
          ),
        ),
      ),
      onItemSearch: (symptoms, query) {
        return symptoms.toLowerCase().contains(query.toLowerCase());
      },
      onApplyButtonClick: (list) {
        selectedList = List.from(list!);
        setState(() {
          switch (dataField) {
            case 'periodSymptoms': currDayData.periodSymptoms = selectedList; break;
            case 'pmsSymptoms': currDayData.pmsSymptoms = selectedList; break;
          }
        });
        updateDayData();
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.history,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          reverse: true,
          child: Column(
            children: [
              CalendarTimeline(
                initialDate: currDate,
                firstDate: getFirstCalendarDate(),
                lastDate: DateTime.now(),
                onDateSelected: (date) {
                  currDate = date;
                  var savedDayData = dateBox.get(formatter.format(currDate));
                  setState(() {
                    if (savedDayData != null) {
                      currDayData = savedDayData;
                    } else {
                      currDayData = DayData();
                    }
                  });
                },
                leftMargin: 20,
                monthColor: Colors.grey,
                dayColor: Colors.grey,
                activeDayColor: Colors.white,
                activeBackgroundDayColor: Theme.of(context).primaryColor,
                dotsColor: const Color(0xFF333A47),
                locale: AppLocalizations.of(context)!.localeName,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10.0),
                    if (!currDayData.pms) ...[
                      Row(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.period,
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
                            },
                          ),
                        ],
                      ),
                    ],
                    if (!currDayData.period) ...[
                      Row(
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
                            },
                          ),
                        ],
                      ),
                    ],
                    if (currDayData.period) ...[
                      const SizedBox(
                        height: 20.0,
                      ),
                      Text(AppLocalizations.of(context)!.bleeding),
                      Row(
                        children: [
                          Slider(
                            value: currDayData.bleeding,
                            divisions: 10,
                            thumbColor: Theme.of(context).primaryColor,
                            activeColor: Theme.of(context).primaryColor,
                            inactiveColor: Theme.of(context).primaryColorLight,
                            onChanged: (value) {
                              setState(() {
                                currDayData.bleeding = value;
                              });
                            },
                            onChangeEnd: (value) => updateDayData(),
                          ),
                          Text((currDayData.bleeding * 10).round().toString()),
                        ],
                      ),
                      Text(AppLocalizations.of(context)!.pain),
                      Row(
                        children: [
                          Slider(
                            value: currDayData.pain,
                            divisions: 10,
                            thumbColor: Theme.of(context).primaryColor,
                            activeColor: Theme.of(context).primaryColor,
                            inactiveColor: Theme.of(context).primaryColorLight,
                            onChanged: (value) {
                              setState(() {
                                currDayData.pain = value;
                              });
                            },
                            onChangeEnd: (value) => updateDayData(),
                          ),
                          Text((currDayData.pain * 10).round().toString()),
                        ],
                      ),
                      Row(
                        children: [
                          Text(AppLocalizations.of(context)!.symptoms),
                          TextButton(
                            onPressed: () => openAddRemoveDialog(
                                listData: appBox.get('periodSymptoms'),
                                selectedList: currDayData.periodSymptoms,
                                dataField: 'periodSymptoms'),
                            child: Text(
                              '+/-',
                              style: TextStyle(
                                fontSize: 20.0,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: -4.0,
                        children: [
                          for (var symptom in currDayData.periodSymptoms) ...[
                            Chip(
                              label: Text(
                                symptom,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: Theme.of(context).primaryColor,
                            ),
                          ], // for
                        ],
                      ),
                      const SizedBox(height: 15.0,),
                      Text(AppLocalizations.of(context)!.medicationTaken),
                      for (var i = 0; i < currDayData.periodMedsTaken.length + 1; i++) ...[
                        Row(
                          children: [
                            if (currDayData.periodMedsTaken.asMap().containsKey(i) && !appBox.get('medicines').contains(currDayData.periodMedsTaken[i][0])) ...[
                              Expanded(
                                child: TextFormField(
                                  initialValue: currDayData.periodMedsTaken[i][0],
                                  enabled: false,
                                  onChanged: null,
                                  decoration: const InputDecoration(
                                    disabledBorder: InputBorder.none,
                                  ),
                                ),
                              ),
                            ] else ...[
                              DropdownButtonHideUnderline(
                                child: DropdownButton(
                                  hint: Text(AppLocalizations.of(context)!.medication),
                                  value: currDayData.periodMedsTaken.asMap().containsKey(i) ? currDayData.periodMedsTaken[i][0] : null,
                                  items: appBox.get('medicines')
                                      .map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      if (currDayData.periodMedsTaken.asMap().containsKey(i)) {
                                        currDayData.periodMedsTaken[i][0] = value.toString();
                                      } else {
                                        currDayData.periodMedsTaken.add([value.toString(), '', '']);
                                      }
                                      updateDayData();
                                    });
                                  },
                                ),
                              ),
                            ],
                            const SizedBox(width: 10.0,),
                            Expanded(
                              child: TextFormField(
                                initialValue: currDayData.periodMedsTaken.asMap().containsKey(i) ? currDayData.periodMedsTaken[i][1] : null,
                                enabled: currDayData.periodMedsTaken.asMap().containsKey(i),
                                onChanged: (value) {
                                  setState(() {
                                    currDayData.periodMedsTaken[i][1] = value.toString();
                                  });
                                  updateDayData();
                                },
                                decoration: InputDecoration.collapsed(
                                  hintText: AppLocalizations.of(context)!.time,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10.0,),
                            Expanded(
                              child: TextFormField(
                                initialValue: currDayData.periodMedsTaken.asMap().containsKey(i) ? currDayData.periodMedsTaken[i][2] : null,
                                enabled: currDayData.periodMedsTaken.asMap().containsKey(i),
                                onChanged: (value) {
                                  setState(() {
                                    currDayData.periodMedsTaken[i][2] = value.toString();
                                  });
                                  updateDayData();
                                },
                                decoration: InputDecoration.collapsed(
                                  hintText: AppLocalizations.of(context)!.dose,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: i >= currDayData.periodMedsTaken.length ? null : () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(AppLocalizations.of(context)!.deleteEntry),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text(AppLocalizations.of(context)!.cancelUpper),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            // setState(() {
                                              currDayData.periodMedsTaken.removeAt(i);
                                              updateDayData();
                                            // });
                                            Navigator.pop(context);
                                            Navigator.pushReplacementNamed(context, 'historyView');
                                          },
                                          child: Text(AppLocalizations.of(context)!.deleteUpper),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              icon: Icon(
                                i < currDayData.periodMedsTaken.length ? Icons.delete : null,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                      TextFormField(
                        initialValue: currDayData.periodNotes,
                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.notes,
                        ),
                        onChanged: (text) {
                          currDayData.periodNotes = text;
                          updateDayData();
                        },
                      ),
                    ],
                    if (currDayData.pms) ...[
                      Row(
                        children: [
                          Text(AppLocalizations.of(context)!.symptoms),
                          TextButton(
                            onPressed: () => openAddRemoveDialog(
                                listData: pmsSymptoms,
                                selectedList: currDayData.pmsSymptoms,
                                dataField: 'pmsSymptoms'),
                            child: Text(
                              '+/-',
                              style: TextStyle(
                                fontSize: 20.0,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: -4.0,
                        children: [
                          for (var symptom in currDayData.pmsSymptoms) ...[
                            Chip(
                              label: Text(
                                symptom,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: Theme.of(context).primaryColor,
                            ),
                          ], // for
                        ],
                      ),
                      Text(AppLocalizations.of(context)!.medicationTaken),
                      for (var i = 0; i < currDayData.pmsMedsTaken.length + 1; i++) ...[
                        Row(
                          children: [
                            if (currDayData.pmsMedsTaken.asMap().containsKey(i) && !appBox.get('medicines').contains(currDayData.pmsMedsTaken[i][0])) ...[
                              Expanded(
                                child: TextFormField(
                                  initialValue: currDayData.pmsMedsTaken[i][0],
                                  enabled: false,
                                  onChanged: null,
                                  decoration: const InputDecoration(
                                    disabledBorder: InputBorder.none,
                                  ),
                                ),
                              ),
                            ] else ...[
                              DropdownButtonHideUnderline(
                                child: DropdownButton(
                                  hint: Text(AppLocalizations.of(context)!.medication),
                                  value: currDayData.pmsMedsTaken.asMap().containsKey(i) ? currDayData.pmsMedsTaken[i][0] : null,
                                  items: appBox.get('medicines')
                                      .map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      if (currDayData.pmsMedsTaken.asMap().containsKey(i)) {
                                        currDayData.pmsMedsTaken[i][0] = value.toString();
                                      } else {
                                        currDayData.pmsMedsTaken.add([value.toString(), '', '']);
                                      }
                                      updateDayData();
                                    });
                                  },
                                ),
                              ),
                            ],
                            const SizedBox(width: 10.0,),
                            Expanded(
                              child: TextFormField(
                                initialValue: currDayData.pmsMedsTaken.asMap().containsKey(i) ? currDayData.pmsMedsTaken[i][1] : null,
                                enabled: currDayData.pmsMedsTaken.asMap().containsKey(i),
                                onChanged: (value) {
                                  setState(() {
                                    currDayData.pmsMedsTaken[i][1] = value.toString();
                                  });
                                  updateDayData();
                                },
                                decoration: InputDecoration.collapsed(
                                  hintText: AppLocalizations.of(context)!.time,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10.0,),
                            Expanded(
                              child: TextFormField(
                                initialValue: currDayData.pmsMedsTaken.asMap().containsKey(i) ? currDayData.pmsMedsTaken[i][2] : null,
                                enabled: currDayData.pmsMedsTaken.asMap().containsKey(i),
                                onChanged: (value) {
                                  setState(() {
                                    currDayData.pmsMedsTaken[i][2] = value.toString();
                                  });
                                  updateDayData();
                                },
                                decoration: InputDecoration.collapsed(
                                  hintText: AppLocalizations.of(context)!.dose,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: i >= currDayData.pmsMedsTaken.length ? null : () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(AppLocalizations.of(context)!.deleteEntry),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text(AppLocalizations.of(context)!.cancelUpper),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            // setState(() {
                                            currDayData.pmsMedsTaken.removeAt(i);
                                            updateDayData();
                                            // });
                                            Navigator.pop(context);
                                            Navigator.pushReplacementNamed(context, 'historyView');
                                          },
                                          child: Text(AppLocalizations.of(context)!.deleteUpper),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              icon: Icon(
                                i < currDayData.pmsMedsTaken.length ? Icons.delete : null,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                      TextFormField(
                        initialValue: currDayData.pmsNotes,
                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.notes,
                        ),
                        onChanged: (text) {
                          currDayData.pmsNotes = text;
                          updateDayData();
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: bottomNavBar(context, 1),
    );
  }
}