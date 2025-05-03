import 'package:sm_network/sm_network.dart';

Future<void> main(List<String> args) async {
  configHttp(baseUrl: 'https://httpbin.org/');

  await session1();
  await session2();
  await session3();
  await session4();
}

void configHttp({
  String? baseUrl,
  Map<String, dynamic>? headers,
  HttpClientAdapter? httpClientAdapter,
}) {
  // Or you can create dio instance and config it as follow:
  //  final dio = Dio(BaseOptions(
  //    baseUrl: "http://www.dtworkroom.com/doris/1/2.0.0/",
  //    connectTimeout: const Duration(seconds: 5),
  //    receiveTimeout: const Duration(seconds: 5),
  //    headers: {
  //      HttpHeaders.userAgentHeader: 'dio',
  //      'common-header': 'xx',
  //    },
  //  ));
  Http.shared.config(
    // dio: dio,
    options: HttpBaseOptions(
      baseUrl: baseUrl ?? '',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      validateStatus: (status) => status != null && status == 200,
      headers: {
        'user-agent': 'sm_network',
        'common-header': 'xx',
        ...?headers,
      },
      log: HttpLog(
        options: LogOptions.allow(),
        error: (error, stackTrace) {
          print('$error\n$stackTrace');
        },
      ),
      converterOptions: DefaultConverterOptions(
        code: 'code',
        data: 'data',
        message: 'message',
        status: (status, data) => status == 1,
      ),
    ),
    interceptors: [
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('InterceptorsWrapper onRequest');
          // return handler.resolve( Response(data:"xxx"));
          // return handler.reject( DioException(message: "eh"));
          return handler.next(options);
        },
      ),
      HttpLogInterceptor(
          // onRequest: (response, handler) {
          //   print('HttpLogInterceptor onRequest');
          //   return handler.next(response);
          // },
          // onResponse: (response, handler) {
          //   print('HttpLogInterceptor onResponse');
          //   return handler.next(response);
          // },
          // onError: (response, handler) {
          //   print('HttpLogInterceptor onError');
          //   return handler.next(response);
          // },
          )
    ],
    httpClientAdapter: httpClientAdapter,
  );
}

Future session1() async {
  // Get
  final response = await Http.get(path: 'https://pub.dev/');
  print(response);
}

Future session2() async {
  // Download a file
  final response = await Http.download(
    path: 'https://pub.dev/',
    savePath: './download/xx.html',
    queryParameters: {'a': 1},
    onReceiveProgress: (received, total) {
      print('received: $received, total: $total');
    },
  );
  print(response);
}

Future session3() async {
  // Create a FormData
  final formData = FormData.fromMap({
    'age': 25,
    'file': await MultipartFile.fromFile(
      '../assets/upload.txt',
      filename: 'upload.txt',
    ),
  });

  // Send FormData
  final response = await Http.post(path: '/test', data: formData);
  print(response);
}

Future session4() async {
  // post data with "application/x-www-form-urlencoded" format
  final response = await Http.post(
    path: '/test',
    data: {
      'id': 8,
      'info': {
        'name': 'wendux',
        'age': 25,
      },
    },
    options: HttpOptions(
      contentType: ContentType.urlencoded,
    ),
  );
  print(response);
}
