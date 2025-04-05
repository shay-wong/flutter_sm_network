// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:dio/dio.dart';

import '../coverters/converter.dart';
import '../http.dart';
import '../log.dart';

/// 日志拦截器
class LogcatInterceptor extends Interceptor {
  LogcatInterceptor({
    this.maxWidth = 110,
    this.logRequest = const LogOptions(),
    this.logResponse = const LogOptions(),
    this.logError = const LogOptions(),
    HttpLog? log,
    ConverterOptions? converterOptions,
  })  : _log = log,
        _converterOptions = converterOptions;

  /// InitialTab count to logPrint json response
  static const _kInitialTab = 1;

  static const _separator = '\n';

  /// log error options
  final LogOptions logError;

  /// log request options
  final LogOptions logRequest;

  /// log response options
  final LogOptions logResponse;

  /// Width size per logPrint
  final int maxWidth;

  final ConverterOptions? _converterOptions;
  final HttpLog? _log;

  /// 日志处理
  final _sb = StringBuffer();

  /// 开始时间
  DateTime? _startTime;

  /// 转换选项
  ConverterOptions get converterOptions =>
      _converterOptions ?? Http.shared.options.converterOptions;

  /// 日志打印
  HttpLog get log => _log ?? Http.shared.options.log;

  /// 拷贝
  LogcatInterceptor copyWith({
    LogOptions? logRequest,
    LogOptions? logResponse,
    LogOptions? logError,
    int? maxWidth,
    ConverterOptions? converterOptions,
    HttpLog? log,
  }) {
    return LogcatInterceptor(
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
    if (!logError.enable) {
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
        code = const IntConverter().fromJson(data[converterOptions.code]);
        message = const StringConverter().fromJson(data[converterOptions.message]);
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

      if (logError.queryParameters && uri.queryParameters.isNotEmpty) {
        _toJson('Query Parameters', uri.queryParameters);
      }
      if (logError.headers && requestOptions.headers.isNotEmpty) {
        _toJson('Headers', requestOptions.headers);
      }
      if (logError.data && requestOptions.data != null) {
        _processData(requestOptions.data, requestOptions.headers['content-type']);
      }
      if (logError.extra && requestOptions.extra.isNotEmpty) {
        _toJson('Extra', requestOptions.extra);
      }
      if (logError.responseData && data != null) {
        _toJson('Response Data', data);
      }
      if (logError.curl) {
        _getCURL(requestOptions);
      }
      log.error(_processStringBuffer(), err.stackTrace);
    } catch (e) {
      log.error(e, StackTrace.current);
    }

    super.onError(err, handler);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!logRequest.enable) {
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

      if (logRequest.queryParameters && uri.queryParameters.isNotEmpty) {
        _toJson('Query Parameters', uri.queryParameters);
      }
      if (logRequest.headers && options.headers.isNotEmpty) {
        _toJson('Headers', options.headers);
      }
      if (logRequest.data && options.data != null) {
        _processData(options.data, options.headers['content-type']);
      }
      if (logRequest.extra && options.extra.isNotEmpty) {
        _toJson('Extra', options.extra);
      }
      if (logRequest.curl) {
        _getCURL(options);
      }
      log.debug(_processStringBuffer());
    } catch (e) {
      log.error(e, StackTrace.current);
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!logResponse.enable) {
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

      if (logResponse.queryParameters && uri.queryParameters.isNotEmpty) {
        _toJson('Query Parameters', uri.queryParameters);
      }
      if (logResponse.headers && requestOptions.headers.isNotEmpty) {
        _toJson('Headers', requestOptions.headers);
      }
      if (logResponse.data && requestOptions.data != null) {
        _processData(requestOptions.data, requestOptions.headers['content-type']);
      }
      if (logResponse.extra && requestOptions.extra.isNotEmpty) {
        _toJson('Extra', requestOptions.extra);
      }
      if (logResponse.responseData && response.data != null) {
        _toJson('Response Data', response.data);
      }

      if (logResponse.curl) {
        _getCURL(requestOptions);
      }
      log.debug(_processStringBuffer());
    } catch (e) {
      log.error(e, StackTrace.current);
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

  /// json
  String _jsonConverter(dynamic data, {bool isCurl = false}) {
    if (data is String) {
      try {
        data = jsonDecode(data);
      } catch (e) {
        return '${isCurl ? '' : _indent()}$data';
      }
    }
    var json = JsonEncoder.withIndent(_indent(isCurl ? 2 : 1)).convert(data);

    if (isCurl) {
      json = json.replaceRange(json.length - 1, null, '${_indent()}}');
    } else {
      json = json.splitMapJoin(
        '\n',
        onNonMatch: (line) => _indent() + line,
      );
    }

    return json;
  }

  Map<String, dynamic> _mergeListToMap(List<MapEntry<String, dynamic>> inputList) {
    return inputList.fold(
      {},
      (result, entry) {
        final key = entry.key;
        final value = entry.value;

        if (result.containsKey(key)) {
          if (result[key] is List) {
            (result[key] as List).add(value);
          } else {
            result[key] = [result[key], value];
          }
        } else {
          result[key] = value;
        }

        return result;
      },
    );
  }

  void _printLine([String pre = '', String suf = '╝']) {
    _sb.writeln('$pre${'═' * (maxWidth - pre.length)}$suf');
  }

  /// 处理 data
  void _processData(dynamic data, String? contentType, {bool isCurl = false}) {
    if (data != null) {
      if (data is FormData) {
        if (isCurl) {
          _sb
            ..writeAll(
              [
                ...data.fields.map(
                  (e) => '${_indent()}--form ${e.key}="${e.value}"',
                ),
                ...data.files.map(
                  (e) => '${_indent()}--form =@"${e.value.filename}"',
                ),
              ],
              _separator,
            )
            ..writeln();
        } else {
          final formDataMap = <String, dynamic>{}
            ..addAll(_mergeListToMap(data.fields))
            ..addEntries(data.files);
          _toJson('Form data', formDataMap);
        }
      } else if (contentType == Headers.formUrlEncodedContentType) {
        if (isCurl) {
          _sb
            ..writeAll(
              // ignore: avoid_dynamic_calls
              data.entries.map(
                (MapEntry e) {
                  return "${_indent()}--data-urlencode '${e.key}=${e.value}'";
                },
              ),
              _separator,
            )
            ..writeln();
        } else {
          _toJson('Form Urlencoded', data);
        }
      } else {
        if (isCurl) {
          data = _jsonConverter(data, isCurl: isCurl);
          _sb.writeln(
            "${_indent()}-d '$data'",
          );
        } else {
          _toJson('Request Data', data);
        }
      }
    }
  }

  String _processStringBuffer() {
    return _sb.toString().removeEnd(_separator);
  }

  /// LogPrint json
  void _toJson<T>(String name, T data, {bool isCurl = false}) {
    _printLine('╔ $name ', '╗');
    _sb.writeln(_jsonConverter(data, isCurl: isCurl));
    _printLine('╚');
  }
}

/// 打印配置
class LogOptions {
  const LogOptions({
    this.curl = true,
    this.data = true,
    this.extra = true,
    this.headers = true,
    this.queryParameters = true,
    this.responseData = true,
    this.enable = true,
  });

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
}

extension _StringExt on String {
  String removeEnd(String end) {
    if (endsWith(end)) {
      return substring(0, length - 1);
    }
    return this;
  }
}
