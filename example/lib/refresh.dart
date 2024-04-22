import 'package:easy_refresh/easy_refresh.dart';
import 'package:example/api.dart';
import 'package:flutter/material.dart';
import 'package:sm_network/sm_network.dart';

class Refresh extends StatefulWidget {
  const Refresh({super.key});

  @override
  State<Refresh> createState() => _RefreshState();
}

class _RefreshState extends State<Refresh> {
  List<int> datas = [];

  final APIPageable loader = APIPageable();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Refresh'),
      ),
      body: EasyRefresh(
        onRefresh: () async {
          datas = await RefreshAPI(pageable: loader).refresh() ?? [];
          setState(() {});
        },
        onLoad: () async {
          final res = await RefreshAPI(pageable: loader).load() ?? [];
          datas.addAll(res);
          setState(() {});
        },
        child: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            final data = datas[index];
            return ListTile(title: Text('$data'));
          },
          itemCount: datas.length,
        ),
      ),
    );
  }
}
