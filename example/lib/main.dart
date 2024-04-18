import 'package:example/api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sm_network/sm_network.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  APICore.initialize(
    APIConfig(
      baseUrl: 'https://example.com',
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
    final string = await GetStringAPI().fetch();
    final num = await GetNumAPI().fetch();
    final person = await GetMapAPI().fetch();
    final persons = await GetListAPI().fetchList();

    if (kDebugMode) {
      print(string);
      print(num);
      print(person);
      print(persons);
    }
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
