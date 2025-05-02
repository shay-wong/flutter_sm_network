// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:sm_network/sm_network.dart';

Future<void> main(List<String> args) async {
  Http.shared.config(
    options: HttpBaseOptions(
      baseUrl: 'https://httpbin.org/',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      validateStatus: (status) => status != null && status == 200,
      headers: {
        'user-agent': 'sm_network',
        'common-header': 'xx',
        'accept': 'application/json'
      },
      log: HttpLog(
        options: LogOptions(
          curl: true,
          data: true,
          extra: true,
          headers: true,
          queryParameters: true,
          responseData: true,
          enable: true,
          stream: true,
          bytes: true,
        ),
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
    interceptors: [HttpLogInterceptor()],
  );

  runApp(MaterialApp(home: App()));
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();

    request();
  }

  Future request() async {
    final resp = await GetSession().request();
    print(resp);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Hello World')));
  }
}

class GetSession extends Session {
  @override
  Parameters? get parameters => {'name': 'Shay', 'age': 18};

  @override
  String? get path => '/get';
}
