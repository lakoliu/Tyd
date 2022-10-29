import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:vula/day_data.dart';
import 'package:collection/collection.dart';

void resetAllStats() {
  var appBox = Hive.box('app_box');

  appBox.put('latestStartDate', null);
  appBox.put('lastPeriod', null);
  appBox.put('lastEndDate', null);
  appBox.put('lastStartDate', null);
  appBox.put('averageCycle', null);
  appBox.put('totalDaysTracked', null);
  appBox.put('longestPeriod', null);
  appBox.put('averagePeriod', null);
  appBox.put('averageBleedingByDay', null);
  appBox.put('totalPeriodDays', null);
}

void updateStats() {
  var appBox = Hive.box('app_box');
  var dateBox = Hive.box('date_box');
  resetAllStats();
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  final todayFormatted = formatter.format(DateTime.now());

  var datesChronological = dateBox.keys.toList();
  if (datesChronological.isNotEmpty) {
    datesChronological.sort((a,b) => b.compareTo(a));

    // First, check if we are currently on period.
    DayData? todaysData = dateBox.get(todayFormatted);
    var onPeriod = false;
    if (todaysData != null && todaysData.period) {
      onPeriod = true;
    }

    // Next, remove current period days if on period
    var alteredDates = List<String>.from(datesChronological);
    var latestStart = '';
    if (onPeriod) {
      int indexToRemove = 0;
      for (var date in datesChronological) {
        DayData dayData = dateBox.get(date);

        if (dayData.period) {
          latestStart = date;
          indexToRemove = datesChronological.indexOf(date);
        } else {
          appBox.put('latestStartDate', DateTime.parse(latestStart));
          break;
        }
      }
      // Remove index
      alteredDates.removeRange(0, indexToRemove + 1);
    } else {
      // Record latestStartDate if not on period
      var periodFound = false;
      var dayBefore = DateTime.now();
      DateTime? trueLatestStartDate;
      for (var date in datesChronological) {
        DayData dayData = dateBox.get(date);
        var parsedDate = DateTime.parse(date);

        if (dayData.period) {
          if (periodFound && dayBefore.difference(parsedDate).inDays == 1) {
            trueLatestStartDate = dayBefore;
          } else if (periodFound && dayBefore.difference(parsedDate).inDays != 1) {
            appBox.put('latestStartDate', dayBefore);
            trueLatestStartDate = null;
            break;
          }
          periodFound = true;
        } else {
          if (periodFound) {
            appBox.put('latestStartDate', dayBefore);
            trueLatestStartDate = null;
            break;
          }
        }
        dayBefore = parsedDate;
      }
      if (trueLatestStartDate != null) {
        appBox.put('latestStartDate', trueLatestStartDate);
      }
    }

    var periodFound = false;
    var dayBefore = DateTime.now();
    for (var date in alteredDates) {
      DayData dayData = dateBox.get(date);
      var parsedDate = DateTime.parse(date);

      if (periodFound) {
        // If it's the last in the list, it should end
        if (alteredDates.indexOf(date) == alteredDates.length - 1) {
          if (dayData.period  && dayBefore.difference(parsedDate).inDays == 1) {
            appBox.put('lastStartDate', parsedDate);
          } else {
            appBox.put('lastStartDate', dayBefore);
          }
          break;
        } else if (dayData.period  && dayBefore.difference(parsedDate).inDays == 1) {
          dayBefore = DateTime.parse(date);
        } else {
          appBox.put('lastStartDate', dayBefore);
          break;
        }
      } else {
        if (dayData.period) {
          periodFound = true;
          var parsedDate = DateTime.parse(date);
          appBox.put('lastEndDate', parsedDate);
          dayBefore = parsedDate;
        }
      }
    }

    // Format the 'Last Period' string
    if (appBox.get('lastStartDate') != null && appBox.get('lastEndDate') != null) {
      final DateFormat monthDayFormatter = DateFormat('MMM d');
      var lastStart = monthDayFormatter.format(appBox.get('lastStartDate'));
      var lastEnd = monthDayFormatter.format(appBox.get('lastEndDate'));
      if (lastStart == lastEnd) {
        appBox.put('lastPeriod', lastStart);
      } else {
        appBox.put('lastPeriod', '$lastStart - $lastEnd');
      }
    }

    // Calculate average cycle
    List<int> cycleIntervals = [];
    var currInterval = 0;
    var endAtNextPeriod = false;
    var lastDate = '';
    var daysBetween = 0;
    var lastParsed = DateTime.now();
    for (var date in datesChronological.reversed) {
      DayData dayData = dateBox.get(date);
      var parsedDate = DateTime.parse(date);

      if(lastDate.isNotEmpty) {
        lastParsed = DateTime.parse(lastDate);
        daysBetween = parsedDate.difference(lastParsed).inDays;
      }

      if(lastDate.isEmpty || daysBetween == 1) {
        if (!dayData.period) {
          // Not a period
          endAtNextPeriod = true;
          currInterval += 1;
        } else if (endAtNextPeriod) {
          // Found the next period and need to end
          cycleIntervals.add(currInterval);
          currInterval = 1;
          endAtNextPeriod = false;
        } else {
          // Found the next period, but don't need to end
          currInterval += 1;
        }
      } else {
        currInterval += daysBetween - 1;
        if (dayData.period) {
          cycleIntervals.add(currInterval);
          currInterval = 1;
          endAtNextPeriod = false;
        } else {
          endAtNextPeriod = true;
        }
      }
      lastDate = date;
    }
    if (cycleIntervals.isNotEmpty) {
      var averageCycle = cycleIntervals.sum / cycleIntervals.length;
      appBox.put('averageCycle', averageCycle.round());
    } else {
      appBox.put('averageCycle', null);
    }
  }
}

void updateSecondaryStats() {
  var dateBox = Hive.box('date_box');
  var appBox = Hive.box('app_box');
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  final todayFormatted = formatter.format(DateTime.now());

  var datesChronological = dateBox.keys.toList();
  if (datesChronological.isNotEmpty) {
    datesChronological.sort((a,b) => b.compareTo(a));

    // Calculate number of dates tracked (starting date until today)
    var firstDay = DateTime.parse(datesChronological.reversed.first);
    var numDaysTracked = DateTime.now().difference(firstDay);
    appBox.put('totalDaysTracked', numDaysTracked.inDays);

    // Calculate average period length AND average bleeding by day
    bool? lastWasPeriod;
    List<int> periodIntervals = [];
    var counter = 0;
    var lastDate = '';
    var lastParsed = DateTime.now();
    var daysBetween = 0;
    // List<double> bleedingByDay = [];
    List<List<double>> bleedingByDay = [];
    for (var date in datesChronological.reversed) {
      DayData dayData = dateBox.get(date);
      var parsedDate = DateTime.parse(date);

      if (lastDate.isNotEmpty) {
        lastParsed = DateTime.parse(lastDate);
        daysBetween = parsedDate.difference(lastParsed).inDays;
      }

      if (dayData.period) {
        if (lastWasPeriod == null || !lastWasPeriod) {
          // bleedingByDay.add(dayData.bleeding);
          counter ++;
          lastWasPeriod = true;
        } else if (lastWasPeriod && daysBetween == 1) {
          // bleedingByDay.add(dayData.bleeding);
          counter ++;
          lastWasPeriod = true;
        } else if (lastWasPeriod && daysBetween !=1) {
          // allBleedingData.add(bleedingByDay);
          // bleedingByDay = [];
          periodIntervals.add(counter);
          counter = 1;
          lastWasPeriod = true;
        }
      } else {
        if (lastWasPeriod ?? false) {
          // allBleedingData.add(bleedingByDay);
          // bleedingByDay = [];
          periodIntervals.add(counter);
          counter = 0;
        }
        lastWasPeriod = false;
      }
      lastDate = date;

      // Organize bleeding into days
      if (counter > 0) {
        if (bleedingByDay.asMap().containsKey(counter-1)) {
          bleedingByDay[counter-1].add(dayData.bleeding);
        } else {
          List<double> newPeriodDay = [dayData.bleeding];
          bleedingByDay.add(newPeriodDay);
        }
      }
    }
    if (periodIntervals.isNotEmpty) {
      // Get longest period length for average bleeding stats
      // TODO technically, this could be removed and I could use the length of averageBleedingByDay instead
      periodIntervals.sort();
      appBox.put('longestPeriod', periodIntervals.last);

      var averageCycle = periodIntervals.sum / periodIntervals.length;
      appBox.put('averagePeriod', averageCycle.round());
    } else {
      appBox.put('longestPeriod', null);
      appBox.put('averagePeriod', null);
    }
    if (bleedingByDay.isNotEmpty) {
      Map<int, double> averageBleedingByDay = {};
      for (var i = 0; i < bleedingByDay.length; i++) {
        var averageBleeding = bleedingByDay[i].sum / bleedingByDay[i].length;
        averageBleedingByDay[i+1] = averageBleeding;
      }
      appBox.put('averageBleedingByDay', averageBleedingByDay);
    }

    // Calculate total period days
    var numPeriodDays = 0;
    for (var date in datesChronological) {
      DayData dayData = dateBox.get(date);

      if (dayData.period) {
        numPeriodDays++;
      }
    }
    appBox.put('totalPeriodDays', numPeriodDays);
  }
}