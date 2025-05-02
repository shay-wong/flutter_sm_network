// ignore_for_file: public_member_api_docs

import 'package:json_annotation/json_annotation.dart';

/// 日期时间转换
class MicroEpochDateTimeConverter implements JsonConverter<DateTime, int> {
  @override
  DateTime fromJson(int json) => DateTime.fromMicrosecondsSinceEpoch(json);

  @override
  int toJson(DateTime object) => object.microsecondsSinceEpoch;
}

/// 日期时间转换
class MilliEpochDateTimeConverter implements JsonConverter<DateTime, int> {
  @override
  DateTime fromJson(int json) => DateTime.fromMillisecondsSinceEpoch(json);

  @override
  int toJson(DateTime object) => object.millisecondsSinceEpoch;
}

/// 日期时间转换
class StringDateTimeConverter implements JsonConverter<DateTime?, String> {
  @override
  DateTime? fromJson(String json) => DateTime.tryParse(json);

  @override
  String toJson(DateTime? object) => object.toString();
}
