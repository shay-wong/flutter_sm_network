import 'package:json_annotation/json_annotation.dart';

class BoolConverter implements JsonConverter<bool, int> {
  const BoolConverter();

  @override
  bool fromJson(int json) {
    return json > 0 ? true : false;
  }

  @override
  int toJson(bool object) {
    return object ? 1 : 0;
  }
}
