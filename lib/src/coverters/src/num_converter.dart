import 'package:json_annotation/json_annotation.dart';

/// int 转换
class IntConverter implements JsonConverter<int?, dynamic> {
  // ignore: public_member_api_docs
  const IntConverter();

  @override
  int? fromJson(dynamic json) => int.tryParse(json.toString());

  @override
  int? toJson(int? object) => object;
}
