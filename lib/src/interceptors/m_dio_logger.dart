import 'dart:math' as math;
import 'dart:typed_data';

import 'package:dio/dio.dart';

/*修改自 PetterDioLogger*/
class MDioLogger extends Interceptor {
  MDioLogger({
    this.request = true,
    this.requestHeader = false,
    this.requestBody = false,
    this.responseHeader = false,
    this.responseBody = true,
    this.error = true,
    this.maxWidth = 90,
    this.compact = true,
    this.logPrint = print,
  });

  /// Size in which the Uint8List will be splitted
  static const int chunkSize = 20;

  /// InitialTab count to logPrint json response
  static const int kInitialTab = 1;

  /// 1 tab length
  static const String tabStep = '    ';

  final List<String> logs = [];

  /// Print compact json response
  final bool compact;

  /// Print error message
  final bool error;

  /// Log printer; defaults logPrint log to console.
  /// In flutter, you'd better use debugPrint.
  /// you can also write log in a file.
  final void Function(Object object) logPrint;

  /// Width size per logPrint
  final int maxWidth;

  /// Print request [Options]
  final bool request;

  /// Print request data [Options.data]
  final bool requestBody;

  /// Print request header [Options.headers]
  final bool requestHeader;

  /// Print [Response.data]
  final bool responseBody;

  /// Print [Response.headers]
  final bool responseHeader;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (error) {
      if (err.type == DioExceptionType.badResponse) {
        final uri = err.response?.requestOptions.uri;
        _printBoxed(
            header: 'DioError ║ Status: ${err.response?.statusCode} ${err.response?.statusMessage}',
            text: uri.toString());
        if (err.response != null && err.response?.data != null) {
          logs.add('╔ ${err.type.toString()}');
          _printResponse(err.response!);
        }
        _printLine('╚');
        logs.add('');
      } else {
        _printBoxed(header: 'DioError ║ ${err.type}', text: err.message);
      }
    }

    if (logs.isNotEmpty) {
      logPrint(logs.join('\n'));
    }
    super.onError(err, handler);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (request) {
      _printRequestHeader(options);
    }
    if (requestHeader) {
      _printMapAsTable(options.queryParameters, header: 'Query Parameters');
      final requestHeaders = <String, dynamic>{};
      requestHeaders.addAll(options.headers);
      requestHeaders['contentType'] = options.contentType?.toString();
      requestHeaders['responseType'] = options.responseType.toString();
      requestHeaders['followRedirects'] = options.followRedirects;
      requestHeaders['connectTimeout'] = options.connectTimeout?.toString();
      requestHeaders['receiveTimeout'] = options.receiveTimeout?.toString();
      _printMapAsTable(requestHeaders, header: 'Headers');
      _printMapAsTable(options.extra, header: 'Extras');
    }
    if (requestBody && options.method != 'GET') {
      final dynamic data = options.data;
      if (data != null) {
        if (data is Map) _printMapAsTable(options.data as Map?, header: 'Body');
        if (data is FormData) {
          final formDataMap = <String, dynamic>{}
            ..addAll(_mergeListToMap(data.fields))
            ..addEntries(data.files);
          _printMapAsTable(formDataMap, header: 'Form data | ${data.boundary}');
        } else {
          _printBlock(data.toString());
        }
      }
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _printResponseHeader(response);
    if (responseHeader) {
      final responseHeaders = <String, String>{};
      response.headers.forEach((k, list) => responseHeaders[k] = list.toString());
      _printMapAsTable(responseHeaders, header: 'Headers');
    }

    if (responseBody) {
      _printLine('╔ Body ', '╗');
      _printResponse(response);
      _printLine('╚');
    }

    if (logs.isNotEmpty) {
      logPrint(logs.join('\n'));
    }

    super.onResponse(response, handler);
  }

  bool _canFlattenList(List list) {
    return list.length < 10 && list.toString().length < maxWidth;
  }

  bool _canFlattenMap(Map map) {
    return map.values.where((dynamic val) => val is Map || val is List).isEmpty && map.toString().length < maxWidth;
  }

  String _flattenList(List list) {
    String listString = '[';

    list.asMap().forEach((i, dynamic e) {
      final isLast = i == list.length - 1;
      if (e is String) {
        e = '"${e.toString().replaceAll(RegExp(r'([\r\n])+'), " ")}"';
      }
      if (e is Map) {
        e = _flattenMap(e);
      } else if (e is List) {
        e = _flattenList(e);
      } else {
        e = e.toString().replaceAll('\n', '');
      }
      listString += '$e${isLast ? '' : ', '}';
    });

    listString += ']';

    return listString;
  }

  String _flattenMap(Map map) {
    String mapString = '{';
    map.keys.toList().asMap().forEach((index, dynamic key) {
      final isLast = index == map.length - 1;
      dynamic value = map[key];
      if (value is String) {
        value = '"${value.toString().replaceAll(RegExp(r'([\r\n])+'), " ")}"';
      }
      if (value is Map) {
        value = _flattenMap(value);
      } else if (value is List) {
        value = _flattenList(value);
      } else {
        value = value.toString().replaceAll('\n', '');
      }
      mapString += '"$key": $value${isLast ? '' : ', '}';
    });
    mapString += '}';
    return mapString;
  }

  String _indent([int tabCount = kInitialTab]) => tabStep * tabCount;

  Map<String, dynamic> _mergeListToMap(List<MapEntry<String, dynamic>> inputList) {
    return inputList.fold({}, (Map<String, dynamic> result, entry) {
      final key = entry.key;
      final value = entry.value;

      if (result.containsKey(key)) {
        if (result[key] is List) {
          result[key].add(value);
        } else {
          result[key] = [result[key], value];
        }
      } else {
        result[key] = value;
      }

      return result;
    });
  }

  void _printBlock(String msg) {
    final lines = (msg.length / maxWidth).ceil();
    for (var i = 0; i < lines; ++i) {
      logs.add((i >= 0 ? '║ ' : '') + msg.substring(i * maxWidth, math.min<int>(i * maxWidth + maxWidth, msg.length)));
    }
  }

  void _printBoxed({String? header, String? text}) {
    logs.addAll(['', '╔╣ $header', '║  $text']);
    _printLine('╚');
  }

  void _printKV(String? key, Object? v) {
    final pre = '╟ $key: ';
    final msg = v.toString();

    // TODO: 自动换行
    // if (pre.length + msg.length > maxWidth) {
    //   logPrint(pre);
    //   _printBlock(msg);
    // } else {
    logs.add('$pre$msg');
    // }
  }

  void _printLine([String pre = '', String suf = '╝']) => logs.add('$pre${'═' * (maxWidth - pre.length)}$suf');

  void _printList(List list, {int tabs = kInitialTab}) {
    list.asMap().forEach((i, dynamic e) {
      final isLast = i == list.length - 1;
      if (e is String) {
        e = '"${e.toString().replaceAll(RegExp(r'([\r\n])+'), " ")}"';
      }
      if (e is Map) {
        if (compact && _canFlattenMap(e)) {
          logs.add('${_indent(tabs)}  ${_flattenMap(e)}${!isLast ? ',' : ''}');
        } else {
          _printPrettyMap(e, initialTab: tabs + 1, isListItem: true, isLast: isLast);
        }
      } else if (e is List) {
        if (compact && _canFlattenList(e)) {
          logs.add('${_indent(tabs)}  ${_flattenList(e)}${!isLast ? ',' : ''}');
        } else {
          logs.add('${_indent()}[');
          _printList(e);
          logs.add('${_indent()}]');
        }
      } else {
        logs.add('${_indent(tabs + 2)} $e${isLast ? '' : ','}');
      }
    });
  }

  void _printMapAsTable(Map? map, {String? header}) {
    if (map == null || map.isEmpty) return;
    logs.add('╔ $header ');
    map.forEach((dynamic key, dynamic value) => _printKV(key.toString(), value));
    _printLine('╚');
  }

  void _printPrettyMap(
    Map data, {
    int initialTab = kInitialTab,
    bool isListItem = false,
    bool isLast = false,
  }) {
    var tabs = initialTab;
    final isRoot = tabs == kInitialTab;
    final initialIndent = _indent(tabs);
    tabs++;

    if (isRoot || isListItem) {
      logs.add('$initialIndent{');
    }

    data.keys.toList().asMap().forEach((index, dynamic key) {
      final isLast = index == data.length - 1;
      dynamic value = data[key];
      if (value is String) {
        value = '"${value.toString().replaceAll(RegExp(r'([\r\n])+'), " ")}"';
      }
      if (value is Map) {
        if (compact && _canFlattenMap(value)) {
          logs.add('${_indent(tabs)} "$key": ${_flattenMap(value)}${!isLast ? ',' : ''}');
        } else {
          logs.add('${_indent(tabs)} "$key": {');
          _printPrettyMap(value, initialTab: tabs);
        }
      } else if (value is List) {
        if (compact && _canFlattenList(value)) {
          logs.add('${_indent(tabs)} "$key": ${_flattenList(value)}${!isLast ? ',' : ''}');
        } else {
          logs.add('${_indent(tabs)} "$key": [');
          _printList(value, tabs: tabs);
          logs.add('${_indent(tabs)} ]${isLast ? '' : ','}');
        }
      } else {
        final msg = value.toString().replaceAll('\n', '');
        // TODO: 自动换行
        // final indent = _indent(tabs);
        // final linWidth = maxWidth - indent.length;
        // if (msg.length + indent.length > linWidth) {
        //   final lines = (msg.length / linWidth).ceil();
        //   for (var i = 0; i < lines; ++i) {
        //     logPrint(
        //         '${_indent(tabs)} ${msg.substring(i * linWidth, math.min<int>(i * linWidth + linWidth, msg.length))}');
        //   }
        // } else {
        logs.add('${_indent(tabs)} "$key": $msg${!isLast ? ',' : ''}');
        // }
      }
    });

    logs.add('$initialIndent}${isListItem && !isLast ? ',' : ''}');
  }

  void _printRequestHeader(RequestOptions options) {
    final uri = options.uri;
    final method = options.method;
    _printBoxed(header: 'Request ║ $method ', text: uri.toString());
  }

  void _printResponse(Response response) {
    if (response.data != null) {
      if (response.data is Map) {
        _printPrettyMap(response.data as Map);
      } else if (response.data is Uint8List) {
        logs.add('${_indent()}[');
        _printUint8List(response.data as Uint8List);
        logs.add('${_indent()}]');
      } else if (response.data is List) {
        logs.add('${_indent()}[');
        _printList(response.data as List);
        logs.add('${_indent()}]');
      } else {
        _printBlock(response.data.toString());
      }
    }
  }

  void _printResponseHeader(Response response) {
    final uri = response.requestOptions.uri;
    final method = response.requestOptions.method;
    _printBoxed(
        header: 'Response ║ $method ║ Status: ${response.statusCode} ${response.statusMessage}', text: uri.toString());
  }

  void _printUint8List(Uint8List list, {int tabs = kInitialTab}) {
    var chunks = [];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(
        list.sublist(i, i + chunkSize > list.length ? list.length : i + chunkSize),
      );
    }
    for (var element in chunks) {
      logs.add('${_indent(tabs)} ${element.join(", ")}');
    }
  }
}
