import 'api_error.dart';

class APIResponder<T> {
  bool? success;
  int? code;
  String? message;
  String? shortSysInfo;
  T? data;
  String? extra;

  APIError? get error {
    return isSuccess
        ? null
        : APIError(
            code: code,
            message: shortSysInfo?.isNotEmpty == true
                ? shortSysInfo
                : message?.isNotEmpty == true
                    ? message
                    : '接口请求错误');
  }

  bool get isSuccess => success ?? false;

  APIResponder({
    this.success,
    this.code,
    this.message,
    this.shortSysInfo,
    this.data,
    this.extra,
  });

  factory APIResponder.fromJson(Map<String, dynamic> json, T Function(dynamic json) fromJsonT) => APIResponder<T>(
        success: json['success'] as bool?,
        code: json['code'] as int?,
        message: json['message'] as String?,
        shortSysInfo: json['shortSysInfo'] as String?,
        data: json['data'] == null ? null : fromJsonT(json['data']),
        extra: json['extra'] as String?,
      );

  Map<String, dynamic> toJson(Map<String, dynamic>? Function(T? value) toJsonT) => <String, dynamic>{
        'success': success,
        'code': code,
        'message': message,
        'shortSysInfo': shortSysInfo,
        'data': data == null ? null : toJsonT(data),
        'extra': extra,
      };
}
