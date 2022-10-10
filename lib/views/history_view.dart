import 'package:flutter/material.dart';
import 'package:calendar_timeline/calendar_timeline.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({Key? key}) : super(key: key);

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  var periodSwitch = false;
  var pmsSwitch = false;

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
                initialDate: DateTime.now(),
                firstDate: DateTime(2015, 1, 1),
                lastDate: DateTime.now(),
                onDateSelected: (date) => print(date), // TODO change page shown
                leftMargin: 20,
                monthColor: Colors.grey,
                dayColor: Colors.grey, // TODO set today to primary color and period days to red
                activeDayColor: Colors.white,
                activeBackgroundDayColor: Colors.pink[300],
                dotsColor: const Color(0xFF333A47),
                locale: 'en_ISO', // TODO Set to user's locale
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 50.0),
                    Row(
                      children: [
                        const Text(
                          'Period',
                          style: TextStyle(
                            fontSize: 20.0,
                          ),
                        ),
                        Switch(
                          activeColor: Colors.pink[300],
                          value: periodSwitch,
                          onChanged: (bool value) {
                            setState(() {
                              // TODO Add "Are you sure" dialog if switching off because all information will be deleted?
                              periodSwitch = value;
                            });
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          'PMS',
                          style: TextStyle(
                            fontSize: 20.0,
                          ),
                        ),
                        Switch(
                          activeColor: Colors.pink[300],
                          value: pmsSwitch,
                          onChanged: (bool value) {
                            setState(() {
                              // TODO Add "Are you sure" dialog if switching off because all information will be deleted?
                              pmsSwitch = value;
                            });
                          },
                        ),
                      ],
                    ),
                    if (periodSwitch) ...[
                      const SizedBox(height: 20.0,),
                      const Text('Strength'),
                      Row(
                        children: [
                          // const Text('0'),
                          Slider(
                            value: 0.5,
                            onChanged: (value) {

                            },
                          ),
                          const Text('10'),
                        ],
                      ),
                      const Text('Pain'),
                      Row(
                        children: [
                          // const Text('0'),
                          Slider(
                            value: 0.5,
                            onChanged: (value) {

                            },
                          ),
                          const Text('10'),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('Symptoms'),
                          TextButton(
                            onPressed: () {},
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
                        children:
                        [
                          for (var i = 0; i < 7; i++) ...[
                            Chip(
                              label: const Text(
                                'Headache',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: Colors.pink[300],
                            ),
                          ], // for
                        ],
                      ),

                      // TODO Pain medication taken'
                      const SizedBox(height: 12.0),
                      const Text('Notes'),
                      const TextField(
                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        maxLines: null,
                      ),
                    ], // If periodSwitch toggled
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
