// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DayDataAdapter extends TypeAdapter<DayData> {
  @override
  final int typeId = 0;

  @override
  DayData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DayData()
      ..period = fields[0] == null ? false : fields[0] as bool
      ..pms = fields[1] == null ? false : fields[1] as bool
      ..bleeding = fields[2] == null ? 0.0 : fields[2] as double
      ..pain = fields[3] == null ? 0.0 : fields[3] as double
      ..periodSymptoms =
          fields[4] == null ? [] : (fields[4] as List).cast<String>()
      ..periodMedsTaken =
          fields[5] == null ? [] : (fields[5] as List).cast<String>()
      ..periodNotes = fields[6] == null ? '' : fields[6] as String
      ..pmsSymptoms =
          fields[7] == null ? [] : (fields[7] as List).cast<String>()
      ..pmsMedsTaken =
          fields[8] == null ? [] : (fields[8] as List).cast<String>()
      ..pmsNotes = fields[9] == null ? '' : fields[9] as String
      ..timerData =
          fields[10] == null ? [] : (fields[10] as List).cast<TimerData>();
  }

  @override
  void write(BinaryWriter writer, DayData obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.period)
      ..writeByte(1)
      ..write(obj.pms)
      ..writeByte(2)
      ..write(obj.bleeding)
      ..writeByte(3)
      ..write(obj.pain)
      ..writeByte(4)
      ..write(obj.periodSymptoms)
      ..writeByte(5)
      ..write(obj.periodMedsTaken)
      ..writeByte(6)
      ..write(obj.periodNotes)
      ..writeByte(7)
      ..write(obj.pmsSymptoms)
      ..writeByte(8)
      ..write(obj.pmsMedsTaken)
      ..writeByte(9)
      ..write(obj.pmsNotes)
      ..writeByte(10)
      ..write(obj.timerData);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DayDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
