import 'package:example/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sm_network/sm_network.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  APICore.initialize(
    APIConfig(
      baseUrl: 'https://raw.onmicrosoft.cn',
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    load();
  }

  load() async {
    final bing = await BingAPI().fetchList();
    print(bing);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Hello World!'),
        ),
        body: Center(
          child: Container(
            color: Colors.red,
            child: const Text('Hello World!'),
          ),
        ),
      ),
    );
  }
}
