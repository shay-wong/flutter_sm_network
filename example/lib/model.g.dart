// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Person _$PersonFromJson(Map<String, dynamic> json) => Person(
      name: const StringConverter().fromJson(json['name']),
      age: const IntConverter().fromJson(json['age']),
    )
      ..birth = const DateStringConverter().fromJson(json['birth'] as String?)
      ..day = _$JsonConverterFromJson<int, DateTime>(
          json['day'], const DateDayConverter().fromJson)
      ..hour = _$JsonConverterFromJson<int, DateTime>(
          json['hour'], const DateHourConverter().fromJson)
      ..microsecond = _$JsonConverterFromJson<int, DateTime>(
          json['microsecond'], const DateMicroEpochConverter().fromJson)
      ..millisecond = _$JsonConverterFromJson<int, DateTime>(
          json['millisecond'], const DateMilliEpochConverter().fromJson)
      ..minute = _$JsonConverterFromJson<int, DateTime>(
          json['minute'], const DateMinuteConverter().fromJson)
      ..month = _$JsonConverterFromJson<int, DateTime>(
          json['month'], const DateMonthConverter().fromJson)
      ..second = _$JsonConverterFromJson<int, DateTime>(
          json['second'], const DateSecondConverter().fromJson)
      ..year = _$JsonConverterFromJson<int, DateTime>(
          json['year'], const DateYearConverter().fromJson);

Map<String, dynamic> _$PersonToJson(Person instance) => <String, dynamic>{
      'age': const IntConverter().toJson(instance.age),
      'birth': const DateStringConverter().toJson(instance.birth),
      'day': _$JsonConverterToJson<int, DateTime>(
          instance.day, const DateDayConverter().toJson),
      'hour': _$JsonConverterToJson<int, DateTime>(
          instance.hour, const DateHourConverter().toJson),
      'microsecond': _$JsonConverterToJson<int, DateTime>(
          instance.microsecond, const DateMicroEpochConverter().toJson),
      'millisecond': _$JsonConverterToJson<int, DateTime>(
          instance.millisecond, const DateMilliEpochConverter().toJson),
      'minute': _$JsonConverterToJson<int, DateTime>(
          instance.minute, const DateMinuteConverter().toJson),
      'month': _$JsonConverterToJson<int, DateTime>(
          instance.month, const DateMonthConverter().toJson),
      'name': const StringConverter().toJson(instance.name),
      'second': _$JsonConverterToJson<int, DateTime>(
          instance.second, const DateSecondConverter().toJson),
      'year': _$JsonConverterToJson<int, DateTime>(
          instance.year, const DateYearConverter().toJson),
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
