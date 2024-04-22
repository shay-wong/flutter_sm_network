import 'package:json_annotation/json_annotation.dart';

class BoolConverter implements JsonConverter<bool, int> {
  const BoolConverter();

  @override
  bool fromJson(int json) => json == 0 ? false : true;

  @override
  int toJson(bool object) => object ? 1 : 0;
}
