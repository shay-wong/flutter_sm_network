// ignore_for_file: public_member_api_docs

import 'package:json_annotation/json_annotation.dart';

/// 日-日期时间 转换
class DateDayConverter implements JsonConverter<DateTime, int> {
  const DateDayConverter();

  @override
  DateTime fromJson(int json) => DateTime(1970, 1, json + 1);

  @override
  int toJson(DateTime object) => object.second;
}

/// 时-日期时间 转换
class DateHourConverter implements JsonConverter<DateTime, int> {
  const DateHourConverter();

  @override
  DateTime fromJson(int json) => DateTime(1970, 1, 1, json);

  @override
  int toJson(DateTime object) => object.second;
}

/// 微秒-日期时间 转换
class DateMicroEpochConverter implements JsonConverter<DateTime, int> {
  const DateMicroEpochConverter();

  @override
  DateTime fromJson(int json) => DateTime.fromMicrosecondsSinceEpoch(json);

  @override
  int toJson(DateTime object) => object.microsecondsSinceEpoch;
}

/// 毫秒-日期时间 转换
class DateMilliEpochConverter implements JsonConverter<DateTime, int> {
  const DateMilliEpochConverter();

  @override
  DateTime fromJson(int json) => DateTime.fromMillisecondsSinceEpoch(json);

  @override
  int toJson(DateTime object) => object.millisecondsSinceEpoch;
}

/// 分-日期时间 转换
class DateMinuteConverter implements JsonConverter<DateTime, int> {
  const DateMinuteConverter();

  @override
  DateTime fromJson(int json) => DateTime(1970, 1, 1, 0, json);

  @override
  int toJson(DateTime object) => object.second;
}

/// 月-日期时间 转换
class DateMonthConverter implements JsonConverter<DateTime, int> {
  const DateMonthConverter();

  @override
  DateTime fromJson(int json) => DateTime(1970, 1 + json);

  @override
  int toJson(DateTime object) => object.second;
}

/// 秒-日期时间 转换
class DateSecondConverter implements JsonConverter<DateTime, int> {
  const DateSecondConverter();

  @override
  DateTime fromJson(int json) => DateTime.fromMillisecondsSinceEpoch(json * 1000);

  @override
  int toJson(DateTime object) => object.second;
}

/// 日期格式化字符串-日期时间 转换
class DateStringConverter implements JsonConverter<DateTime?, String?> {
  const DateStringConverter();

  @override
  DateTime? fromJson(String? json) {
    return json == null ? null : DateTime.tryParse(json);
  }

  @override
  String? toJson(DateTime? object) {
    return object?.toIso8601String();
  }
}

/// 日-日期时间 转换
class DateYearConverter implements JsonConverter<DateTime, int> {
  const DateYearConverter();

  @override
  DateTime fromJson(int json) => DateTime(json + 1970);

  @override
  int toJson(DateTime object) => object.second;
}
