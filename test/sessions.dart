import 'package:sm_network/sm_network.dart';

import 'models.dart';

class GetErrorSession extends Session<String> with HttpMockAdapter {
  @override
  String get path => '/getError';

  @override
  Map<String, Object> get response => {
        'code': -1,
        'message': 'error',
      };

  @override
  bool get status => false;

  @override
  int? get statusCode => 400;
}

class GetNumSession extends Session<num> with HttpMockAdapter {
  GetNumSession();

  @override
  String get path => '/getNum';

  @override
  num? get responseData => 1234567890;

  @override
  ResponseType? get responseType => ResponseType.plain;
}

class GetObjSession extends Session<Person> with HttpMockAdapter {
  GetObjSession();

  @override
  FromJsonT<Person>? get fromJsonT => Person.fromJson;

  @override
  String get path => '/getObj';

  @override
  Person? get responseData => Person('Shay', 18);
}

class GetObjsSession extends Session<Person> with HttpMockAdapter {
  GetObjsSession();

  @override
  FromJsonT<Person>? get fromJsonT => Person.fromJson;

  @override
  String get path => '/getObjs';

  @override
  List<Person> get responseData => [
        Person('Shay', 18),
        Person('Bob', 20),
      ];
}

class GetStringSession extends Session<String> with HttpMockAdapter {
  GetStringSession();

  @override
  String get path => '/getString';

  @override
  String? get responseData => 'Hello World!';
}

class ContentTypeSession extends Session with HttpMockAdapter {
  ContentTypeSession({
    this.contentType = ContentType.raw,
    this.data = const {'name': 'Shay Wong', 'age': 18},
  });

  @override
  String? get path => '/contentType';

  @override
  ContentType? contentType;

  @override
  Object? data;

  @override
  Object? get responseData => data;
}

/// 模拟請求
mixin HttpMockAdapter<T> on Session<T> {
  @override
  Parameters? get extra => Extra(
        responseData: responseData,
        response: response,
        status: status,
        statusCode: statusCode,
      ).toJson();

  dynamic get response => null;
  dynamic get responseData => null;
  bool get status => true;
  int? get statusCode => null;
}
