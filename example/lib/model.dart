import 'dart:convert';

import 'package:sm_network/sm_network.dart';

part 'model.g.dart';

@JsonSerializable()
class Person {
  Person({
    this.name,
    this.age,
  });

  factory Person.fromJson(Map<String, dynamic> srcJson) => _$PersonFromJson(srcJson);

  @IntConverter()
  int? age;

  @DateStringConverter()
  DateTime? birth;

  @DateDayConverter()
  DateTime? day;

  @DateHourConverter()
  DateTime? hour;

  @DateMicroEpochConverter()
  DateTime? microsecond;

  @DateMilliEpochConverter()
  DateTime? millisecond;

  @DateMinuteConverter()
  DateTime? minute;

  @DateMonthConverter()
  DateTime? month;

  @StringConverter()
  String? name;

  @DateSecondConverter()
  DateTime? second;

  @DateYearConverter()
  DateTime? year;

  @override
  String toString() {
    return JsonEncoder.withIndent('  ').convert(toJson());
  }

  Map<String, dynamic> toJson() => _$PersonToJson(this);
}
