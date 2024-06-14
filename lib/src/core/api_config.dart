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
    // this.isToastErrors = false,
    this.listFormat,
    this.maxRedirects,
    this.method = HTTPMethod.GET,
    this.persistentConnection,
    this.postBodyByDefault = false,
    this.postBodyFormat,
    @Deprecated(
        'Use `postBodyByDefault` and `postBodyFormat` instead, it will be removed in next version.')
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

  /// Content-Type
  final String? contentType;

  /// 确保 Headers 字段不为空
  final bool ensureNonNullHeadersFields;

  /// 确保 Parameters 字段不为空
  final bool ensureNonNullParametersFields;

  /// 额外参数
  final Parameters? extra;

  /// 跟随重定向
  final bool? followRedirects;

  /// 默认请求头
  final HTTPHeader? headers;

  /// 是否处理错误
  final bool isHandleErrors;

  // TODO: 自动弹错误 toast
  // final bool isToastErrors;

  /// 数组格式
  final ListFormat? listFormat;

  /// 最大重定向次数
  final int? maxRedirects;

  /// 请求方式
  final HTTPMethod? method;

  /// 持久化连接
  final bool? persistentConnection;

  /// Post 方式默认使用 Request Body
  final bool postBodyByDefault;

  /// Post 时 Body 默认使用的格式
  final BodyFormat? postBodyFormat;

  /// Post 方式默认使用 FormData
  @Deprecated(
      'Use `postBodyByDefault` and `postBodyFormat` instead, it will be removed in next version.')
  final bool postUseFormData;

  /// 跟随主域名后面的前缀
  final String prefixPath;

  /// 保留 Header 大小写
  final bool preserveHeaderCase;

  /// 请求参数
  final Parameters? queryParameters;

  /// 状态错误时是否接收数据
  final bool? receiveDataWhenStatusError;

  /// 接收超时时间
  final Duration? receiveTimeout;

  /// 请求编码
  final RequestEncoder? requestEncoder;

  /// 响应解码
  final ResponseDecoder? responseDecoder;

  /// 响应类型
  final ResponseType? responseType;

  /// 发送超时时间
  final Duration? sendTimeout;

  /// 跟随主域名后面的后缀
  final String suffixPath;

  /// 请求状态校验
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
    bool? postBodyByDefault,
    BodyFormat? postBodyFormat,
    @Deprecated(
        'Use `postBodyByDefault` and `postBodyFormat` instead, it will be removed in next version.')
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
      ensureNonNullHeadersFields:
          ensureNonNullHeadersFields ?? this.ensureNonNullHeadersFields,
      ensureNonNullParametersFields:
          ensureNonNullParametersFields ?? this.ensureNonNullParametersFields,
      extra: extra ?? this.extra,
      followRedirects: followRedirects ?? this.followRedirects,
      headers: headers ?? this.headers,
      isHandleErrors: isHandleErrors ?? this.isHandleErrors,
      // isToastErrors: isToastErrors ?? this.isToastErrors,
      listFormat: listFormat ?? this.listFormat,
      maxRedirects: maxRedirects ?? this.maxRedirects,
      method: method ?? this.method,
      persistentConnection: persistentConnection ?? this.persistentConnection,
      postBodyByDefault: postBodyByDefault ?? this.postBodyByDefault,
      postBodyFormat: postBodyFormat ?? this.postBodyFormat,
      postUseFormData: postUseFormData ?? this.postUseFormData,
      prefixPath: prefixPath ?? this.prefixPath,
      preserveHeaderCase: preserveHeaderCase ?? this.preserveHeaderCase,
      queryParameters: queryParameters ?? this.queryParameters,
      receiveDataWhenStatusError:
          receiveDataWhenStatusError ?? this.receiveDataWhenStatusError,
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
  /// 默认 URL
  static const baseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: "");

  /// 根据 enum index
  static const _envi =
      int.fromEnvironment('APP_API_ENV', defaultValue: _kDebugMode ? 1 : 0);

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

// ignore_for_file: constant_identifier_names
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

// TODO: 目前就实现了 [multipart, urlencoded, json] 类型
enum BodyFormat {
  plain,
  html,
  xml,
  json,
  urlencoded,
  multipart,
  binary,
  yaml,
  buffers,
  csv,
}

extension BodyFormatExt on BodyFormat {
  String? get contentType {
    switch (this) {
      case BodyFormat.plain:
        return Headers.textPlainContentType;
      case BodyFormat.html:
        return 'text/html';
      case BodyFormat.xml:
        return 'application/xml';
      case BodyFormat.json:
        return Headers.jsonContentType;
      case BodyFormat.urlencoded:
        return Headers.formUrlEncodedContentType;
      case BodyFormat.multipart:
        return Headers.multipartFormDataContentType;
      case BodyFormat.binary:
        return 'application/octet-stream';
      case BodyFormat.yaml:
        return 'application/x-yaml';
      case BodyFormat.buffers:
        return 'application/octet-stream';
      case BodyFormat.csv:
        return 'text/csv';
    }
  }
}
