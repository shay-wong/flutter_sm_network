import 'package:json_annotation/json_annotation.dart';

/// bool 转换器
class BoolConverter implements JsonConverter<bool, dynamic> {
  /// Constructor
  const BoolConverter();

  @override
  bool fromJson(dynamic json) {
    if (json is bool) {
      return json;
    }
    if (json is int || json is double) {
      return json == 1;
    }
    if (json is String) {
      return json == '1' || json == 'true';
    }
    return false;
  }

  @override
  bool toJson(bool object) => object;
}
