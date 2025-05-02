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

/// [Map] 扩展
@internal
extension MapExt<K, V> on Map<K, V> {
  dynamic getNestedValue(String path) {
    // 支持 '.' 或 '>' 作为路径分隔符
    final keys = path.split(RegExp('[.>]'));

    dynamic current = this;
    for (final key in keys) {
      if (current is Map<String, dynamic> && current.containsKey(key)) {
        current = current[key];
      } else {
        return null; // 找不到路径时返回 null
      }
    }
    return current;
  }
}
