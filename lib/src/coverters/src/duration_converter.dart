// ignore_for_file: public_member_api_docs

import 'package:json_annotation/json_annotation.dart';

/// 时间转换
class SecondDurationConverter implements JsonConverter<Duration?, dynamic> {
  const SecondDurationConverter();

  @override
  Duration? fromJson(dynamic json) {
    if (json == null) {
      return null;
    }
    final duration = int.tryParse(json);

    if (duration == null) {
      return null;
    }
    return Duration(seconds: duration);
  }

  @override
  dynamic toJson(Duration? object) => object?.inSeconds;
}
