import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum EnvType {
  test(
    '测试环境',
    Color(0xFFFFA500),
  ),
  release(
    '正式环境',
    Colors.green,
  ),
  ip(
    'ip 本地环境',
    Color(0xFF0000FF),
  );

  const EnvType(
    this.env,
    this.color,
  );

  final Color color;
  final String env;
}

class APIEnv {
  /// 根据 enum index
  static const envi = int.fromEnvironment('APP_ENV', defaultValue: kDebugMode ? 0 : 1);

  static EnvType get env => EnvType.values[envi];

  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: "");
  static const picBaseUrl = String.fromEnvironment('PIC_BASE_URL', defaultValue: "");
  static const wsBaseUrl = String.fromEnvironment('WS_BASE_URL', defaultValue: "");
}
