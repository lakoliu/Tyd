import 'package:stop_watch_timer/stop_watch_timer.dart';

class StopwatchHelper {
  static final StopwatchHelper _stopwatchHelper = StopwatchHelper._internal();

  final stopWatchTimer = StopWatchTimer();
  late DateTime startTime;
  var typeSelected = 'Tampon';
  var sizeSelected = '-';
  var radioSelected = 1;

  factory StopwatchHelper() {
    return _stopwatchHelper;
  }

  StopwatchHelper._internal();
}
