import 'package:dio/dio.dart';

import '../core/api_config.dart';
import '../responder/api_responder.dart';
import 'api_mixin.dart';
import 'api_options.dart';

final class API<T> extends APISession<T> {
  API({String? url}) : _url = url;

  @override
  String get url => _url ?? super.url;

  final String? _url;
}

abstract class APISession<T> extends APIXSession
    with APIParseMixin<T>, APIDioMixin<T, APIResponder<T>>, APISessionMixin {}

mixin APISessionMixin<T, E extends APIResponder<T>> on APIDioMixin<T, E> {
  /// 根据 responder 自动解析成对应的 model 并返回
  Future<T?> fetch({
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
    return request(
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

  /// 根据 responder 自动解析成对应的 list model 并返回
  Future<List<T>?> fetchList({
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
    return request(
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
      (value) => value.dataList,
    );
  }
}

abstract class APIXSession<T> with APIOptions, APIXDioMixin<T> {}
