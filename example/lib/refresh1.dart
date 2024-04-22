import 'package:example/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sm_network/sm_network.dart';

class Refresh1 extends StatefulWidget {
  const Refresh1({super.key});

  @override
  State<Refresh1> createState() => _RefreshState();
}

class _RefreshState extends State<Refresh1> {
  List<int> datas = [];

  final APIPageable loader = APIPageable();
  final RefreshController _refreshController = RefreshController();

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
      body: SmartRefresher(
        onRefresh: () async {
          datas = await RefreshAPI(pageable: loader).refresh() ?? [];
          _refreshController.refreshCompleted();
          setState(() {});
        },
        onLoading: () async {
          final res = await RefreshAPI(pageable: loader).load() ?? [];
          _refreshController.loadComplete();
          datas.addAll(res);
          setState(() {});
        },
        controller: _refreshController,
        header: const WaterDropHeader(
          idleIcon: Icon(
            Icons.autorenew,
            size: 15,
            color: Colors.white,
          ),
          waterDropColor: Colors.grey,
          complete: Text('刷新完成'),
        ),
        enablePullDown: true,
        enablePullUp: true,
        footer: CustomFooter(
          builder: (context, mode) {
            Widget body;
            switch (mode) {
              case LoadStatus.idle:
                body = const Text('上拉加载');
                break;
              case LoadStatus.loading:
                body = const CupertinoActivityIndicator();
                break;
              case LoadStatus.canLoading:
                body = const Text('放开加载更多');
                break;
              case LoadStatus.failed:
                body = const Text('加载失败， 点击重试');
                break;
              case LoadStatus.noMore:
                body = const Text('没有更多啦');
                break;
              default:
                body = const Text('');
            }
            return SizedBox(
              height: 55.0,
              child: Center(child: body),
            );
          },
        ),
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
