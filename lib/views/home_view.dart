import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  var whatDay = 18;
  var avgCycleDays = 28;

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    // Automatically scroll to the current day of cycle in timeline
    _scrollController.animateTo(whatDay * 86, duration: const Duration(seconds: 2), curve: Curves.ease);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              const SizedBox(height: 10.0),
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 50.0),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: avgCycleDays,
                    controller: _scrollController,
                    itemBuilder: (BuildContext context, int index) {
                      return TimelineTile(
                        alignment: TimelineAlign.center,
                        axis: TimelineAxis.horizontal,
                        isFirst: index == 0,
                        isLast: index == avgCycleDays - 1,
                        indicatorStyle: IndicatorStyle(
                          width: 30,
                          height: 30,
                          indicatorXY: 0.0,
                          indicator: _IndicatorExample(number: '${index + 1}'),
                          drawGap: true,
                        ),
                        beforeLineStyle: const LineStyle(
                          thickness: 3.0,
                        ),
                        afterLineStyle: const LineStyle(
                          thickness: 3.0,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30.0),
              const Text(
                'DAY',
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
              Text(
                whatDay.toString(),
                style: const TextStyle(
                  fontSize: 120.0,
                ),
              ),
              Text(
                '~ ${avgCycleDays-whatDay} days until your next period',
                style: const TextStyle(
                  fontSize: 15.0,
                ),
              ),
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
            color: Colors.black.withOpacity(0.2),
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