import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../responder/api_error.dart';
import '../responder/api_responder.dart';
import 'api_session.dart';

class APIPageableLoader {
  APIPageableLoader({
    this.pageNum = 1,
    this.pageSize = 10,
    bool initialRefresh = false,
    RefreshStatus? initialRefreshStatus,
    LoadStatus? initialLoadStatus,
  })  : _firstPage = pageNum,
        controller = RefreshController(
          initialRefresh: initialRefresh,
          initialRefreshStatus: initialRefreshStatus,
          initialLoadStatus: initialLoadStatus,
        );

  final RefreshController controller;

  // 第几页
  int pageNum;

  // 每页大小
  final int pageSize;

  // 第一页
  final int _firstPage;

  // 是否是刷新
  bool _isRefresh = true;

  bool get isRefresh => _isRefresh;

  set isRefresh(bool ref) {
    _isRefresh = ref;
    if (_isRefresh) {
      pageNum = _firstPage;
      controller.resetNoData();
    } else {
      pageNum++;
    }
  }

  void dispose() {
    controller.dispose();
  }
}

class APIPageableSession<T> extends APISessionList<T> {
  // NOTE: 如果 loader 传的是空属性不能使用刷新控件,但是可以分页请求.
  APIPageableSession({
    required APIPageableLoader? loader,
  }) : loader = loader ?? APIPageableLoader();

  final APIPageableLoader loader;

  @override
  @mustCallSuper
  Parameters get parameters => {
        'pageNum': loader.pageNum,
        'pageSize': loader.pageSize,
      };

  @override
  Future<APIResponder<List<T>>> request({bool isCached = true}) async {
    return super.request(isCached: isCached).then(
      (value) {
        if (value.isSuccess) {
          loader.controller.refreshCompleted();
          (value.data?.length ?? 0) < loader.pageSize
              ? loader.controller.loadNoData()
              : loader.controller.loadComplete();
        } else {
          loader.controller.loadFailed();
          if (!loader.isRefresh) {
            loader.pageNum--;
          }
        }
        return value;
      },
    ).onError((error, stackTrace) {
      loader.controller.refreshFailed();
      if (!loader.isRefresh) {
        loader.pageNum--;
      }
      return Future.error(error ?? APIError.error());
    });
  }
}

abstract class APISessionList<T> with APISession<List<T>> {
  @override
  List<T> Function(dynamic json) get responder =>
      (json) => (json as List).map((e) => e is Parameters ? toObject(e) : e as T).toList();

  T toObject(Parameters p) => p as T;
}
