// ignore_for_file: constant_identifier_names

import 'package:dio/dio.dart';

const bool _kDebugMode = !_kReleaseMode && !_kProfileMode;
const bool _kProfileMode = bool.fromEnvironment('dart.vm.profile');
const bool _kReleaseMode = bool.fromEnvironment('dart.vm.product');

typedef FromJsonT<T> = T Function(dynamic json);

typedef HTTPHeader = Parameters;

typedef Parameters = Map<String, dynamic>;

typedef ParseJsonT<T> = T Function(Parameters json);

typedef ToJsonT<T> = Parameters? Function(T? value);

/// 默认配置, 在调用 [APISession] 之前, 必须先调用 [APICore.initialize] 才会生效
class APIConfig {
  APIConfig({
    this.dio,
    this.baseUrl,
    this.connectTimeout = const Duration(seconds: 60),
    this.contentType,
    this.ensureNonNullHeadersFields = false,
    this.ensureNonNullParametersFields = false,
    this.extra,
    this.followRedirects,
    this.headers,
    this.isHandleErrors = false,
    this.isToastErrors = false,
    this.listFormat,
    this.maxRedirects,
    this.method = HTTPMethod.GET,
    this.persistentConnection,
    this.postUseFormData = false,
    this.prefixPath = '',
    this.preserveHeaderCase = false,
    this.queryParameters,
    this.receiveDataWhenStatusError,
    this.receiveTimeout = const Duration(seconds: 60),
    this.requestEncoder,
    this.responseDecoder,
    this.responseType = ResponseType.json,
    this.sendTimeout,
    this.suffixPath = '',
    this.validateStatus,
  });

  final Dio? dio;

  /// 默认 URL
  final String? baseUrl;

  /// 连接超时时间
  final Duration? connectTimeout;

  ///
  final String? contentType;

  /// 确保 Headers 字段不为空
  final bool ensureNonNullHeadersFields;

  /// 确保 Parameters 字段不为空
  final bool ensureNonNullParametersFields;

  ///
  final Parameters? extra;

  ///
  final bool? followRedirects;

  /// 默认请求头
  final HTTPHeader? headers;

  /// 是否处理错误
  final bool isHandleErrors;

  // TODO: 自动弹错误 toast
  final bool isToastErrors;

  ///
  final ListFormat? listFormat;

  ///
  final int? maxRedirects;

  /// 请求方式
  final HTTPMethod? method;

  ///
  final bool? persistentConnection;

  /// Post 方式默认使用 FormData
  final bool postUseFormData;

  /// 跟随主域名后面的前缀
  final String prefixPath;

  ///
  final bool preserveHeaderCase;

  ///
  final Parameters? queryParameters;

  ///
  final bool? receiveDataWhenStatusError;

  /// 接收超时时间
  final Duration? receiveTimeout;

  ///
  final RequestEncoder? requestEncoder;

  ///
  final ResponseDecoder? responseDecoder;

  ///
  final ResponseType? responseType;

  /// 发送超时时间
  final Duration? sendTimeout;

  /// 跟随主域名后面的后缀
  final String suffixPath;

  ///
  final ValidateStatus? validateStatus;

  APIConfig copyWith({
    String? baseUrl,
    Duration? connectTimeout,
    String? contentType,
    bool? ensureNonNullHeadersFields,
    bool? ensureNonNullParametersFields,
    Parameters? extra,
    bool? followRedirects,
    HTTPHeader? headers,
    bool? isHandleErrors,
    bool? isToastErrors,
    ListFormat? listFormat,
    int? maxRedirects,
    HTTPMethod? method,
    bool? persistentConnection,
    bool? postUseFormData,
    String? prefixPath,
    bool? preserveHeaderCase,
    Parameters? queryParameters,
    bool? receiveDataWhenStatusError,
    Duration? receiveTimeout,
    RequestEncoder? requestEncoder,
    ResponseDecoder? responseDecoder,
    ResponseType? responseType,
    Duration? sendTimeout,
    String? suffixPath,
    ValidateStatus? validateStatus,
  }) {
    return APIConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      connectTimeout: connectTimeout ?? this.connectTimeout,
      contentType: contentType ?? this.contentType,
      ensureNonNullHeadersFields: ensureNonNullHeadersFields ?? this.ensureNonNullHeadersFields,
      ensureNonNullParametersFields: ensureNonNullParametersFields ?? this.ensureNonNullParametersFields,
      extra: extra ?? this.extra,
      followRedirects: followRedirects ?? this.followRedirects,
      headers: headers ?? this.headers,
      isHandleErrors: isHandleErrors ?? this.isHandleErrors,
      isToastErrors: isToastErrors ?? this.isToastErrors,
      listFormat: listFormat ?? this.listFormat,
      maxRedirects: maxRedirects ?? this.maxRedirects,
      method: method ?? this.method,
      persistentConnection: persistentConnection ?? this.persistentConnection,
      postUseFormData: postUseFormData ?? this.postUseFormData,
      prefixPath: prefixPath ?? this.prefixPath,
      preserveHeaderCase: preserveHeaderCase ?? this.preserveHeaderCase,
      queryParameters: queryParameters ?? this.queryParameters,
      receiveDataWhenStatusError: receiveDataWhenStatusError ?? this.receiveDataWhenStatusError,
      receiveTimeout: receiveTimeout ?? this.receiveTimeout,
      requestEncoder: requestEncoder ?? this.requestEncoder,
      responseDecoder: responseDecoder ?? this.responseDecoder,
      responseType: responseType ?? this.responseType,
      sendTimeout: sendTimeout ?? this.sendTimeout,
      suffixPath: suffixPath ?? this.suffixPath,
      validateStatus: validateStatus ?? this.validateStatus,
    );
  }
}

class APIEnv {
  static const baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: "");

  /// 根据 enum index
  static const _envi = int.fromEnvironment('APP_API_ENV', defaultValue: _kDebugMode ? 1 : 0);

  static APIEnvType get env => APIEnvType.values[_envi];
}

enum APIEnvType {
  release(
    '正式环境',
  ),
  debug(
    '调试环境',
  ),
  test(
    '测试环境',
  ),
  local(
    '本地环境',
  );

  final String env;

  const APIEnvType(
    this.env,
  );
}

enum HTTPMethod {
  CONNECT,
  DELETE,
  GET,
  HEAD,
  OPTIONS,
  PATCH,
  POST,
  PUT,
  QUERY,
  TRACE,
}
