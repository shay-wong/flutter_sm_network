import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import 'coverters/converter.dart';
import 'error.dart';
import 'http.dart';
import 'options.dart';

/// 请求接口
abstract class RequestMethod<R extends BaseResp<T>, T> {
  /// Convenience method to make an HTTP DELETE request.
  Future<R> delete({
    String? path,
    Object? data,
    Parameters? queryParameters,
    HttpOptions<R, T>? options,
    CancelToken? cancelToken,
  });

  /// Convenience method to make an HTTP DELETE request with [Uri].
  Future<R> deleteUri({
    Uri? uri,
    Object? data,
    HttpOptions<R, T>? options,
    CancelToken? cancelToken,
  });

  /// The eventual method to submit requests. All callers for requests should
  /// eventually go through this method.
  Future<Response<E>> fetch<E>({
    String? path,
    Method? method,
    Object? data,
    Parameters? queryParameters,
    CancelToken? cancelToken,
    HttpOptions<R, T>? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  });

  /// Convenience method to make an HTTP GET request.
  Future<R> get({
    String? path,
    Object? data,
    Parameters? queryParameters,
    HttpOptions<R, T>? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  });

  /// Convenience method to make an HTTP GET request with [Uri].
  Future<R> getUri({
    Uri? uri,
    Object? data,
    HttpOptions<R, T>? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  });

  /// Convenience method to make an HTTP HEAD request.
  Future<R> head({
    String? path,
    Object? data,
    Parameters? queryParameters,
    HttpOptions<R, T>? options,
    CancelToken? cancelToken,
  });

  /// Convenience method to make an HTTP HEAD request with [Uri].
  Future<R> headUri({
    Uri? uri,
    Object? data,
    HttpOptions<R, T>? options,
    CancelToken? cancelToken,
  });

  /// Convenience method to make an HTTP PATCH request.
  Future<R> patch({
    String? path,
    Object? data,
    Parameters? queryParameters,
    HttpOptions<R, T>? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  });

  /// Convenience method to make an HTTP PATCH request with [Uri].
  Future<R> patchUri({
    Uri? uri,
    Object? data,
    HttpOptions<R, T>? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  });

  /// Convenience method to make an HTTP POST request.
  Future<R> post({
    String? path,
    Object? data,
    Parameters? queryParameters,
    HttpOptions<R, T>? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  });

  /// Convenience method to make an HTTP POST request with [Uri].
  Future<R> postUri({
    Uri? uri,
    Object? data,
    HttpOptions<R, T>? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  });

  /// Convenience method to make an HTTP PUT request.
  Future<R> put({
    String? path,
    Object? data,
    Parameters? queryParameters,
    HttpOptions<R, T>? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  });

  /// Convenience method to make an HTTP PUT request with [Uri].
  Future<R> putUri({
    Uri? uri,
    Object? data,
    HttpOptions<R, T>? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  });

  /// Make HTTP request with options.
  Future<R> request({
    String? path,
    Method? method,
    Object? data,
    Parameters? queryParameters,
    CancelToken? cancelToken,
    HttpOptions<R, T>? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  });

  /// Make http request with options with [Uri].
  Future<R> requestUri({
    Uri? uri,
    Method? method,
    Object? data,
    CancelToken? cancelToken,
    HttpOptions<R, T>? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  });
}

/// 请求混入
mixin RequestMixin<R extends BaseResp<T>, T> on HttpOptionsMixin<R, T>
    implements RequestMethod<R, T> {
  @override
  Future<R> delete({
    String? path,
    Object? data,
    Parameters? queryParameters,
    HttpOptions<R, T>? options,
    CancelToken? cancelToken,
  }) {
    return request(
      method: Method.delete,
      path: path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<R> deleteUri({
    Uri? uri,
    Object? data,
    HttpOptions<R, T>? options,
    CancelToken? cancelToken,
  }) {
    return requestUri(
      method: Method.delete,
      uri: uri,
      data: data,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// [method] 方法名，[options] 中的 [method] 优先级最高
  @override
  Future<Response<E>> fetch<E>({
    String? path,
    Method? method,
    Object? data,
    Parameters? queryParameters,
    CancelToken? cancelToken,
    HttpOptions<R, T>? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    path ??= this.path;
    method ??= this.method;
    data ??= this.data;
    queryParameters ??= parameters;
    options ??= this.options;
    options?.method ??= method?.name;
    cancelToken ??= this.cancelToken;
    onSendProgress ??= this.onSendProgress;
    onReceiveProgress ??= this.onReceiveProgress;

    try {
      // 处理请求体
      if (data != null) {
        if (contentType == ContentType.json) {
          data = jsonEncode(data);
        } else if (contentType == ContentType.multipart && data is Parameters) {
          data = FormData.fromMap(data);
        }
      }

      final response = await Http.dio.request<E>(
        path ?? '',
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      if (response.requestOptions.validateStatus(response.statusCode)) {
        return response;
      } else {
        final message = 'statusCode: ${response.statusCode}, service error(validate failed)';
        final exception = DioException(
          response: response,
          error: NetError(message),
          type: DioExceptionType.badResponse,
          requestOptions: response.requestOptions,
          message: message,
        );

        Http.shared.options.log.error(
          'path: $path \n$exception',
          exception.stackTrace,
        );
        throw exception;
      }
    } on DioException {
      rethrow;
    } catch (e) {
      StackTrace? stackTrace;
      if (e is Error) {
        stackTrace = e.stackTrace;
      }
      Http.shared.options.log.error(
        'path: $path \nError: $e',
        stackTrace ?? StackTrace.current,
      );
      rethrow;
    }
  }

  @override
  Future<R> get({
    String? path,
    Object? data,
    Parameters? queryParameters,
    HttpOptions<R, T>? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) {
    return request(
      method: Method.get,
      path: path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  @override
  Future<R> getUri({
    Uri? uri,
    Object? data,
    HttpOptions<R, T>? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) {
    return requestUri(
      method: Method.get,
      uri: uri,
      data: data,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  @override
  Future<R> head({
    String? path,
    Object? data,
    Parameters? queryParameters,
    HttpOptions<R, T>? options,
    CancelToken? cancelToken,
  }) {
    return request(
      method: Method.head,
      path: path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<R> headUri({
    Uri? uri,
    Object? data,
    HttpOptions<R, T>? options,
    CancelToken? cancelToken,
  }) {
    return requestUri(
      method: Method.head,
      uri: uri,
      data: data,
      options: options,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<R> patch({
    String? path,
    Object? data,
    Parameters? queryParameters,
    HttpOptions<R, T>? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return request(
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

  @override
  Future<R> patchUri({
    Uri? uri,
    Object? data,
    HttpOptions<R, T>? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return requestUri(
      method: Method.patch,
      uri: uri,
      data: data,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  @override
  Future<R> post({
    String? path,
    Object? data,
    Parameters? queryParameters,
    HttpOptions<R, T>? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return request(
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

  @override
  Future<R> postUri({
    Uri? uri,
    Object? data,
    HttpOptions<R, T>? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return requestUri(
      method: Method.post,
      uri: uri,
      data: data,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  @override
  Future<R> put({
    String? path,
    Object? data,
    Parameters? queryParameters,
    HttpOptions<R, T>? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return request(
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

  @override
  Future<R> putUri({
    Uri? uri,
    Object? data,
    HttpOptions<R, T>? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return requestUri(
      method: Method.put,
      uri: uri,
      data: data,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  @override
  Future<R> request({
    String? path,
    Method? method,
    Object? data,
    Parameters? queryParameters,
    CancelToken? cancelToken,
    HttpOptions<R, T>? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    Converter<R, T>? converter,
  }) async {
    converter ??= this.converter;

    try {
      final response = await fetch(
        path: path,
        method: method,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return converter.success(response);
    } on DioException catch (e) {
      return converter.exception(e);
    } catch (e) {
      return converter.error(e);
    }
  }

  @override
  Future<R> requestUri({
    Uri? uri,
    Method? method,
    Object? data,
    CancelToken? cancelToken,
    HttpOptions<R, T>? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return request(
      path: uri?.toString(),
      method: method,
      data: data,
      cancelToken: cancelToken,
      options: options,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }
}
