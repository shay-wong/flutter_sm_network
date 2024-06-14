import 'package:dio/dio.dart';

import '../core/api_config.dart';
import '../core/api_core.dart';

mixin APIOptions {
  /// 请求体格式
  BodyFormat? get bodyFormat => null;

  /// 全局配置
  APIConfig get config => APICore.config;

  /// Content-Type
  String? get contentType => null;

  /// 请求体 默认 null
  Object? get data => null;

  /// 额外参数
  Parameters? get extra => null;

  /// 跟随重定向
  bool? get followRedirects => null;

  /// 请求头 默认 null
  HTTPHeader? get headers => null;

  /// 数组格式
  ListFormat? get listFormat => null;

  /// 最大重定向次数
  int? get maxRedirects => null;

  /// 请求方式 默认 GET
  HTTPMethod get method => config.method ?? HTTPMethod.GET;

  /// 请求配置
  Options? get options {
    Parameters? effectiveHeaders = headers;
    if (config.ensureNonNullHeadersFields) {
      effectiveHeaders = effectiveHeaders
        ?..removeWhere((key, value) => value == null);
    }
    // 请求配置
    return Options(
      method: method.name,
      sendTimeout: sendTimeout,
      receiveTimeout: receiveTimeout,
      extra: extra,
      headers: effectiveHeaders,
      preserveHeaderCase: preserveHeaderCase,
      responseType: responseType,
      contentType: contentType,
      validateStatus: validateStatus,
      receiveDataWhenStatusError: receiveDataWhenStatusError,
      followRedirects: followRedirects,
      maxRedirects: maxRedirects,
      persistentConnection: persistentConnection,
      requestEncoder: requestEncoder,
      responseDecoder: responseDecoder,
      listFormat: listFormat,
    );
  }

  /// 请求参数 默认 null
  Parameters? get parameters => null;

  /// 请求路径 默认 null
  String get path => '';

  /// 持久化连接
  bool? get persistentConnection => null;

  /// 跟随主域名后面的前缀
  String get prefixPath => config.prefixPath;

  /// 保留 Header 大小写
  bool? get preserveHeaderCase => null;

  /// 状态错误时是否接收数据
  bool? get receiveDataWhenStatusError => null;

  /// 接收超时时间
  Duration? get receiveTimeout => null;

  /// 请求编码
  RequestEncoder? get requestEncoder => null;

  /// 响应解码
  ResponseDecoder? get responseDecoder => null;

  /// 响应类型
  ResponseType? get responseType => null;

  /// 发送超时时间
  Duration? get sendTimeout => null;

  /// 跟随主域名后面的后缀
  String get suffixPath => config.suffixPath;

  /// 请求 [url], 由 [prefixPath]、[path] 和 [suffixPath] 组成
  String get url => prefixPath + path + suffixPath;

  /// 是否将 [parameters] 转成 [data] 放入 Request Body 中，默认不放入请求体中
  bool get useBody => false;

  /// 请求状态校验
  ValidateStatus? get validateStatus => null;
}

mixin APIParseMixin<T> {
  /// [json] 转换函数
  ParseJsonT<T> get parseJson => fromJson;

  /// 将 [json] 转换为对应的 [T] 类型
  T fromJson(dynamic json) => json as T;
}
