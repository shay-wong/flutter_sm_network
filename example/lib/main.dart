import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sm_network/sm_network.dart';

import 'api.dart';
import 'refresh.dart';
import 'refresh1.dart';

void main() {
  APICore.initialize(
    config: APIConfig(
      baseUrl: 'https://example.com',
      connectTimeout: const Duration(seconds: 1),
      receiveTimeout: const Duration(seconds: 1),
      sendTimeout: const Duration(seconds: 1),
      postBodyByDefault: true,
      postBodyFormat: BodyFormat.multipart,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
      // home: const Refresh(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void dPrint(Object? object) {
    if (kDebugMode) {
      print(object);
    }
  }

  void fetch(APIRequest request) {
    request.fetch().then((value) => dPrint(value));
  }

  void fetchList(APIRequest request) {
    request.fetchList().then((value) => dPrint(value));
  }

  load() async {
    // data 是 String
    fetch(GetStringAPI());
    fetch(PostStringAPI());
    // data 是 Number
    fetch(GetNumAPI());
    // data 是 Map
    fetch(GetMapAPI());
    fetchList(GetListAPI());
    // 如果返回的 data 是 list, 那么fetch 返回的就是 null， 应该要用 fetchList
    fetch(GetList01API());
    // data 是 List 使用
    fetchList(GetList01API());
    // 超时请求
    fetch(GetTimeOutAPI());
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });

    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return const Refresh();
                  },
                ),
              );
            },
            child: const Text('Refresh'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return const Refresh1();
                  },
                ),
              );
            },
            child: const Text('Refresh1'),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
