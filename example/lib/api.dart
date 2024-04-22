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
  T data, {
  Duration? delay,
}) {
  final dioAdapter = DioAdapter(dio: dio);

  dioAdapter.onGet(
    url,
    (server) => server.reply(
      200,
      {
        'code': 1,
        'data': data,
        'message': 'Success!',
      },
      // Reply would wait for one-sec before returning data.
      delay: delay ?? const Duration(seconds: 1),
    ),
  );
}

abstract class APIRequest<T> with APIOptions<T>, APIDioMixin<T, BaseModel<T>>, APISessionMixin {
  @override
  BaseModel<T> createResponder(data) {
    return BaseModel.fromJson(data, fromJsonT: fromJson, parseJsonT: parseJson);
  }
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

class GetList01API extends APIRequest<List<int>> {
  GetList01API() {
    dioAdapter(dio, url, [
      [1, 2],
      [2, 2],
      [3, 3]
    ]);
  }

  @override
  String get path => '/getList01';

  @override
  List<int> fromJson(json) {
    return (json as List<dynamic>).cast<int>();
  }
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
    dio.interceptors.add(TimeoutInterceptor());
    dioAdapter(
      dio,
      url,
      'Hello World!',
      delay: const Duration(seconds: 5),
    );
  }

  @override
  Duration? get sendTimeout => const Duration(seconds: 1);

  @override
  Duration? get receiveTimeout => const Duration(seconds: 1);

  @override
  String get path => '/getString';
}

class RefreshAPI extends APIPageableSession<int> {
  RefreshAPI({required super.pageable});

  @override
  Future<APIResponder<int>> request({
    HTTPMethod? method,
    Parameters? queryParameters,
    bool isCached = true,
    Options? options,
  }) {
    dioAdapter(
      dio,
      url,
      List.generate(pageable.pageSize, (index) => 10 * (pageable.pageNum - 1) + index),
      delay: const Duration(seconds: 1),
    );
    return super.request(
      method: method,
      queryParameters: queryParameters,
      isCached: isCached,
      options: options,
    );
  }

  @override
  String get path => '/getPageable';
}

class TimeoutInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.next(options);
    // 延迟请求，模拟超时
    // Future.delayed(const Duration(seconds: 6)).then((_) {
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
    Future.delayed(const Duration(seconds: 3)).then((_) {
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
