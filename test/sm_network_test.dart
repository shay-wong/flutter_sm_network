// ignore_for_file: avoid_print, avoid_redundant_argument_values

import 'package:flutter_test/flutter_test.dart';
import 'package:sm_network/sm_network.dart';

import 'config.dart';
import 'mock_interceptor.dart';
import 'models.dart';
import 'sessions.dart';

void main() {
  configHttp(
    baseUrl: 'https://example.com',
    headers: {
      'accept': 'application/json',
    },
    interceptors: [
      MockInterceptor(),
    ],
  );

  test('GetStringSession', () async {
    final response = await GetStringSession().request();
    print('$response');
    expect(response.data, 'Hello World!');
  });

  test('Net GetStringSession', () async {
    final response =
        await Http.session(path: '/getString', extra: Extra(responseData: 'Hello World').toJson())
            .get();
    print(response);
    expect(response.data, 'Hello World');
  });

  test('GetNumSession', () async {
    final response = await GetNumSession().request();
    print(response);
    expect(response.data, 1234567890);
  });

  test('GetObjSession', () async {
    final response = await GetObjSession().request();
    print(response);
    expect(response.data, isA<Person>());
  });

  test('GetObjsSession', () async {
    final response = await GetObjsSession().request();
    print(response);
    expect(response.list, isA<List<Person>>());
  });

  test('GetPageableSession', () async {
    final response = await GetPageableSession().request();
    print(response);
    expect(response.list, isA<List<Person>>());

    final response1 = await GetPageableSession(pageNumber: 2).request();
    print(response1);
    expect(response.list, isA<List<Person>>());
  });

  test('GetErrorSession', () async {
    final response = await GetErrorSession().request();
    print(response.isSuccess);
    expect(response.isSuccess, false);
  });

  test('ContentTypeSession', () async {
    final response = await ContentTypeSession(
      contentType: ContentType.raw,
      data: 'Hello World',
    ).fetch();
    print(response);

    expect(response.requestOptions.data, 'Hello World');

    final response1 = await ContentTypeSession(
      contentType: ContentType.json,
    ).request();
    print(response1);

    final response2 = await ContentTypeSession(
      contentType: ContentType.multipart,
    ).request();
    print(response2);

    final response3 = await ContentTypeSession(
      contentType: ContentType.urlencoded,
    ).request();
    print(response3);
  });

  test('TimeoutSession', () async {
    final response = await TimeoutSession().request();
    print(response.dioException);
    expect(response.dioException?.type, DioExceptionType.receiveTimeout);
  });
}
