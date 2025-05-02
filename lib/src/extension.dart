import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

/// [ResponseBody] 扩展
@internal
extension ResponseBodyExt on ResponseBody {
  /// 转换为 json
  Map<String, dynamic> toJson() => {
        'isRedirect': isRedirect,
        'redirects': redirects,
        'statusCode': statusCode,
        'statusMessage': statusMessage,
        'headers': headers,
        'extra': extra,
        'stream': stream.toString(),
        'contentLength': contentLength,
      };
}

/// [String] 扩展
@internal
extension StringExt on String {
  String removeEnd(String end) {
    if (endsWith(end)) {
      return substring(0, length - 1);
    }
    return this;
  }
}
