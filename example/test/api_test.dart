import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:sm_network/sm_network.dart';

void main() {
  APICore.initialize(
    config: APIConfig(
      baseUrl: 'https://example.com',
      connectTimeout: const Duration(seconds: 1),
      receiveTimeout: const Duration(seconds: 1),
      sendTimeout: const Duration(seconds: 1),
      postBodyByDefault: true,
      postBodyFormat: BodyFormat.multipart,
      postUseFormData: true,
    ),
  );

  test(
    'test get',
    () async {
      final api = API(url: 'https://example.com/test');
      dioAdapter(api.dio, api.url, 'Hello World!');
      // 获取请求结果并断言
      final res = await api.fetch(method: HTTPMethod.GET);
      expect(res, 'Hello World!');
      // 使用 expectAsync1 断言异步操作
      await api.fetch(method: HTTPMethod.GET).then(expectAsync1((data) {
        expect(data, 'Hello World!');
      }));
      // 断言异步函数返回值
      expect(
        api.fetch(method: HTTPMethod.GET),
        completion(equals('Hello World!')),
      );
      // 使用 expectLater 和 completion 断言异步操作的结果
      expectLater(
        api.fetch(method: HTTPMethod.GET),
        completion(equals('Hello World!')),
      );
    },
  );
}

void dioAdapter<T>(
  Dio dio,
  String url,
  T responseData, {
  HttpRequestMatcher? matcher,
  Duration? delay,
  HTTPMethod? method,
  dynamic data,
  Map<String, dynamic>? queryParameters,
  Map<String, dynamic>? headers,
}) {
  final dioAdapter = DioAdapter(
    dio: dio,
    // 注意匹配規則，如果不匹配，那么会报错 Could not find mocked route matching request
    // 改成只匹配 url 和 method
    matcher: matcher ?? const UrlRequestMatcher(matchMethod: true),
  );

  dioAdapter.onRoute(
    url,
    (server) => server.reply(
      200,
      {
        'code': 1,
        'data': responseData,
        'message': 'Success!',
      },
      // Reply would wait for one-sec before returning data.
      delay: delay ?? const Duration(seconds: 1),
    ),
    request: Request(
      route: url,
      method: RequestMethods.forName(name: method?.name ?? 'GET'),
      data: data,
      queryParameters: queryParameters,
      headers: headers,
    ),
  );
}
