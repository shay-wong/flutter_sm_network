import 'package:flutter/foundation.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../core/api_config.dart';
import '../responder/api_error.dart';
import '../responder/api_responder.dart';
import 'api_mixin.dart';

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

abstract class APIPageableSession<T> with APIOptions<T>, APIDioMixin<T, APIResponder<T>> {
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
  Future<APIResponder<T>> request({bool isCached = true}) async {
    return super.request(isCached: isCached).then(
      (value) {
        if (value.isSuccess) {
          loader.controller.refreshCompleted();
          (value.dataList?.length ?? 0) < loader.pageSize
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

  Future<List<T>?> refresh({bool isCached = true}) {
    loader.isRefresh = true;
    return super.fetchList(isCached: isCached);
  }

  Future<List<T>?> load({bool isCached = true}) {
    loader.isRefresh = false;
    return super.fetchList(isCached: isCached);
  }
}


abstract class APISession<T> with APIOptions<T>, APIDioMixin<T, APIResponder<T>> {}
