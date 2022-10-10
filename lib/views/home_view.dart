import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:vula/views/history_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  var whatDay = 18;
  var avgCycleDays = 28;
  var period = false;

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // const SizedBox(height: 10.0),
              // const SizedBox(height: 30.0),
              const Text(
                'DAY',
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
              Text(
                whatDay.toString(),
                // Change color to red if on period
                style: const TextStyle(
                  fontSize: 120.0,
                ),
              ),
              // TODO Don't show if currently on period
              Text(
                '~ ${avgCycleDays - whatDay} days until your next period',
                style: const TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10.0,),
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Last period: Mar 8 - Mar 14',
                      style: TextStyle(
                        fontSize: 15.0,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 10.0,),
                    const Text(
                      'Your average cycle: 28 days',
                      style: TextStyle(
                        fontSize: 15.0,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30.0,),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HistoryView()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)
                  ),
                  padding: const EdgeInsets.all(12.0),
                ),
                child: Text(
                  period ? 'Stop Period' : 'Start Period',
                  style: const TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
              const SizedBox(height: 50.0,), // To push everything up a little. TODO Necessary?
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     const Text(
              //       'PMS',
              //       style: TextStyle(
              //         fontSize: 20.0,
              //       ),
              //     ),
              //     Switch(value: false, onChanged: (value) {})
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IndicatorExample extends StatelessWidget {
  const _IndicatorExample({Key? key, required this.number}) : super(key: key);

  final String number;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.fromBorderSide(
          BorderSide(
            color: Colors.black.withOpacity(0.2), // Red for period days, black for other days (or dark gray), and light gray for future days. (Green for days where you have the most energy?)
            width: 4,
          ),
        ),
      ),
      child: Center(
        child: Text(
          number,
          style: const TextStyle(fontSize: 15),
        ),
      ),
    );
  }
}