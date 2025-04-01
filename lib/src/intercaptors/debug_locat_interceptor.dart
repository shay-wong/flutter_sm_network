import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../log.dart';

/// 日志拦截器
class DebugLogcatInterceptor extends Interceptor {
  /// Constructor
  DebugLogcatInterceptor({
    this.logQueryParameters = true,
    this.logHeaders = false,
    this.logExtra = false,
    this.log = const HttpLog(),
  });

  /// 是否打印请求参数
  final bool logQueryParameters;

  /// 是否打印请求头
  final bool logHeaders;

  /// 是否打印请求附加参数
  final bool logExtra;

  /// InitialTab count to logPrint json response
  static const _kInitialTab = 1;

  /// Width size per logPrint
  final maxWidth = 110;

  /// 日志打印
  final HttpLog log;

  /// 开始时间
  DateTime? _startTime;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final requestOptions = err.requestOptions;
    final dynamic method = requestOptions.method;
    final statusCode = err.response?.statusCode;
    final uri = requestOptions.uri;
    final dynamic data = err.response?.data;
    String? duration;
    int? prettyStatusCode;
    String? prettyMessage;

    try {
      if (_startTime != null) {
        duration = '${DateTime.now().difference(_startTime!).inMilliseconds}ms';
      }
      if (err.response != null) {
        if (data is Map<String, dynamic>) {
          prettyStatusCode = data['code'] as int?;
          prettyMessage = data['message'] as String?;
        } else {
          prettyStatusCode = err.response?.statusCode;
        }
      } else if (err.error != null) {
        if (err.error is SocketException) {
          prettyStatusCode = (err.error! as SocketException).osError?.errorCode;
          prettyMessage = (err.error! as SocketException).toString();
        } else {
          prettyMessage = err.error.toString();
        }
      }

      final line =
          '╔╣ DioError ║ $method ║ ${statusCode ?? prettyStatusCode ?? err.type} ║ ${err.response?.statusMessage} ║ $duration\n║ $uri\n${prettyMessage != null ? '║ $prettyMessage\n' : ''}';
      var log = line;
      log += _printLine('╚');

      if (logQueryParameters && uri.queryParameters.isNotEmpty) {
        log += '\n${_toJson('Query Parameters', uri.queryParameters)}';
      }
      if (logHeaders && requestOptions.headers.isNotEmpty) {
        log += '\n${_toJson('Headers', requestOptions.headers)}';
      }
      if (logExtra && requestOptions.extra.isNotEmpty) {
        log += '\n${_toJson('Extra', requestOptions.extra)}';
      }

      if (requestOptions.method != 'GET') {
        final data = requestOptions.data;
        if (data is Map) {
          log += '\n${_toJson('Request Body', data)}';
        } else if (data is FormData) {
          final formDataMap = <String, dynamic>{}
            ..addAll(_mergeListToMap(data.fields))
            ..addEntries(data.files);
          log += '\n${_toJson('Form data', formDataMap)}';
        }
      }
      if (data != null) {
        log += '\n${_toJson('Response Data', data)}';
      }
      if (!kReleaseMode) {
        log += '\n${_getCURL(requestOptions)}';
      }
      this.log.error(log, err.stackTrace);
    } catch (e) {
      log.error(e, StackTrace.current);
    }

    super.onError(err, handler);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    super.onRequest(options, handler);
    _startTime = DateTime.now();
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    super.onResponse(response, handler);

    final requestOptions = response.requestOptions;
    final method = requestOptions.method;
    final statusCode = response.statusCode;
    final statusMessage = response.statusMessage;
    final uri = requestOptions.uri;
    String? duration;

    try {
      if (_startTime != null) {
        duration = '${DateTime.now().difference(_startTime!).inMilliseconds}ms';
      }

      final line =
          '╔╣ Response ║ $method ║ $statusCode ║ $statusMessage ║ ${_startTime != null ? '${DateFormat('yyyy-MM-DD HH:mm:s SSS').format(_startTime!)}ms' : ''} ║ $duration\n║ $uri\n';
      var log = line;
      log += _printLine('╚');
      if (logQueryParameters && uri.queryParameters.isNotEmpty) {
        log += '\n${_toJson('Query Parameters', uri.queryParameters)}';
      }
      if (logHeaders && requestOptions.headers.isNotEmpty) {
        log += '\n${_toJson('Headers', requestOptions.headers)}';
      }
      if (logExtra && requestOptions.extra.isNotEmpty) {
        log += '\n${_toJson('Extra', requestOptions.extra)}';
      }
      if (requestOptions.method != 'GET') {
        final data = requestOptions.data;
        if (data is Map) {
          log += '\n${_toJson('Request Body', data)}';
        } else if (data is FormData) {
          final formDataMap = <String, dynamic>{}
            ..addAll(_mergeListToMap(data.fields))
            ..addEntries(data.files);
          log += '\n${_toJson('Form data', formDataMap)}';
        }
      }
      if (response.data != null) {
        log += '\n${_toJson('Response Data', response.data)}';
      }
      log += '\n${_getCURL(requestOptions)}';
      this.log.debug(log);
    } catch (e) {
      log.error(e, StackTrace.current);
    }
  }

  String _printLine([String pre = '', String suf = '╝']) =>
      '$pre${'═' * (maxWidth - pre.length)}$suf';

  /// LogPrint json
  String _toJson<T>(String name, T data) {
    var json = _printLine('╔ $name ', '╗');
    json +=
        '\n${JsonEncoder.withIndent(_indent(), (object) => object.toString()).convert(data).splitMapJoin('\n', onNonMatch: (line) => _indent() + line)}\n';
    json += _printLine('╚');
    return json;
  }

  String _indent([int tabCount = _kInitialTab]) => log.tabStep * tabCount;

  String _getCURL(RequestOptions options) {
    const separator = '\n';
    final sb = StringBuffer()
      ..writeAll(
        [
          _printLine('╔ CURL ', '╗'),
          "${_indent()}curl -X ${options.method} '${options.uri}'",
          ...options.headers.entries
              .where(
                (element) => element.key != 'Cookie',
              )
              .map(
                (e) => "${_indent()}-H '${e.key}: ${e.value}'",
              ),
        ],
        separator,
      )
      ..writeln();
    final data = options.data;
    if (data != null) {
      if (data is FormData) {
        sb
          ..writeAll(
            [
              ...data.fields.map(
                (e) => '${_indent()}--form ${e.key}="${e.value}"',
              ),
              ...data.files.map(
                (e) => '${_indent()}--form =@"${e.value.filename}"',
              ),
            ],
            separator,
          )
          ..writeln();
      } else if (options.headers['content-type'] == Headers.formUrlEncodedContentType) {
        sb
          ..writeAll(
            // ignore: avoid_dynamic_calls
            data.entries.map(
              (MapEntry e) {
                return '${_indent()}--data-urlencode "${e.key}=${e.value}"';
              },
            ),
            separator,
          )
          ..writeln();
      } else {
        var json = data;
        if (data is! String) {
          json = JsonEncoder.withIndent(_indent()).convert(data);
        }
        sb.writeln(
          "${_indent()}-d '$json'",
        );
      }
    }
    sb.write(_printLine('╚'));
    return sb.toString();
  }

  Map<String, dynamic> _mergeListToMap(List<MapEntry<String, dynamic>> inputList) =>
      inputList.fold({}, (result, entry) {
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
      });
}
