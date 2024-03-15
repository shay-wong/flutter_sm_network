import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter_sm_logger/sm_logger.dart';

import '../interceptors/dio_logger.dart';
import '../responder/api_error.dart';
import '../responder/api_responder.dart';
import 'api_env.dart';

enum HTTPMethod {
  connect('CONNECT'),
  delete('DELETE'),
  get('GET'),
  head('HEAD'),
  options('OPTIONS'),
  patch('PATCH'),
  post('POST'),
  put('PUT'),
  query('QUERY'),
  trace('TRACE');

  const HTTPMethod(this.value);

  final String value;
}

typedef Parameters = Map<String, dynamic>;
typedef HTTPHeader = Map<String, dynamic>;

mixin APISession<T> {
  /// dio 对象
  late final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: timeoutInterval,
      receiveTimeout: timeoutInterval,
      headers: _defaultHeaders,
    ),
  );

  /// 基础 url
  String get _baseUrl => APIEnv.apiBaseUrl;

  /// 默认请求头
  HTTPHeader get _defaultHeaders {
    HTTPHeader header = {
      // "version": DeviceService.version,
      // "locale": DeviceService.isoCode,
      // "store": DeviceService.storeInfo,
      // "brand": DeviceService.brand,
      // "model": DeviceService.model,
      // "language": DeviceService.language,
      // "identity": DeviceService.packageName,
      // "systemVersion": DeviceService.systemVersion,
      // "Authorization": AuthService.to.token?.requestToken,
      // "vendorID": DeviceService.vendorId,
      // "oaid": DeviceService.oaid,
      // "phone_locale": DeviceService.localeName, //en_US
      // "phone_language": DeviceService.languageCode, //e
      // "jPushId": DeviceService.notificationId
    };

    return header;
  }

  /// 请求头 默认 null
  HTTPHeader? get headers => null;

  /// 确保 Headers 字段不为空
  bool get isEnsureNonNullHeadersFields => true;

  /// 确保 Parameters 字段不为空
  bool get isEnsureNonNullParametersFields => true;

  /// 请求方式 默认 post
  HTTPMethod get method => HTTPMethod.post;

  /// 请求参数 默认 null
  Parameters? get parameters => null;

  /// 请求路径 默认 null
  String? get path => null;

  /// Post 方式默认使用 FormData
  bool get postUseFormData => true;

  /// 跟随主域名后面的前缀
  String get prefixPath => '/boxdata';

  /// 请求响应处理
  T Function(dynamic json) get responder => (json) => json as T;

  /// 请求超时时间
  Duration get timeoutInterval => const Duration(seconds: 30);

  /// 请求 url
  String get url => _baseUrl + prefixPath + (path ?? '');

  /// 是否处理错误
  bool get isHandleErrors => true;
  // TODO: 自动弹错误 toast
  bool get isToastErrors => false;

  Future<APIResponder<T>> request({bool isCached = true}) async {
    final finalHeaders = {..._defaultHeaders, ...?headers};
    if (isEnsureNonNullHeadersFields) finalHeaders.removeWhere((key, value) => value == null);
    // 请求配置
    final options = Options(method: method.value, headers: finalHeaders);
    // 添加 DioCacheInterceptor 拦截器实现接口缓存：
    if (isCached) {
      // OPTIMIZE: 自定义接口缓存
      final cacheInterceptors = DioCacheInterceptor(
        options: CacheOptions(
          store: MemCacheStore(),
        ),
      );
      _dio.interceptors.add(cacheInterceptors);
    }

    if (kPrintable) {
      // 添加 LogInterceptor 拦截器来自动打印请求、响应日志：
      _dio.interceptors.add(
        DioLogger(
          requestHeader: true,
          requestBody: true,
          maxWidth: consoleOutputLength - 2,
        ),
      );
    }

    // 网络请求
    try {
      Object? data;
      Parameters? queryParameters = parameters;

      if (isEnsureNonNullParametersFields) {
        queryParameters?.removeWhere((key, value) => value == null);
      }

      if (method == HTTPMethod.post && postUseFormData && queryParameters != null) {
        data = FormData.fromMap(queryParameters);
        queryParameters = null;
      }

      Response response = await _dio.request(
        prefixPath + (path ?? ''),
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      final res = APIResponder.fromJson(response.data, responder);
      if (res.isSuccess || !isHandleErrors) {
        return res;
      }
      return Future.error(
        res.error ??
            APIError(
              code: -1,
              message: '接口请求错误',
            ),
      );
    } on DioException catch (e) {
      logger.e('$e \n $path');
      if (e.type == DioExceptionType.badResponse && e.response?.statusCode == 503) {
        return Future.error(APIError(code: e.response?.statusCode, message: '服务正在重启, 请稍后再试'));
      }
      final response = APIResponder.fromJson(e.response?.data, responder);
      return Future.error(
        response.error?.copyWith(
              code: e.response?.statusCode,
              message: e.response?.statusMessage,
            ) ??
            APIError(
              code: e.response?.statusCode,
              message: e.response?.statusMessage ?? '接口请求错误',
            ),
      );
    } on Error catch (e) {
      logger.e('$e \n $path');
      return Future.error(e);
    }
  }

  /// 根据 responder 自动解析成对应的 model 并返回
  Future<T?> send() async {
    return request().then((value) => value.data);
  }
}
