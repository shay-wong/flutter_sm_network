import 'dart:convert';
import 'dart:typed_data' show Uint8List;

import 'package:dio/dio.dart';

import 'intercaptors/log_interceptor.dart';

/// 1 tab length
const _tabStep = '  ';

/// 打印调试信息
typedef HttpDebugLog = void Function(Object object);

/// 打印错误信息
typedef HttpErrorLog = void Function(Object error, StackTrace? stackTrace);

/// 网络打印信息
class HttpLog {
  // ignore: public_member_api_docs
  const HttpLog({
    this.options = const LogOptions(),
    this.captch = const LogCatchOptions(),
    this.debug = print,
    HttpErrorLog? error,
    this.tabStep = _tabStep,
    this.onRequest,
    this.onResponse,
    this.onError,
  }) : _error = error;

  /// 错误拦截打印配置
  /// 请查看 [LogCatchOptions]
  final LogCatchOptions captch;

  /// 打印调试信息
  final HttpDebugLog debug;

  /// 错误拦截
  final InterceptorErrorCallback? onError;

  /// 请求拦截
  final InterceptorSendCallback? onRequest;

  /// 响应拦截
  final InterceptorSuccessCallback? onResponse;

  /// 打印配置
  /// 针对全部打印, 单独配置请去以下配置
  /// 请查看 [HttpLogInterceptor.logRequest]、[HttpLogInterceptor.logResponse]、[HttpLogInterceptor.logError]
  final LogOptions options;

  /// 1 tab length
  final String tabStep;

  /// 打印错误信息
  final HttpErrorLog? _error;

  /// 打印错误信息
  void error(Object error, StackTrace? stackTrace) {
    if (_error != null) {
      _error.call(error, stackTrace);
    } else {
      // ignore: avoid_print
      print('$error\n$stackTrace');
    }
  }
}

/// 错误拦截打印
class LogCatchOptions {
  // ignore: public_member_api_docs
  const LogCatchOptions({
    this.error = false,
    this.exception = false,
    this.converter = false,
  });

  /// 是否打印 [Error] 的捕获
  final bool error;

  /// 是否打印 [DioException] 的捕获
  final bool exception;

  /// 是否打印 [Converter] 中错误的捕获
  final bool converter;
}

/// 打印配置
class LogOptions {
  /// 默认不允许打印
  const LogOptions({
    this.curl = false,
    this.data = false,
    this.extra = false,
    this.headers = false,
    this.queryParameters = false,
    this.responseData = false,
    this.enable = false,
    this.stream = false,
    this.bytes = false,
  });

  /// 允许打印
  LogOptions.allow({
    this.curl = true,
    this.data = true,
    this.extra = true,
    this.headers = true,
    this.queryParameters = true,
    this.responseData = true,
    this.enable = true,
    this.stream = true,
    this.bytes = true,
  });

  /// 是否打印格式为 [Uint8List] 的 [Response.data]
  /// 非 [ResponseType.bytes] 无效
  final bool bytes;

  /// 是否打印 curl
  final bool curl;

  /// 是否打印 [RequestOptions.data]
  final bool data;

  /// 是否允许打印
  final bool enable;

  /// 是否打印 [RequestOptions.extra]
  final bool extra;

  /// 是否打印 [RequestOptions.headers]
  final bool headers;

  /// 是否打印 [RequestOptions.queryParameters]
  final bool queryParameters;

  /// 是否打印 [Response.data]
  /// [Interceptor.onRequest] 无效
  final bool responseData;

  /// 是否打印格式为 [ResponseBody] 的 [Response.data]
  /// 非 [ResponseType.stream] 无效
  final bool stream;

  /// copyWith
  LogOptions copyWith({
    bool? curl,
    bool? data,
    bool? enable,
    bool? extra,
    bool? headers,
    bool? queryParameters,
    bool? responseData,
    bool? stream,
    bool? bytes,
  }) {
    return LogOptions(
      curl: curl ?? this.curl,
      data: data ?? this.data,
      enable: enable ?? this.enable,
      extra: extra ?? this.extra,
      headers: headers ?? this.headers,
      queryParameters: queryParameters ?? this.queryParameters,
      responseData: responseData ?? this.responseData,
      stream: stream ?? this.stream,
      bytes: bytes ?? this.bytes,
    );
  }
}
