import 'package:sm_network/sm_network.dart';

class APICore {
  factory APICore() => _instance;

  APICore._();

  static APIConfig? _config;
  static APIPagingConfig? _pagingConfig;
  static final APICore _instance = APICore._();

  static APIConfig get config => _config ??= APIConfig();
  static APIPagingConfig get pagingConfig =>
      _pagingConfig ??= APIPagingConfig();
  static APICore get instance => _instance;

  /// 可以在任意地方调用, 调用之后所有的 [APISession] 都会默认使用这个配置
  /// 只初始化一次，后续使用 [updateConfig] 来更新配置
  static void initialize({
    required APIConfig config,
    APIPagingConfig? pagingConfig,
  }) {
    _config ??= config;
    _pagingConfig ??= pagingConfig;
  }

  static void updateConfig({
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
    String? numberKey,
    int? pageNumber,
    int? pageSize,
    String? sizeKey,
  }) {
    assert(_config != null, 'You must initialize the APICore first');
    if (_config != null) {
      _config = config.copyWith(
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
        postBodyByDefault: postBodyByDefault,
        postBodyFormat: postBodyFormat,
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
      );
    }
    if (numberKey != null &&
        pageNumber != null &&
        pageSize != null &&
        sizeKey != null) {
      _pagingConfig = pagingConfig.copyWith(
        numberKey: numberKey,
        pageNumber: pageNumber,
        pageSize: pageSize,
        sizeKey: sizeKey,
      );
    }
  }
}
