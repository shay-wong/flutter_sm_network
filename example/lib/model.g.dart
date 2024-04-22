// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Person _$PersonFromJson(Map<String, dynamic> json) => Person(
      json['age'] as num?,
      json['gender'] as String?,
      json['name'] as String?,
      (json['friends'] as List<dynamic>?)
          ?.map((e) => Person.fromJson(e as Map<String, dynamic>))
          .toList(),
      _$JsonConverterFromJson<String, DateTime?>(
          json['birthday'], const StringDateTimeConverter().fromJson),
      _$JsonConverterFromJson<int, DateTime>(
          json['adulthood'], const MilliEpochDateTimeConverter().fromJson),
    )..isStudent = _$JsonConverterFromJson<int, bool>(
        json['student'], const BoolConverter().fromJson);

Map<String, dynamic> _$PersonToJson(Person instance) => <String, dynamic>{
      'age': instance.age,
      'birthday': const StringDateTimeConverter().toJson(instance.birthday),
      'friends': instance.friends,
      'gender': instance.gender,
      'student': _$JsonConverterToJson<int, bool>(
          instance.isStudent, const BoolConverter().toJson),
      'name': instance.name,
      'adulthood': _$JsonConverterToJson<int, DateTime>(
          instance.adulthood, const MilliEpochDateTimeConverter().toJson),
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
