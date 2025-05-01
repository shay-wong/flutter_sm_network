import 'package:dio/dio.dart';

import 'intercaptors/locat_interceptor.dart';
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

  static final _instance = Http._();

  /// dio
  static Dio get dio => _instance._dio;

  /// 单例
  static Http get shared => _instance;

  late final Dio _dio;

  late HttpBaseOptions _options;

  /// 配置
  HttpBaseOptions get options => _options;

  set options(HttpBaseOptions options) {
    _options = options;
    dio.options = options;
  }

  /// 请求配置
  void config({
    Dio? dio,
    HttpBaseOptions? options,
    Iterable<Interceptor>? interceptors,
  }) {
    _options = options ?? HttpBaseOptions();
    _dio = dio ?? Dio(_options);

    var logInterceptorIndex = -1;
    if (interceptors != null) {
      final inters = interceptors.toList();
      logInterceptorIndex = inters.lastIndexWhere((e) => e is LogcatInterceptor);
      if (logInterceptorIndex != -1) {
        final filtered = inters
            .asMap()
            .entries
            .where((entry) {
              final index = entry.key;
              final value = entry.value;
              return value is! LogcatInterceptor || index == logInterceptorIndex;
            })
            .map((e) => e.value)
            .toList();
        _dio.interceptors.addAll(filtered);
      }
    }

    // 添加日志
    if (_options.log.enable && logInterceptorIndex == -1) {
      _dio.interceptors.add(
        LogcatInterceptor(
          log: _options.log,
          converterOptions: _options.converterOptions,
        ),
      );
    }
  }
}

/// 请求方法， dio 内部会转成大写
// ignore: public_member_api_docs
enum Method { delete, get, head, patch, post, put, download, upload }
