// ignore_for_file: avoid_print

import 'dart:developer';

import 'package:example/model.dart';
import 'package:flutter/material.dart';
import 'package:sm_network/sm_network.dart';

void main(List<String> args) {
  Http.shared.config(
    options: HttpBaseOptions(
      baseUrl: 'https://httpbin.org/',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      validateStatus: (status) => status != null && status == 200,
      responseType: ResponseType.json,
      contentType: ContentType.json,
      headers: {
        'user-agent': 'sm_network',
        'common-header': 'xx',
        'accept-encoding': 'application/json',
      },
      log: HttpLog(
        options: LogOptions.allow(
          enable: true,
          headers: true,
          data: true,
          extra: false,
          queryParameters: true,
          responseData: true,
          curl: true,
          stream: false,
          bytes: false,
        ),
        error: (error, stackTrace) {
          log('$error\n$stackTrace', name: 'Error');
        },
      ),
      converterOptions: DefaultConverterOptions(
        code: 'json.code',
        data: 'json.data',
        message: 'json.message',
        status: (status, data) => status == 200,
      ),
    ),
    interceptors: [
      HttpLogInterceptor(
        maxWidth: 120,
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
      ),
    ],
  );

  runApp(MaterialApp(home: App()));
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  Person? person;

  @override
  void initState() {
    super.initState();

    request();
  }

  Future request() async {
    final resp = await PostSession().request();
    print(resp);
    if (resp.isSuccess) {
      setState(() {
        person = resp.data;
      });
    } else {
      print(resp.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Hello World'),
            Text('姓名: ${person?.name}'),
            Text('年龄: ${person?.age}'),
            Text('生日: ${person?.birth}'),
            Text('year: ${person?.year}'),
            Text('month: ${person?.month}'),
            Text('day: ${person?.day}'),
            Text('hour: ${person?.hour}'),
            Text('minute: ${person?.minute}'),
            Text('second: ${person?.second}'),
            Text('millisecond: ${person?.millisecond}'),
            Text('microsecond: ${person?.microsecond}'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          request();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class PostSession extends Session<Person> {
  @override
  Object? get data => {
        'code': 200,
        'data': {
          'name': 'Shay',
          'age': 18,
          'birth': '2000-01-01 12:10:30',
          'microsecond': 1746225650489000,
          'millisecond': 1746225650489,
          'second': 1746225650,
          'minute': 29103761,
          'hour': 485063,
          'day': 20211,
          'month': 674,
          'year': 56,
        },
        'message': 'success',
      };

  @override
  String? get path => '/post';

  @override
  FromJsonT<Person>? get fromJsonT => Person.fromJson;

  @override
  Method? get method => Method.post;
}
