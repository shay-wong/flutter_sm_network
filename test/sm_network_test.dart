// ignore_for_file: avoid_print, unreachable_from_main

import 'dart:io' show HttpHeaders;

import 'package:flutter_test/flutter_test.dart';
import 'package:sm_network/sm_network.dart';

import 'mock_interceptor.dart';
import 'models.dart';
import 'sessions.dart';

void main() {
  Http.shared.config(
    options: HttpBaseOptions(
      baseUrl: 'https://example.com',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      validateStatus: (status) => status != null && status == 200,
      headers: {
        HttpHeaders.userAgentHeader: 'net',
        'common-header': 'xx',
        Headers.acceptHeader: 'application/json',
      },
      log: HttpLog(error: (error, stackTrace) => print('$error\n$stackTrace')),
      // ignore: avoid_redundant_argument_values
      converterOptions: const DefaultConverterOptions(
        // ignore: avoid_redundant_argument_values
        code: 'code',
        // ignore: avoid_redundant_argument_values
        data: 'data',
        // ignore: avoid_redundant_argument_values
        message: 'message',
        // ignore: avoid_redundant_argument_values
        status: 'status',
      ),
    ),
    interceptors: [
      // 模拟网络请求，返回 extra 中的数据
      MockInterceptor(),
    ],
  );

  test('GetStringSession', () async {
    final response = await GetStringSession().request();
    print('$response');
  });
  test('Net GetStringSession', () async {
    final resp =
        await Net.session(path: '/getString', extra: Extra(responseData: 'Hello World').toJson())
            .get();
    print(resp);
  });
  test('GetNumSession', () async {
    final response = await GetNumSession().request();
    print(response);
  });
  test('GetObjSession', () async {
    final response = await GetObjSession().request();
    print(response);
  });
  test('GetObjsSession', () async {
    final response = await GetObjsSession().request();
    print(response);
  });
  test('GetErrorSession', () async {
    final response = await GetErrorSession().request();
    print(response);
  });

  test('ContentTypeSession', () async {
    final resp =
        // ignore: avoid_redundant_argument_values
        await ContentTypeSession(contentType: ContentType.raw, data: 'Hello World').request();
    print(resp);
    final resp1 = await ContentTypeSession(contentType: ContentType.json).request();
    print(resp1);
    final resp2 = await ContentTypeSession(contentType: ContentType.multipart).request();
    print(resp2);
    final resp3 = await ContentTypeSession(contentType: ContentType.urlencoded).request();
    print(resp3);
  });
}
