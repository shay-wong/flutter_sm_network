import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

import 'http.dart';

@internal
final class Utils {
  factory Utils() => _instance;
  Utils._();
  static final _instance = Utils._();

  /// 单例
  static Utils get shared => _instance;

  /// 处理请求 data
  Object? processData({
    Object? data,
    FormFiles? files,
    ContentType? contentType,
  }) {
    // 处理 upload
    if (files != null) {
      data ??= Parameters.from({});
      if (data is Parameters) {
        data = FormData.fromMap({...data, ...files});
      } else {
        throw ArgumentError('data must be Parameters when files is not null');
      }
    }
    // 处理请求体
    if (data != null) {
      if (contentType == ContentType.json) {
        data = jsonEncode(data);
      } else if (contentType == ContentType.multipart && data is Parameters) {
        data = FormData.fromMap(data);
      }
    }
    return data;
  }
}
