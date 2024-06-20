// ignore_for_file: constant_identifier_names, depend_on_referenced_packages

import 'package:example/model.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:sm_network/sm_network.dart';

const Bob = {
  "name": "Bob",
  "age": 20,
  "gender": "male",
  "birthday": "2012-02-27 13:27:00",
  "adulthood": 1641031200000,
  "friends": [
    Jack,
    Tom,
  ],
};
const Jack = {
  "name": "Jack",
  "age": 18,
  "gender": "male",
  "birthday": "2014-05-13 10:57:45",
  "friends": [
    Tom,
  ],
};
const Tom = {
  "name": "Tom",
  "age": 30,
  "gender": "male",
  "birthday": "2002-03-17 15:37:10",
  "friends": [
    {
      "name": "Jack",
      "age": 18,
      "gender": "male",
    },
    {
      "name": "Bob",
      "age": 20,
      "gender": "male",
    },
  ],
};

const listData = [
  Bob,
  Jack,
  Tom,
];

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

abstract class APIRequest<T> extends APISession<T> {
  /// 重写 [createResponder]，用于创建 [BaseModel] 对象
  @override
  BaseModel<T> createResponder(data) {
    return BaseModel.fromJson(data, fromJsonT: fromJson, parseJsonT: parseJson);
  }
}

class GetList01API extends APIRequest<List<int>> {
  GetList01API() {
    dioAdapter(
      dio,
      url,
      [
        [1, 2],
        [2, 2],
        [3, 2],
      ],
    );
  }

  @override
  List<int> fromJson(json) {
    return (json as List).cast<int>();
  }

  @override
  String get path => '/getList01';
}

class GetListAPI extends APIRequest<Person> {
  GetListAPI() {
    dioAdapter(dio, url, listData);
  }

  @override
  ParseJsonT<Person> get parseJson => Person.fromJson;

  @override
  String get path => '/getList';
}

class GetMapAPI extends APIRequest<Person> {
  GetMapAPI() {
    dioAdapter(dio, url, Bob);
  }

  @override
  ParseJsonT<Person> get parseJson => Person.fromJson;

  @override
  String get path => '/getMap';
}

class GetNumAPI extends APIRequest<num> {
  GetNumAPI() {
    dioAdapter(dio, url, 1234567890);
  }

  @override
  String get path => '/getNum';
}

class GetStringAPI extends APIRequest<String> {
  GetStringAPI() {
    dioAdapter(dio, url, 'Hello World!');
  }

  @override
  String get path => '/getString';
}

class GetTimeOutAPI extends APIRequest<String> {
  GetTimeOutAPI() {
    dio.interceptors.add(TimeoutInterceptor());
    dioAdapter(dio, url, 'Hello World TimeOut!');
  }

  @override
  String get path => '/getTimeOut';

  @override
  Duration? get receiveTimeout => const Duration(seconds: 1);

  @override
  Duration? get sendTimeout => const Duration(seconds: 1);
}

class PostStringAPI extends APIRequest<String> {
  PostStringAPI() {
    dioAdapter(
      dio,
      url,
      'Post Hello World!',
      method: method,
    );
  }

  @override
  HTTPMethod get method => HTTPMethod.POST;

  // @override
  // Object? get body => FormData.fromMap({
  //       'content': 'Post Hello World!',
  //     });

  @override
  Parameters? get parameters => {
        'method': "POST",
        'content': 'Post Hello World!',
        'content-cn': '你好世界！',
      };

  @override
  String get path => '/postString';

  // @override
  // bool get useBody => true;
}

class RefreshAPI extends APIPageableSession<int> {
  RefreshAPI({required super.pageable});

  @override
  String get path => '/getPageable';

  @override
  Future<APIResponder<int>> request({
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
    dioAdapter(
      dio,
      url,
      List.generate(
          pageable.pageSize, (index) => 10 * (pageable.pageNumber - 1) + index),
      delay: const Duration(seconds: 1),
    );
    return super.request(
      method: method,
      data: data,
      queryParameters: queryParameters ?? pageableParameters,
      options: options,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
      useBody: useBody,
      bodyFormat: bodyFormat,
      isCached: isCached,
    );
  }
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
