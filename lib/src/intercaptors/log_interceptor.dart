// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../coverters/converter.dart';
import '../extension.dart';
import '../http.dart';
import '../log.dart';
import '../utils.dart';

part '_warpper_mixin.dart';

/// 日志拦截器
class HttpLogInterceptor extends Interceptor with _InterceptorWrapperMixin {
  /// 网络请求日志拦截器
  ///
  /// [maxWidth] 日志打印最大宽度
  ///
  /// 请查看 [HttpLog] 和 [LogOptions] 日志配置
  /// - [log] 全局日志配置
  /// - [logRequest] 请求日志配置
  /// - [logResponse] 响应日志配置
  /// - [logError] 错误日志配置
  ///
  /// [ConverterOptions] 转换选项
  ///
  /// [onRequest]、[onResponse]、[onError] 会拦截打印，可以在其中添加自己的打印逻辑
  HttpLogInterceptor({
    this.maxWidth = 110,
    LogOptions? logRequest,
    LogOptions? logResponse,
    LogOptions? logError,
    HttpLog? log,
    ConverterOptions? converterOptions,
    InterceptorSendCallback? onRequest,
    InterceptorSuccessCallback? onResponse,
    InterceptorErrorCallback? onError,
  })  : _log = log,
        _logRequest = logRequest,
        _logResponse = logResponse,
        _logError = logError,
        _converterOptions = converterOptions,
        __onRequest = onRequest,
        __onResponse = onResponse,
        __onError = onError;

  /// Size in which the Uint8List will be split
  static const chunkSize = 25;

  /// InitialTab count to logPrint json response
  static const _kInitialTab = 1;

  static const _separator = '\n';

  /// Width size per logPrint
  final int maxWidth;

  final InterceptorErrorCallback? __onError;
  final InterceptorSendCallback? __onRequest;
  final InterceptorSuccessCallback? __onResponse;
  final ConverterOptions? _converterOptions;
  final HttpLog? _log;
  final LogOptions? _logError;
  final LogOptions? _logRequest;
  final LogOptions? _logResponse;

  /// 日志处理
  final _sb = StringBuffer();

  /// 开始时间
  DateTime? _startTime;

  /// 转换选项
  ConverterOptions get converterOptions =>
      _converterOptions ?? Http.shared.options.converterOptions;

  /// 日志打印
  HttpLog get log => _log ?? Http.shared.options.log;

  /// log error options
  LogOptions get logError => _logError ?? log.options;

  /// log request options
  LogOptions get logRequest => _logRequest ?? log.options;

  /// log response options
  LogOptions get logResponse => _logResponse ?? log.options;

  @override
  InterceptorErrorCallback? get _onError => __onError ?? log.onError;

  @override
  InterceptorSendCallback? get _onRequest => __onRequest ?? log.onRequest;

  @override
  InterceptorSuccessCallback? get _onResponse => __onResponse ?? log.onResponse;

  /// 拷贝
  HttpLogInterceptor copyWith({
    LogOptions? logRequest,
    LogOptions? logResponse,
    LogOptions? logError,
    int? maxWidth,
    ConverterOptions? converterOptions,
    HttpLog? log,
  }) {
    return HttpLogInterceptor(
      logRequest: logRequest ?? this.logRequest,
      logResponse: logResponse ?? this.logResponse,
      logError: logError ?? this.logError,
      maxWidth: maxWidth ?? this.maxWidth,
      converterOptions: _converterOptions ?? _converterOptions,
      log: _log ?? _log,
    );
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!logError.enable || _onError != null) {
      super.onError(err, handler);
      return;
    }

    try {
      // 清除
      _sb.clear();

      final requestOptions = err.requestOptions;
      final dynamic method = requestOptions.method;
      final statusCode = err.response?.statusCode;
      final statusMessage = err.response?.statusMessage;
      final uri = requestOptions.uri;
      final dynamic data = err.response?.data;
      final error = err.error;

      String? time;
      String? duration;
      int? code;
      String? message;

      if (_startTime != null) {
        time = _formatTime(_startTime!);
        duration = '${DateTime.now().difference(_startTime!).inMilliseconds}ms';
      }
      if (data is Map<String, dynamic>) {
        code = const IntConverter().fromJson(data.getNestedValue(converterOptions.code));
        message = const StringConverter().fromJson(data.getNestedValue(converterOptions.message));
      } else {
        code = statusCode;
        message = statusMessage;
      }
      if (statusCode != null) {
        code = statusCode;
      }
      if (statusMessage != null && statusMessage.isNotEmpty) {
        message = statusMessage;
      }
      if (err.message != null) {
        message = err.message;
      }
      if (error != null) {
        message = error.toString();
      }

      _sb
        ..writeAll(
          [
            '╔╣ DioError',
            method,
            statusCode ?? code ?? err.type,
            if (time != null) time,
            if (duration != null) duration,
            uri,
          ],
          ' ║ ',
        )
        ..writeln();

      if (message != null) {
        message = message.removeEnd(_separator).splitMapJoin(
              '\n',
              onNonMatch: (line) => '║ $line',
            );
        _sb.writeln(message);
      }

      _printLine('╚');

      _logPrint(logError, requestOptions, response: err.response, stackTrace: err.stackTrace);
    } catch (e) {
      log.error(e, e is Error ? e.stackTrace : StackTrace.current);
    }

    super.onError(err, handler);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!logRequest.enable || _onRequest != null) {
      super.onRequest(options, handler);
      return;
    }
    try {
      // 清除
      _sb.clear();

      // 记录开始时间
      _startTime = DateTime.now();

      final method = options.method;
      final uri = options.uri;

      _sb
        ..writeAll(
          [
            '╔╣ Request',
            method,
            _formatTime(_startTime!),
          ],
          ' ║ ',
        )
        ..writeln()
        ..writeln('║ $uri');

      _printLine('╚');

      _logPrint(logRequest, options);
    } catch (e) {
      log.error(e, e is Error ? e.stackTrace : StackTrace.current);
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!logResponse.enable || _onResponse != null) {
      super.onResponse(response, handler);
      return;
    }
    try {
      // 清除
      _sb.clear();
      final requestOptions = response.requestOptions;
      final method = requestOptions.method;
      final statusCode = response.statusCode;
      final statusMessage = response.statusMessage;
      final uri = requestOptions.uri;
      final time = _formatTime(DateTime.now());
      String? duration;

      if (_startTime != null) {
        duration = '${DateTime.now().difference(_startTime!).inMilliseconds}ms';
      }

      _sb
        ..writeAll(
          [
            '╔╣ Response',
            method,
            if (statusCode != null) statusCode,
            if (statusMessage != null && statusMessage.isNotEmpty) statusMessage,
            time,
            if (duration != null) duration,
          ],
          ' ║ ',
        )
        ..writeln()
        ..writeln('║ $uri');

      _printLine('╚');

      _logPrint(logResponse, requestOptions, response: response);
    } catch (e) {
      log.error(e, e is Error ? e.stackTrace : StackTrace.current);
    }

    super.onResponse(response, handler);
  }

  String _formatTime(DateTime time) {
    final year = time.year;
    final month = time.month.toString().padLeft(2, '0');
    final day = time.day.toString().padLeft(2, '0');
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final second = time.second.toString().padLeft(2, '0');
    final millisecond = time.millisecond.toString().padLeft(3, '0');
    return '$year-$month-$day $hour:$minute:$second ${millisecond}ms';
  }

  void _getCURL(RequestOptions options) {
    _printLine('╔ CURL ', '╗');
    _sb
      ..writeAll(
        [
          "${_indent()}curl -X ${options.method} '${options.uri}'",
          ...options.headers.entries
              .where(
                (element) => element.key != 'Cookie',
              )
              .map(
                (e) => "${_indent()}-H '${e.key}: ${e.value}'",
              ),
        ],
        _separator,
      )
      ..writeln();
    _processData(options.data, options.headers['content-type'], isCurl: true);
    _printLine('╚');
  }

  String _indent([int tabCount = _kInitialTab]) => log.tabStep * tabCount;

  void _logPrint(
    LogOptions logOptions,
    RequestOptions options, {
    Response? response,
    StackTrace? stackTrace,
  }) {
    final uri = options.uri;
    if (logOptions.queryParameters && uri.queryParameters.isNotEmpty) {
      _toJson('Query Parameters', uri.queryParameters);
    }
    if (logOptions.headers && options.headers.isNotEmpty) {
      _toJson('Headers', options.headers);
    }
    if (logOptions.data && options.data != null) {
      _processData(options.data, options.headers['content-type']);
    }
    if (logOptions.extra && options.extra.isNotEmpty) {
      _toJson('Extra', options.extra);
    }
    if (logOptions.responseData && response?.data != null) {
      _toJson(
        'Response Data',
        response?.data,
        isStream: options.responseType == ResponseType.stream,
        isBytes: options.responseType == ResponseType.bytes,
      );
    }
    if (logOptions.curl) {
      _getCURL(options);
    }
    if (stackTrace == null) {
      log.debug(_processStringBuffer());
    } else {
      log.error(_processStringBuffer(), stackTrace);
    }
  }

  void _printLine([String pre = '', String suf = '╝']) {
    _sb.writeln('$pre${'═' * (maxWidth - pre.length)}$suf');
  }

  /// 处理 data
  void _processData(dynamic data, String? contentType, {bool isCurl = false}) {
    final result = Utils.shared.processLogRequestData(
      data,
      ContentType.tryParse(contentType),
      _indent,
      isCurl: isCurl,
    );
    if (result != null) {
      final item1 = result.item1;
      final title = result.item2;
      if (isCurl) {
        if (item1 is Iterable<dynamic>) {
          _sb
            ..writeAll(
              item1,
              _separator,
            )
            ..writeln();
        } else {
          _sb.writeln(
            "${_indent()}-d '$item1'",
          );
        }
      } else {
        _toJson(
          title ?? 'Request Data',
          item1,
        );
      }
    }
  }

  String _processStringBuffer() {
    return _sb.toString().removeEnd(_separator);
  }

  /// Process Uint8List
  void _processUint8List(Uint8List list) {
    final chunks = [];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(
        list.sublist(i, i + chunkSize > list.length ? list.length : i + chunkSize),
      );
    }
    for (final element in chunks) {
      // ignore: avoid_dynamic_calls
      _sb.writeln('${_indent()}${element.join(", ")},');
    }
  }

  /// LogPrint json
  void _toJson<T>(
    String name,
    T data, {
    bool isCurl = false,
    bool isStream = false,
    bool isBytes = false,
  }) {
    _printLine('╔ $name ', '╗');
    try {
      if (isStream && data is ResponseBody) {
        _sb.writeln(
          Utils.shared.jsonConverter(
            data.toJson(),
            indent: _indent,
          ),
        );
      } else if (isBytes && data is Uint8List) {
        _processUint8List(data);
      } else {
        _sb.writeln(
          Utils.shared.jsonConverter(
            data,
            isCurl: isCurl,
            indent: _indent,
          ),
        );
      }
    } catch (e) {
      _sb.writeln('${isCurl ? '' : _indent()}$data');
    }
    _printLine('╚');
  }
}
