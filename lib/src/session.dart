import 'package:dio/dio.dart';

import 'coverters/converter.dart';
import 'http.dart';
import 'options.dart';
import 'request.dart';

/// Http 扩展
mixin Net {
  /// delete
  static Future<BaseResp<T?>> delete<T>({
    String? path,
    Object? data,
    Parameters? queryParameters,
    HttpOptions<BaseResp<T>, T>? options,
    CancelToken? cancelToken,
  }) {
    return request<T>(
      method: Method.delete,
      path: path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// delete uri
  static Future<BaseResp<T?>> deleteUri<T>({
    Uri? uri,
    Object? data,
    HttpOptions<BaseResp<T>, T>? options,
    CancelToken? cancelToken,
  }) {
    return requestUri<T>(
      method: Method.delete,
      uri: uri,
      data: data,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// fetch
  static Future<Response<E?>> fetch<E, T>({
    String? path,
    Method? method,
    Object? data,
    Parameters? queryParameters,
    CancelToken? cancelToken,
    HttpOptions<BaseResp<T>, T>? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) =>
      session<T>(
        path: path,
        method: method,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      ).fetch<E>();

  /// get
  static Future<BaseResp<T?>> get<T>({
    String? path,
    Object? data,
    Parameters? queryParameters,
    HttpOptions<BaseResp<T>, T>? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) {
    return request<T>(
      method: Method.get,
      path: path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// get uri
  static Future<BaseResp<T?>> getUri<T>({
    Uri? uri,
    Object? data,
    HttpOptions<BaseResp<T>, T>? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) {
    return requestUri<T>(
      method: Method.get,
      uri: uri,
      data: data,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// head
  static Future<BaseResp<T?>> head<T>({
    String? path,
    Object? data,
    Parameters? queryParameters,
    HttpOptions<BaseResp<T>, T>? options,
    CancelToken? cancelToken,
  }) {
    return request<T>(
      method: Method.head,
      path: path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// head uri
  static Future<BaseResp<T?>> headUri<T>({
    Uri? uri,
    Object? data,
    HttpOptions<BaseResp<T>, T>? options,
    CancelToken? cancelToken,
  }) {
    return requestUri<T>(
      method: Method.head,
      uri: uri,
      data: data,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// patch
  static Future<BaseResp<T?>> patch<T>({
    String? path,
    Object? data,
    Parameters? queryParameters,
    HttpOptions<BaseResp<T>, T>? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return request<T>(
      method: Method.patch,
      path: path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// patch uri
  static Future<BaseResp<T?>> patchUri<T>({
    Uri? uri,
    Object? data,
    HttpOptions<BaseResp<T>, T>? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return requestUri<T>(
      method: Method.patch,
      uri: uri,
      data: data,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// post
  static Future<BaseResp<T?>> post<T>({
    String? path,
    Object? data,
    Parameters? queryParameters,
    HttpOptions<BaseResp<T>, T>? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return request<T>(
      method: Method.post,
      path: path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// post uri
  static Future<BaseResp<T?>> postUri<T>({
    Uri? uri,
    Object? data,
    HttpOptions<BaseResp<T>, T>? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return requestUri<T>(
      method: Method.post,
      uri: uri,
      data: data,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// put
  static Future<BaseResp<T?>> put<T>({
    String? path,
    Object? data,
    Parameters? queryParameters,
    HttpOptions<BaseResp<T>, T>? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return request<T>(
      method: Method.put,
      path: path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// put uri
  static Future<BaseResp<T?>> putUri<T>({
    Uri? uri,
    Object? data,
    HttpOptions<BaseResp<T>, T>? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return requestUri<T>(
      method: Method.put,
      uri: uri,
      data: data,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// request
  static Future<BaseResp<T?>> request<T>({
    String? path,
    Method? method,
    Object? data,
    Parameters? queryParameters,
    CancelToken? cancelToken,
    HttpOptions<BaseResp<T>, T>? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) =>
      session<T>(
        path: path,
        method: method,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      ).request();

  /// request uri
  static Future<BaseResp<T?>> requestUri<T>({
    Uri? uri,
    Method? method,
    Object? data,
    CancelToken? cancelToken,
    HttpOptions<BaseResp<T>, T>? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return request<T>(
      path: uri?.toString(),
      method: method,
      data: data,
      cancelToken: cancelToken,
      options: options,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// session
  static Session<T> session<T>({
    CancelToken? cancelToken,
    ContentType? contentType,
    Converter<BaseResp<T>, T>? converter,
    Object? data,
    Parameters? extra,
    bool? followRedirects,
    FromJsonT<T>? fromJsonT,
    HTTPHeaders? headers,
    ListFormat? listFormat,
    int? maxRedirects,
    Method? method,
    ProgressCallback? onReceiveProgress,
    ProgressCallback? onSendProgress,
    HttpOptions<BaseResp<T>, T>? options,
    Parameters? queryParameters,
    String? path,
    bool? persistentConnection,
    bool? preserveHeaderCase,
    bool? receiveDataWhenStatusError,
    Duration? receiveTimeout,
    RequestEncoder? requestEncoder,
    ResponseDecoder? responseDecoder,
    ResponseType? responseType,
    Duration? sendTimeout,
    ValidateStatus? validateStatus,
  }) =>
      _DefaultSession<T>(
        cancelToken: cancelToken,
        contentType: contentType,
        converter: converter,
        data: data,
        extra: extra,
        followRedirects: followRedirects,
        fromJsonT: fromJsonT,
        headers: headers,
        listFormat: listFormat,
        maxRedirects: maxRedirects,
        method: method,
        onReceiveProgress: onReceiveProgress,
        onSendProgress: onSendProgress,
        options: options,
        parameters: queryParameters,
        path: path,
        persistentConnection: persistentConnection,
        preserveHeaderCase: preserveHeaderCase,
        receiveDataWhenStatusError: receiveDataWhenStatusError,
        receiveTimeout: receiveTimeout,
        requestEncoder: requestEncoder,
        responseDecoder: responseDecoder,
        responseType: responseType,
        sendTimeout: sendTimeout,
        validateStatus: validateStatus,
      );
}

/// 原始请求会话
abstract class RawSession<R extends BaseResp<T>, T>
    with HttpOptionsMixin<R, T>, RequestMixin<R, T> {}

/// 请求会话
abstract class Session<T> extends RawSession<BaseResp<T>, T> {}

class _DefaultSession<T> extends Session<T> {
  _DefaultSession({
    this.cancelToken,
    this.contentType,
    Converter<BaseResp<T>, T>? converter,
    this.data,
    this.extra,
    this.followRedirects,
    this.fromJsonT,
    this.headers,
    this.listFormat,
    this.maxRedirects,
    this.method,
    this.onReceiveProgress,
    this.onSendProgress,
    HttpOptions<BaseResp<T>, T>? options,
    this.parameters,
    this.path,
    this.persistentConnection,
    this.preserveHeaderCase,
    this.receiveDataWhenStatusError,
    this.receiveTimeout,
    this.requestEncoder,
    this.responseDecoder,
    this.responseType,
    this.sendTimeout,
    this.validateStatus,
  })  : _converter = converter,
        _options = options;

  final HttpOptions<BaseResp<T>, T>? _options;

  @override
  final CancelToken? cancelToken;

  @override
  final ContentType? contentType;

  final Converter<BaseResp<T>, T>? _converter;

  @override
  Converter<BaseResp<T>, T> get converter => _converter ?? super.converter;

  @override
  final Object? data;

  @override
  final Parameters? extra;

  @override
  final bool? followRedirects;

  @override
  final FromJsonT<T>? fromJsonT;

  @override
  final HTTPHeaders? headers;

  @override
  final ListFormat? listFormat;

  @override
  final int? maxRedirects;

  @override
  final Method? method;

  @override
  final ProgressCallback? onReceiveProgress;

  @override
  final ProgressCallback? onSendProgress;

  @override
  final Parameters? parameters;

  @override
  final String? path;

  @override
  final bool? persistentConnection;

  @override
  final bool? preserveHeaderCase;

  @override
  final bool? receiveDataWhenStatusError;

  @override
  final Duration? receiveTimeout;

  @override
  final RequestEncoder? requestEncoder;

  @override
  final ResponseDecoder? responseDecoder;

  @override
  final ResponseType? responseType;

  @override
  final Duration? sendTimeout;

  @override
  final ValidateStatus? validateStatus;

  @override
  HttpOptions<BaseResp<T>, T>? get options => _options ?? super.options;
}
