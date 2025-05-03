part of 'log_interceptor.dart';

mixin _InterceptorWrapperMixin on Interceptor {
  InterceptorSendCallback? _onRequest;
  InterceptorSuccessCallback? _onResponse;
  InterceptorErrorCallback? _onError;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (_onRequest != null) {
      _onRequest!(options, handler);
    } else {
      handler.next(options);
    }
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (_onResponse != null) {
      _onResponse!(response, handler);
    } else {
      handler.next(response);
    }
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    if (_onError != null) {
      _onError!(err, handler);
    } else {
      handler.next(err);
    }
  }
}
