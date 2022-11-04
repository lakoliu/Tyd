import 'package:flutter/material.dart';
import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:tyd/views/components/bottom_nav_bar.dart';
import 'package:filter_list/filter_list.dart';
import 'package:tyd/helpers/constants.dart';
import 'package:intl/intl.dart';
import 'package:tyd/day_data.dart';
import 'package:hive/hive.dart';

import '../helpers/update_stats.dart';

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
            case 'pmsMedication': currDayData.pmsMedsTaken = selectedList; break;
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
        title: const Text(
          'History',
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
                locale: Intl.getCurrentLocale(),
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
                          const Text(
                            'Period',
                            style: TextStyle(
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
                          const Text(
                            'PMS',
                            style: TextStyle(
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
                      const Text('Bleeding'),
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
                      const Text('Pain'),
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
                          const Text('Symptoms'),
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
                      const Text('Medication Taken'),
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
                                  hint: const Text('Medication'),
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
                                decoration: const InputDecoration.collapsed(
                                  hintText: 'Time',
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
                                decoration: const InputDecoration.collapsed(
                                  hintText: 'Dose',
                                ),
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
                        decoration: const InputDecoration(
                          labelText: 'Notes',
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
                          const Text('Symptoms'),
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
                      Row(
                        children: [
                          const Text('Medication Taken'),
                          TextButton(
                            onPressed: () => openAddRemoveDialog(
                                listData: medicines,
                                selectedList: currDayData.pmsMedsTaken,
                                dataField: 'pmsMedication'),
                            child: Text(
                              '+',
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
                          for (var symptom in currDayData.pmsMedsTaken) ...[
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
                      TextFormField(
                        initialValue: currDayData.pmsNotes,
                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Notes',
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
