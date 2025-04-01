import 'package:json_annotation/json_annotation.dart';

/// int 转换
class StringConverter implements JsonConverter<String?, dynamic> {
  // ignore: public_member_api_docs
  const StringConverter();

  @override
  String? fromJson(dynamic json) {
    if (json is String) {
      return json;
    }
    return json?.toString();
  }

  @override
  String? toJson(String? object) => object;
}
