import 'dart:convert';

import '../../../sm_network.dart';
import '../../extension.dart';

/// 基础模型
class BaseResp<T> {
  // ignore: public_member_api_docs
  BaseResp({
    this.code,
    this.data,
    Object? error,
    this.list,
    this.message,
    this.status,
  }) : rawError = error;

  /// 错误码
  int? code;

  /// 数据
  T? data;

  /// 列表
  List<T>? list;

  /// 消息
  String? message;

  /// 错误
  Object? rawError;

  /// 是否成功
  bool? status;

  /// 转成 [Error]
  Error? get error => rawError is Error ? rawError as Error? : null;

  /// 转成 [DioException]
  DioException? get dioException => rawError is DioException ? rawError as DioException? : null;

  /// 转成 [HttpError]
  HttpError? get httpError => rawError is HttpError ? rawError as HttpError? : null;

  /// 是否成功, 默认 code == 200 成功
  bool get isSuccess => status ?? code == 200;

  String get _jsonString {
    try {
      final json = toJson();
      if (data != null && data is ResponseBody) {
        // data 是 ResponseBody
        json['data'] = (data! as ResponseBody).toJson();
      } else {
        try {
          // 判断 data 是否可以转换成 json
          jsonEncode(data);
          // 可以转换直接赋值
          json['data'] = data;
        } catch (e) {
          // data 无法转换成 json， 转换成字符串
          json['data'] = data?.toString();
        }
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
        'error': error,
      };

  @override
  String toString() => _jsonString;
}
