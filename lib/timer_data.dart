import 'package:hive/hive.dart';

part 'timer_data.g.dart';

@HiveType(typeId: 1)
class TimerData extends HiveObject {

  @HiveField(0, defaultValue: '')
  late String type;

  @HiveField(1, defaultValue: '-')
  late String size = '-';

  @HiveField(2)
  late DateTime startTime;

  @HiveField(3)
  late DateTime stopTime;

  TimerData(this.type, this.startTime, this.stopTime, this.size);
}