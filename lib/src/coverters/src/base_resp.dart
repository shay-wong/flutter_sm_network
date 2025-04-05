import 'dart:convert';

import '../../http.dart';

/// 基础模型
class BaseResp<T> {
  // ignore: public_member_api_docs
  BaseResp({
    this.code,
    this.data,
    this.list,
    this.message,
    this.status,
  });

  /// 错误码
  int? code;

  /// 数据
  T? data;

  /// 列表
  List<T>? list;

  /// 消息
  String? message;

  /// 是否成功
  bool? status;

  /// 是否成功, 默认 code == 200 成功
  bool get isSuccess => status ?? code == 200;

  String get _jsonString => JsonEncoder.withIndent(
        Http.shared.options.log.tabStep,
      ).convert(
        toJson(),
      );

  // ignore: public_member_api_docs
  Map<String, dynamic> toJson() => <String, dynamic>{
        'code': code,
        'data': data,
        'list': list,
        'message': message,
        'status': status,
      };

  @override
  String toString() => _jsonString;
}
