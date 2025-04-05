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
      headers: {'user-agent': 'sm_network', 'common-header': 'xx', 'accept': 'application/json'},
      log: HttpLog(
        error: (error, stackTrace) {
          print('$error\n$stackTrace');
        },
      ),
      // ignore: avoid_redundant_argument_values
      converterOptions: DefaultConverterOptions(
        // ignore: avoid_redundant_argument_values
        code: 'code',
        // ignore: avoid_redundant_argument_values
        data: 'data',
        // ignore: avoid_redundant_argument_values
        message: 'message',
        // ignore: avoid_redundant_argument_values
        status: (status, data) => status == 1,
      ),
    ),
    interceptors: [LogcatInterceptor()],
  );

  runApp(MaterialApp(home: App()));
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  Future request() async {
    final resp = await GetSession().request();
    print(resp);
  }

  @override
  void initState() {
    super.initState();

    request();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Hello World')));
  }
}

class GetSession extends Session {
  @override
  String? get path => '/get';

  @override
  Parameters? get parameters => {'name': 'Shay', 'age': 18};
}
