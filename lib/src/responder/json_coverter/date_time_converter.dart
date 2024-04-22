import 'package:json_annotation/json_annotation.dart';

class StringDateTimeConverter implements JsonConverter<DateTime?, String> {
  const StringDateTimeConverter();

  @override
  DateTime? fromJson(String json) => DateTime.tryParse(json);

  @override
  String toJson(DateTime? object) => object.toString();
}

class MicroEpochDateTimeConverter implements JsonConverter<DateTime, int> {
  const MicroEpochDateTimeConverter();

  @override
  DateTime fromJson(int json) => DateTime.fromMicrosecondsSinceEpoch(json);

  @override
  int toJson(DateTime object) => object.microsecondsSinceEpoch;
}

class MilliEpochDateTimeConverter implements JsonConverter<DateTime, int> {
  const MilliEpochDateTimeConverter();

  @override
  DateTime fromJson(int json) => DateTime.fromMillisecondsSinceEpoch(json);

  @override
  int toJson(DateTime object) => object.millisecondsSinceEpoch;
}
