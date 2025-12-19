// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlaceHiveModelAdapter extends TypeAdapter<PlaceHiveModel> {
  @override
  final int typeId = 0;

  @override
  PlaceHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlaceHiveModel(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      imageUrl: fields[3] as String,
      distance: fields[4] as double,
      rating: fields[5] as double,
      type: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PlaceHiveModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.imageUrl)
      ..writeByte(4)
      ..write(obj.distance)
      ..writeByte(5)
      ..write(obj.rating)
      ..writeByte(6)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaceHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
