import 'package:hive/hive.dart';

class HistoryItem {
  final String id;
  final DateTime date;
  final String cleanliness;
  final int cleanlinessConfidence;
  final String integrity;
  final int integrityConfidence;
  final String? frontImage;
  final String? leftImage;
  final String? rightImage;
  final String? backImage;

  HistoryItem({
    required this.id,
    required this.date,
    required this.cleanliness,
    required this.cleanlinessConfidence,
    required this.integrity,
    required this.integrityConfidence,
    this.frontImage,
    this.leftImage,
    this.rightImage,
    this.backImage,
  });
}

// Ручной адаптер Hive
class HistoryItemAdapter extends TypeAdapter<HistoryItem> {
  @override
  final int typeId = 1;

  @override
  HistoryItem read(BinaryReader reader) {
    return HistoryItem(
      id: reader.readString(),
      date: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      cleanliness: reader.readString(),
      cleanlinessConfidence: reader.readInt(),
      integrity: reader.readString(),
      integrityConfidence: reader.readInt(),
      frontImage: reader.readBool() ? reader.readString() : null,
      leftImage: reader.readBool() ? reader.readString() : null,
      rightImage: reader.readBool() ? reader.readString() : null,
      backImage: reader.readBool() ? reader.readString() : null,
    );
  }

  @override
  void write(BinaryWriter writer, HistoryItem obj) {
    writer.writeString(obj.id);
    writer.writeInt(obj.date.millisecondsSinceEpoch);
    writer.writeString(obj.cleanliness);
    writer.writeInt(obj.cleanlinessConfidence);
    writer.writeString(obj.integrity);
    writer.writeInt(obj.integrityConfidence);

    writer.writeBool(obj.frontImage != null);
    if (obj.frontImage != null) writer.writeString(obj.frontImage!);

    writer.writeBool(obj.leftImage != null);
    if (obj.leftImage != null) writer.writeString(obj.leftImage!);

    writer.writeBool(obj.rightImage != null);
    if (obj.rightImage != null) writer.writeString(obj.rightImage!);

    writer.writeBool(obj.backImage != null);
    if (obj.backImage != null) writer.writeString(obj.backImage!);
  }
}
