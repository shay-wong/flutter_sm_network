import 'dart:convert';

import '../../../sm_network.dart';
import '../../extension.dart';

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

  String get _jsonString {
    try {
      final json = toJson();
      if (data != null && data is ResponseBody) {
        json['data'] = (data! as ResponseBody).toJson();
      } else {
        json['data'] = data.toString();
      }
      return JsonEncoder.withIndent(
        Http.shared.options.log.tabStep,
      ).convert(json);
    } catch (e) {
      return toJson().toString();
    }
  }

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
