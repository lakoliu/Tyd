import 'package:hive/hive.dart';
import 'package:vula/timer_data.dart';

part 'day_data.g.dart';

@HiveType(typeId: 0)
class DayData extends HiveObject {

  @HiveField(0, defaultValue: false)
  bool period = false;

  @HiveField(1, defaultValue: false)
  bool pms = false;

  @HiveField(2, defaultValue: 0.0)
  double bleeding = 0;

  @HiveField(3, defaultValue: 0.0)
  double pain = 0;

  @HiveField(4, defaultValue: [])
  List<String> periodSymptoms = [];

  @HiveField(5, defaultValue: [])
  List<String> periodMedsTaken = [];

  @HiveField(6, defaultValue: '')
  var periodNotes = '';

  @HiveField(7, defaultValue: [])
  List<String> pmsSymptoms = [];

  @HiveField(8, defaultValue: [])
  List<String> pmsMedsTaken = [];

  @HiveField(9, defaultValue: '')
  var pmsNotes = '';

  @HiveField(10, defaultValue: [])
  List<TimerData> timerData = [];
}