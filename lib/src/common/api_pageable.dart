import 'package:dio/dio.dart';
import 'package:sm_logger/sm_logger.dart';

import '../core/api_config.dart';
import '../responder/api_responder.dart';
import 'api_mixin.dart';

class APIPageable {
  APIPageable({
    int pageNum = 1,
    this.pageSize = 10,
  })  : _pageNum = pageNum,
        assert(pageNum >= 0 && pageSize >= 0, 'pageNum and pageSize must >= 0'),
        _firstPage = pageNum;

  bool isNoMoreData = false;
  // 每页大小
  final int pageSize;

  // 第一页
  final int _firstPage;

  // 是否是刷新
  bool _isRefresh = true;

  // 第几页
  int _pageNum;

  bool get isRefresh => _isRefresh;
  int get pageNum => _pageNum;

  set isRefresh(bool ref) {
    _isRefresh = ref;
    if (_isRefresh) {
      pageNum = _firstPage;
    } else {
      pageNum++;
    }
  }

  set pageNum(int value) {
    _pageNum = value;
    logger.d(value);
  }
}

mixin APIPageableMixin<T> on APIDioMixin<T, APIResponder<T>> {
  @override
  Future<APIResponder<T>> request({
    HTTPMethod? method,
    Parameters? queryParameters,
    bool isCached = true,
    Options? options,
  }) async {
    try {
      final response = await super.request(
        method: method,
        queryParameters: queryParameters ?? pageableParameters,
        isCached: isCached,
        options: options,
      );
      if (response.isSuccess || response.dataList != null) {
        pageable.isNoMoreData = (response.dataList?.length ?? 0) <= pageable.pageSize;
      } else {
        _pageableError();
      }
      return response;
    } catch (e) {
      _pageableError();
      return Future.error(e);
    }
  }

  void _pageableError() {
    if (pageable.isRefresh) {
    } else {
      pageable.pageNum--;
    }
  }

  APIPageable get pageable => APIPageable();
  Parameters get pageableParameters => {
        'pageNum': pageable.pageNum,
        'pageSize': pageable.pageSize,
        ...?parameters,
      };

  Future<List<T>?> load({bool isCached = true}) async {
    pageable.isRefresh = false;
    return request(isCached: isCached).then((value) => value.dataList);
  }

  Future<List<T>?> refresh({bool isCached = true}) async {
    pageable.isRefresh = true;
    return request(isCached: isCached).then((value) => value.dataList);
  }
}

abstract class APIPageableSession<T> with APIOptions<T>, APIDioMixin<T, APIResponder<T>>, APIPageableMixin {
  APIPageableSession({required APIPageable pageable}) : _pageable = pageable;

  final APIPageable _pageable;

  @override
  APIPageable get pageable => _pageable;
}
