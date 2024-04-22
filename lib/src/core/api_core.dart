import 'package:dio/dio.dart';

import 'api_config.dart';

class APICore {
  factory APICore() => _instance;

  APICore._();

  static APIConfig? _config;
  static final APICore _instance = APICore._();

  static APIConfig get config => _config ?? APIConfig();
  static APICore get instance => _instance;

  /// 可以在任意地方调用, 调用之后所有的 [APISession] 都会默认使用这个配置
  static void initialize(APIConfig config) {
    _config = config;
  }

  static void updataConfig(
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
  ) {
    initialize(
      config.copyWith(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        contentType: contentType,
        ensureNonNullHeadersFields: ensureNonNullHeadersFields,
        ensureNonNullParametersFields: ensureNonNullParametersFields,
        extra: extra,
        followRedirects: followRedirects,
        headers: headers,
        isHandleErrors: isHandleErrors,
        isToastErrors: isToastErrors,
        listFormat: listFormat,
        maxRedirects: maxRedirects,
        method: method,
        persistentConnection: persistentConnection,
        postUseFormData: postUseFormData,
        prefixPath: prefixPath,
        preserveHeaderCase: preserveHeaderCase,
        queryParameters: queryParameters,
        receiveDataWhenStatusError: receiveDataWhenStatusError,
        receiveTimeout: receiveTimeout,
        requestEncoder: requestEncoder,
        responseDecoder: responseDecoder,
        responseType: responseType,
        sendTimeout: sendTimeout,
        suffixPath: suffixPath,
        validateStatus: validateStatus,
      ),
    );
  }
}
