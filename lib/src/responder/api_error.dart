// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:json_annotation/json_annotation.dart';
import 'package:sm_models/sm_models.dart';

part 'api_error.g.dart';

@JsonSerializable()
class APIError extends MError {
  APIError({
    super.code,
    super.message,
  });

  APIError.error({
    super.code,
    super.message,
  });

  factory APIError.fromJson(Map<String, dynamic> json) =>
      _$APIErrorFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$APIErrorToJson(this);

  APIError copyWith({
    int? code,
    String? message,
  }) {
    return APIError(
      code: code ?? this.code,
      message: message ?? this.message,
    );
  }

  APIError mergeWith({
    int? code,
    String? message,
  }) {
    return APIError(
      code: this.code ?? code,
      message: this.message ?? message,
    );
  }
}
