import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:sm_network/sm_network.dart';

class MockInterceptor extends Interceptor {
  MockInterceptor({
    this.matcher,
    this.delay,
  });

  final Duration? delay;
  final HttpRequestMatcher? matcher;

  /// 模拟失敗請求
  Parameters failedResponse(dynamic responseData) => {
        'code': -1,
        'data': responseData,
        'message': 'Failed!',
        'status': false,
      };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final extra = options.extra;
    final responseData = extra['response_data'];
    final response = extra['response'];
    final status = extra['status'] as bool? ?? false;
    final statusCode = extra['statusCode'] as int?;

    DioAdapter(
      dio: Http.dio,
      // 注意匹配規則，如果不匹配，那么会报错 Could not find mocked route matching request
      // 改成只匹配 url 和 method
      matcher: matcher ?? const UrlRequestMatcher(matchMethod: true),
    ).onRoute(
      options.path,
      (server) => server.reply(
        statusCode ?? 200,
        response ??
            (responseData != null
                ? status
                    ? successResponse(responseData)
                    : failedResponse(responseData)
                : null),
        // Reply would wait for one-sec before returning data.
        delay: delay ?? const Duration(seconds: 1),
      ),
      request: Request(
        route: options.path,
        method: RequestMethods.forName(name: options.method),
        data: options.data,
        queryParameters: options.queryParameters,
        headers: options.headers,
      ),
    );

    super.onRequest(options, handler);
  }

  /// 模拟成功請求
  Parameters successResponse(dynamic responseData) => {
        'code': 1,
        'data': responseData,
        'message': 'Success!',
        'status': true,
      };
}

class TimeoutInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.next(options);
    // 延迟请求，模拟超时
    // Future.delayed(const Duration(seconds: 2)).then((_) {
    // 正常继续请求
    // 或者直接抛出超时异常
    // handler.reject(
    //   DioException.connectionTimeout(
    //     timeout: const Duration(seconds: 1),
    //     requestOptions: options,
    //     error: 'connection timeout',
    //   ),
    //   true,
    // );
    // });
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 延迟请求，模拟超时
    Future.delayed(const Duration(seconds: 2)).then((_) {
      // 正常继续请求
      // handler.next(options);
      // 或者直接抛出超时异常
      handler.reject(
        DioException.receiveTimeout(
          timeout: const Duration(seconds: 1),
          requestOptions: response.requestOptions,
          error: 'receive timeout',
        ),
        true,
      );
    });
  }
}
