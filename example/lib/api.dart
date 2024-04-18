import 'package:example/model.dart';
// ignore: depend_on_referenced_packages
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:sm_network/sm_network.dart';

class GetListAPI extends APIRequest<Person> {
  GetListAPI() {
    final dioAdapter = DioAdapter(dio: dio);

    dioAdapter.onGet(
      url,
      (server) => server.reply(
        200,
        {
          'code': 1,
          'data': [
            {
              "name": "Bob",
              "age": 20,
              "gender": "male",
            },
            {
              "name": "Jack",
              "age": 18,
              "gender": "male",
            },
            {
              "name": "Tom",
              "age": 30,
              "gender": "male",
            },
          ],
          'message': 'Success!',
        },
        // Reply would wait for one-sec before returning data.
        delay: const Duration(seconds: 1),
      ),
    );
  }

  @override
  ParseJsonT<Person> get parseJson => Person.fromJson;

  @override
  String get url => '/getList';
}

class GetMapAPI extends APIRequest<Person> {
  GetMapAPI() {
    final dioAdapter = DioAdapter(dio: dio);

    dioAdapter.onGet(
      url,
      (server) => server.reply(
        200,
        {
          'code': 1,
          'data': {
            "name": "Bob",
            "age": 20,
            "gender": "male",
          },
          'message': 'Success!',
        },
        // Reply would wait for one-sec before returning data.
        delay: const Duration(seconds: 1),
      ),
    );
  }

  @override
  ParseJsonT<Person> get parseJson => Person.fromJson;

  @override
  String get url => '/getMap';
}

class GetNumAPI extends APIRequest<num> {
  GetNumAPI() {
    final dioAdapter = DioAdapter(dio: dio);

    dioAdapter.onGet(
      url,
      (server) => server.reply(
        200,
        {
          'code': 1,
          'data': 1234567890,
          'message': 'Success!',
        },
        // Reply would wait for one-sec before returning data.
        delay: const Duration(seconds: 1),
      ),
    );
  }

  @override
  String get url => '/getNum';
}

class GetStringAPI extends APIRequest<String> {
  GetStringAPI() {
    final dioAdapter = DioAdapter(dio: dio);

    dioAdapter.onGet(
      url,
      (server) => server.reply(
        200,
        {
          'code': 1,
          'data': 'Hello World!',
          'message': 'Success!',
        },
        // Reply would wait for one-sec before returning data.
        delay: const Duration(seconds: 1),
      ),
    );
  }

  @override
  String get url => '/getString';
}
