import 'package:dio/dio.dart';

import 'intercaptors/debug_locat_interceptor.dart';
import 'options.dart';

/// 请求头
typedef HTTPHeaders = Parameters;

/// 参数
typedef Parameters = Map<String, dynamic>;

/// 请求体
enum ContentType {
  /// 原始
  raw,

  /// json
  json,

  /// urlencoded
  urlencoded,

  /// multipart
  multipart;

  /// 获取 content-type
  String get value {
    switch (this) {
      case ContentType.raw:
        return Headers.textPlainContentType;
      case ContentType.json:
        return Headers.jsonContentType;
      case ContentType.urlencoded:
        return Headers.formUrlEncodedContentType;
      case ContentType.multipart:
        return Headers.multipartFormDataContentType;
    }
  }
}

/// http
class Http {
  /// 单例
  factory Http() => _instance;

  Http._();

  /// dio
  static late final Dio dio;

  static final _instance = Http._();

  /// 单例
  static Http get shared => _instance;

  late HttpBaseOptions _options;

  /// 配置
  HttpBaseOptions get options => _options;

  set options(HttpBaseOptions options) {
    _options = options;
    dio.options = options;
  }

  /// 请求配置
  void config({HttpBaseOptions? options, Iterable<Interceptor>? interceptors}) {
    dio = Dio();
    options ??= HttpBaseOptions();
    this.options = options;

    var contains = false;
    if (interceptors != null) {
      dio.interceptors.addAll(interceptors);
      contains = interceptors.any((element) => element is DebugLogcatInterceptor);
    }

    // 添加日志
    if (!contains && this.options.log.enable) {
      dio.interceptors.add(DebugLogcatInterceptor(log: options.log));
    }
  }
}

/// 请求方法， dio 内部会转成大写
// ignore: public_member_api_docs
enum Method { delete, get, head, patch, post, put, download, upload }
