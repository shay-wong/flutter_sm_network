import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:sm_logger/sm_logger.dart';

import '../core/api_config.dart';
import '../interceptors/m_dio_logger.dart';
import '../responder/api_error.dart';
import '../responder/api_responder.dart';
import 'api_options.dart';

mixin APIDioMixin<T, E extends APIResponder<T>>
    on APIXDioMixin, APIParseMixin<T> {
  /// 创建响应对象, 重写此方法可以自定义响应对象
  E createResponder(dynamic data) {
    return APIResponder<T>.fromJson(data,
        fromJsonT: fromJson, parseJsonT: parseJson) as E;
  }

  E decodeJson(dynamic data) {
    // 如果是 json 字符串就先解析
    if (data is String) {
      data = jsonDecode(data);
    }
    return createResponder(data);
  }

  Future<E> request({
    HTTPMethod? method,
    Object? data,
    Parameters? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool? useBody,
    BodyFormat? bodyFormat,
    bool isCached = true,
  }) async {
    // 网络请求
    try {
      final response = await rawFetch(
        method: method,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
        useBody: useBody,
        bodyFormat: bodyFormat,
        isCached: isCached,
      );

      final responder = decodeJson(response);

      if (responder.isSuccess || !config.isHandleErrors) {
        return responder;
      }

      return Future.error(
        responder.error ??
            APIError(
              code: -1,
              message: '接口请求错误',
            ),
      );
    } on DioException catch (e) {
      logger.e('$e \n $path');

      if (e.response == null) {
        return Future.error(e.error ?? APIError.error());
      }

      if (e.type == DioExceptionType.badResponse &&
          e.response?.statusCode == 503) {
        return Future.error(
          APIError(
            code: e.response?.statusCode,
            message: '服务正在重启, 请稍后再试',
          ),
        );
      }

      final responder = decodeJson(e.response!.data);

      return Future.error(
        responder.error?.mergeWith(
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
}

mixin APIXDioMixin<X> on APIOptions {
  /// dio 对象
  late final Dio _dio = config.dio ?? Dio(_baseOptions);

  Dio get dio => _dio;

  BaseOptions? get _baseOptions {
    Parameters? headers = config.headers;
    if (config.ensureNonNullHeadersFields) {
      headers = headers?..removeWhere((key, value) => value == null);
    }
    return BaseOptions(
      method: config.method?.name,
      connectTimeout: config.connectTimeout,
      receiveTimeout: config.receiveTimeout,
      sendTimeout: config.sendTimeout,
      baseUrl: config.baseUrl ?? APIEnv.baseUrl,
      queryParameters: config.queryParameters,
      extra: config.extra,
      headers: headers,
      preserveHeaderCase: config.preserveHeaderCase,
      responseType: config.responseType,
      contentType: config.contentType,
      validateStatus: config.validateStatus,
      receiveDataWhenStatusError: config.receiveDataWhenStatusError,
      followRedirects: config.followRedirects,
      maxRedirects: config.maxRedirects,
      persistentConnection: config.persistentConnection,
      requestEncoder: config.requestEncoder,
      responseDecoder: config.responseDecoder,
      listFormat: config.listFormat,
    );
  }

  void cacheInterceptors({
    bool isCached = true,
  }) {
    if (isCached) {
      // OPTIMIZE: 自定义接口缓存
      final cacheInterceptors = DioCacheInterceptor(
        options: CacheOptions(
          store: MemCacheStore(),
        ),
      );
      _dio.interceptors.add(cacheInterceptors);
    }
  }

  void loggerInterceptors() {
    if (kPrintable) {
      // 添加 LogInterceptor 拦截器来自动打印请求、响应日志：
      _dio.interceptors.add(
        MDioLogger(
          requestHeader: true,
          requestBody: true,
          maxWidth: consoleOutputLength - 2,
          logPrint: (object) {
            logger.p(object);
          },
        ),
      );
    }
  }

  Future<X?> rawFetch({
    String? url,
    HTTPMethod? method,
    Object? data,
    Parameters? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool? useBody,
    BodyFormat? bodyFormat,
    bool isCached = true,
  }) async {
    return rawRequest(
      url: url,
      method: method,
      data: data,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      options: options,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
      useBody: useBody,
      bodyFormat: bodyFormat,
      isCached: isCached,
    ).then(
      (value) => value.data,
    );
  }

  /// 发送请求
  /// 参数优先级高于默认配置
  /// 如果设置了 [options], 则 [method] 无效, 只会替换默认的 [APIOptions.options] 中的 [method]
  Future<Response<X>> rawRequest({
    String? url,
    HTTPMethod? method,
    Object? data,
    Parameters? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool? useBody,
    BodyFormat? bodyFormat,
    bool isCached = true,
  }) {
    // 添加 DioCacheInterceptor 拦截器实现接口缓存
    cacheInterceptors(isCached: isCached);

    loggerInterceptors();

    // 初始化参数
    url ??= this.url;
    data ??= this.data;
    method ??= this.method;
    queryParameters ??= parameters;
    // TODO: remove postUseFormData
    useBody ??= this.useBody ||
        (method == HTTPMethod.POST &&
            (config.postBodyByDefault || config.postUseFormData));
    options ??= this.options?.copyWith(method: method.name);
    bodyFormat ??= this.bodyFormat ??
        (method == HTTPMethod.POST ? config.postBodyFormat : null);

    if (config.ensureNonNullParametersFields) {
      queryParameters?.removeWhere((key, value) => value == null);
    }

    if (data == null && useBody && queryParameters != null) {
      if (bodyFormat == BodyFormat.plain) {
        data = queryParameters.toString();
      } else if (bodyFormat == BodyFormat.urlencoded) {
        data = Uri(queryParameters: queryParameters).query;
      } else if (bodyFormat == BodyFormat.multipart) {
        data = FormData.fromMap(queryParameters);
      } else if (bodyFormat == BodyFormat.json) {
        data = jsonEncode(queryParameters);
      } else {
        data = queryParameters;
      }
      queryParameters = null;
      if (bodyFormat != null) {
        options?.contentType = bodyFormat.contentType;
      }
    }

    return _dio.request<X>(
      url,
      data: data,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      options: options,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }
}
