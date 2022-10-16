import 'package:flutter/material.dart';
import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:vula/views/home_view.dart';
import 'package:filter_list/filter_list.dart';
import 'package:vula/helpers/constants.dart';
import 'package:intl/intl.dart';
import 'package:vula/day_data.dart';
import 'package:hive/hive.dart';

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

  // TODO TEMPORARY
  var periodSwitch = false;
  var pmsSwitch = false;
  List<String> userAddedPeriodSymps = ['User', 'Added'];
  List<String> userAddedMedicines = ['User', 'Added'];

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
          selectedBackgroundColor: appBox.get('accentColor') ?? Colors.pink[300],
          backgroundColor: Colors.grey[200],
        ),
        controlButtonBarTheme: ControlButtonBarThemeData(
          context,
          controlButtonTheme: ControlButtonThemeData(
            textStyle: TextStyle(
              color: appBox.get('accentColor') ?? Colors.pink[300],
            ),
            primaryButtonBackgroundColor: appBox.get('accentColor') ?? Colors.pink[300],
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
            case 'periodMedication': currDayData.periodMedsTaken = selectedList; break;
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
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // TODO set initial scroll position to show other dates and months
              CalendarTimeline(
                initialDate: currDate,
                firstDate: DateTime(2015, 1,
                    1), // TODO Should be earlier if an earlier date is saved in database
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
                }, // TODO add date and dayData to local vars
                leftMargin: 20,
                monthColor: Colors.grey,
                dayColor: Colors
                    .grey, // TODO set today to primary color and period days to red
                activeDayColor: Colors.white,
                activeBackgroundDayColor: appBox.get('accentColor') ?? Colors.pink[300],
                dotsColor: const Color(0xFF333A47),
                locale: 'en_ISO', // TODO Set to user's locale
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 50.0),
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
                            activeColor: appBox.get('accentColor') ?? Colors.pink[300],
                            value: currDayData.period,
                            onChanged: (bool value) {
                              setState(() {
                                currDayData.period = value;
                              });
                              updateDayData();
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
                            activeColor: appBox.get('accentColor') ?? Colors.pink[300],
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
                                listData: periodSymptoms + userAddedPeriodSymps,
                                selectedList: currDayData.periodSymptoms,
                                dataField: 'periodSymptoms'),
                            child: const Text(
                              '+/-',
                              style: TextStyle(
                                fontSize: 20.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // TODO add for loop to show all period symptoms as pill-shaped objects
                      // TODO Use an enum to make each symptom align with a number? Or just store as a list of strings.
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
                              backgroundColor: appBox.get('accentColor') ?? Colors.pink[300],
                            ),
                          ], // for
                        ],
                      ),
                      Row(
                        children: [
                          const Text('Medication Taken'),
                          TextButton(
                            onPressed: () => openAddRemoveDialog(
                                listData: medicines + userAddedMedicines,
                                selectedList: currDayData.periodMedsTaken,
                                dataField: 'periodMedication'),
                            child: const Text(
                              '+/-',
                              style: TextStyle(
                                fontSize: 20.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: -4.0,
                        children: [
                          for (var med in currDayData.periodMedsTaken) ...[
                            Chip(
                              label: Text(
                                med,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: appBox.get('accentColor') ?? Colors.pink[300],
                            ),
                          ], // for
                        ],
                      ),
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
                    ], // If periodSwitch toggled
                    if (currDayData.pms) ...[
                      Row(
                        children: [
                          const Text('Symptoms'),
                          TextButton(
                            onPressed: () => openAddRemoveDialog(
                                listData: pmsSymptoms,
                                selectedList: currDayData.pmsSymptoms,
                                dataField: 'pmsSymptoms'),
                            child: const Text(
                              '+/-',
                              style: TextStyle(
                                fontSize: 20.0,
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
                              backgroundColor: appBox.get('accentColor') ?? Colors.pink[300],
                            ),
                          ], // for
                        ],
                      ),
                      Row(
                        children: [
                          const Text('Medication Taken'),
                          TextButton(
                            onPressed: () => openAddRemoveDialog(
                                listData: medicines + userAddedMedicines,
                                selectedList: currDayData.pmsMedsTaken,
                                dataField: 'pmsMedication'),
                            child: const Text(
                              '+/-',
                              style: TextStyle(
                                fontSize: 20.0,
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
                              backgroundColor: appBox.get('accentColor') ?? Colors.pink[300],
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
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Tampon Timer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistics',
          ),
        ],
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomeView()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryView()),
            );
          }
        },
      ),
    );
  }
}
