// ignore_for_file: avoid_redundant_argument_values, avoid_print

import 'package:sm_network/sm_network.dart';

void configHttp({
  String? baseUrl,
  Map<String, dynamic>? headers,
  Iterable<Interceptor>? interceptors,
  HttpClientAdapter? httpClientAdapter,
}) {
  Http.shared.config(
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
        error: (error, stackTrace) => print('$error\n$stackTrace'),
      ),
      converterOptions: DefaultConverterOptions(
        code: 'code',
        data: 'data',
        message: 'message',
        status: (status, data) => status == 1,
      ),
    ),
    interceptors: [
      ...?interceptors,
      HttpLogInterceptor(),
    ],
  );
}
