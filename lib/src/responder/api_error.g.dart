// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_error.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

APIError _$APIErrorFromJson(Map<String, dynamic> json) => APIError(
      code: json['code'] as num?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$APIErrorToJson(APIError instance) => <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
    };
