import 'dart:convert';

import '../core/api_config.dart';
import 'api_error.dart';

class _APIBaseModel<T> extends APIResponder<T> {
  _APIBaseModel({
    super.code,
    super.data,
    super.dataList,
    super.extra,
    super.message,
    super.success,
  });

  factory _APIBaseModel.fromJson(
    Map<String, dynamic> json, {
    FromJsonT<T>? fromJsonT,
    ParseJsonT<T>? parseJsonT,
  }) {
    T? data;
    List<T>? dataList;
    final temp = json['data'];
    if (temp is List) {
      dataList = temp.map(
        (e) {
          if (parseJsonT != null && e != null && e is Parameters) {
            return parseJsonT(e);
          }
          if (fromJsonT != null && e != null) {
            return fromJsonT(e);
          }
          return e as T;
        },
      ).toList();
    } else if (temp is Parameters && parseJsonT != null) {
      data = parseJsonT(temp);
    } else if (temp is Map && fromJsonT != null) {
      data = fromJsonT(temp);
    } else {
      data = temp as T?;
    }
    return _APIBaseModel<T>(
      code: json['code'] as int?,
      data: data,
      dataList: dataList,
      extra: json['extra'] as String?,
      message: json['message'] as String?,
      success: json['success'] as bool?,
    );
  }

  static const String _indent = '    ';

  @override
  Map<String, dynamic> toJson([
    ToJsonT<T>? toJsonT,
  ]) {
    return <String, dynamic>{
      'code': code,
      'data': toJsonT != null ? toJsonT(data) : data,
      'dataList': toJsonT != null
          ? dataList?.map((e) => toJsonT(e)).toList()
          : dataList,
      'extra': extra,
      'message': message,
      'success': success,
    };
  }

  @override
  String toString() => 'APIResponder($_jsonString)';

  String get _jsonString => const JsonEncoder.withIndent(_indent).convert({
        'code': code,
        'data': data,
        'dataList': dataList,
        'extra': extra,
        'message': message,
        'success': success,
      });
}

abstract class APIResponder<T> {
  APIResponder({
    this.success,
    this.code,
    this.message,
    this.data,
    this.dataList,
    this.extra,
  });

  factory APIResponder.fromJson(
    Map<String, dynamic> json, {
    FromJsonT<T>? fromJsonT,
    ParseJsonT<T>? parseJsonT,
  }) = _APIBaseModel.fromJson;

  int? code;
  T? data;
  List<T>? dataList;
  String? extra;
  String? message;
  bool? success;

  APIError? get error {
    return isSuccess
        ? null
        : APIError(
            code: code,
            message: message?.isNotEmpty == true ? message : '接口请求错误',
          );
  }

  bool get isSuccess => success ?? false;

  Map<String, dynamic> toJson([
    ToJsonT<T>? toJsonT,
  ]) =>
      throw UnimplementedError();
}
