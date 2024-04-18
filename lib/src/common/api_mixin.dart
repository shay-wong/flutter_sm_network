import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter_sm_logger/sm_logger.dart';

import '../core/api_config.dart';
import '../core/api_core.dart';
import '../interceptors/m_dio_logger.dart';
import '../responder/api_error.dart';
import '../responder/api_responder.dart';

mixin APIDioMixin<T, E extends APIResponder<T>> on APIOptions<T> {
  /// dio 对象
  late final Dio _dio = config.dio ?? Dio(_baseOptions);

  Dio get dio => _dio;

  E createResponder(dynamic data) {
    return APIResponder<T>.fromJson(data, (json) => parseJson(json)) as E;
  }

  E decodeJson(dynamic data) {
    // 如果是 json 字符串就先解析
    if (data is String) {
      data = jsonDecode(data);
    }
    return createResponder(data);
  }

  /// 根据 responder 自动解析成对应的 model 并返回
  Future<T?> fetch({bool isCached = true}) async {
    return request(isCached: isCached).then((value) => value.data);
  }

  /// 根据 responder 自动解析成对应的 list model 并返回
  Future<List<T>?> fetchList({bool isCached = true}) async {
    return request(isCached: isCached).then((value) => value.dataList);
  }

  Future<E> request({bool isCached = true}) async {
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
        MDioLogger(
            requestHeader: true,
            requestBody: true,
            maxWidth: consoleOutputLength - 2,
            logPrint: (object) {
              logger.p(object);
            }),
      );
    }

    // 网络请求
    try {
      Object? data;
      Parameters? queryParameters = parameters;

      if (config.ensureNonNullParametersFields) {
        queryParameters?.removeWhere((key, value) => value == null);
      }

      if (method == HTTPMethod.POST &&
          config.postUseFormData &&
          queryParameters != null) {
        data = FormData.fromMap(queryParameters);
        queryParameters = null;
      }

      final response = await _dio.request(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      final responder = decodeJson(response.data);

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

mixin APIOptions<T> {
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

  /// 全局配置
  APIConfig get config => APICore.config;

  ///
  String? get contentType => null;

  ///
  Parameters? get extra => null;

  ///
  bool? get followRedirects => null;

  /// 请求头 默认 null
  HTTPHeader? get headers => null;

  ///
  ListFormat? get listFormat => null;

  ///
  int? get maxRedirects => null;

  /// 请求方式 默认 post
  HTTPMethod get method => config.method ?? HTTPMethod.GET;

  /// 请求配置
  Options? get options {
    Parameters? effectiveHeaders = headers;
    if (config.ensureNonNullHeadersFields) {
      effectiveHeaders = effectiveHeaders
        ?..removeWhere((key, value) => value == null);
    }
    // 请求配置
    return Options(
      method: method.name,
      sendTimeout: sendTimeout,
      receiveTimeout: receiveTimeout,
      extra: extra,
      headers: effectiveHeaders,
      preserveHeaderCase: preserveHeaderCase,
      responseType: responseType,
      contentType: contentType,
      validateStatus: validateStatus,
      receiveDataWhenStatusError: receiveDataWhenStatusError,
      followRedirects: followRedirects,
      maxRedirects: maxRedirects,
      persistentConnection: persistentConnection,
      requestEncoder: requestEncoder,
      responseDecoder: responseDecoder,
      listFormat: listFormat,
    );
  }

  /// 请求参数 默认 null
  Parameters? get parameters => null;

  /// [json] 转换函数
  ParseJsonT<T> get parseJson => fromJson;

  /// 请求路径 默认 null
  String get path => '';

  ///
  bool? get persistentConnection => null;

  /// 跟随主域名后面的前缀
  String get prefixPath => config.prefixPath;

  ///
  bool? get preserveHeaderCase => null;

  ///
  bool? get receiveDataWhenStatusError => null;

  /// 接收超时时间
  Duration? get receiveTimeout => null;

  ///
  RequestEncoder? get requestEncoder => null;

  ///
  ResponseDecoder? get responseDecoder => null;

  ///
  ResponseType? get responseType => null;

  /// 发送超时时间
  Duration? get sendTimeout => null;

  /// 跟随主域名后面的后缀
  String get suffixPath => config.suffixPath;

  /// 请求 [url], 由 [prefixPath]、[path] 和 [suffixPath] 组成
  String get url => prefixPath + path + suffixPath;

  ///
  ValidateStatus? get validateStatus => null;

  /// 将 [json] 转换为对应的 [T] 类型
  T fromJson(dynamic json) => json as T;
}
