import 'package:sm_logger/sm_logger.dart';
import 'package:sm_network/sm_network.dart';

class APIPageable {
  APIPageable({
    int pageNumber = 1,
    this.pageSize = 10,
    this.numberKey = 'pageNumber',
    this.sizeKey = 'pageSize',
  })  : _pageNumber = pageNumber,
        assert(pageNumber >= 0 && pageSize >= 0, 'pageNumber and pageSize must >= 0'),
        _firstPage = pageNumber;

  final String numberKey;
  final String sizeKey;

  bool isNoMoreData = false;
  // 每页大小
  final int pageSize;

  // 第一页
  final int _firstPage;

  // 是否是刷新
  bool _isRefresh = true;

  // 第几页
  int _pageNumber;

  bool get isRefresh => _isRefresh;
  int get pageNumber => _pageNumber;

  set isRefresh(bool ref) {
    _isRefresh = ref;
    if (_isRefresh) {
      pageNumber = _firstPage;
    } else {
      pageNumber++;
    }
  }

  set pageNumber(int value) {
    _pageNumber = value;
    logger.d(value);
  }
}

mixin APIPageableMixin<T> on APIDioMixin<T, APIResponder<T>> {
  @override
  Future<APIResponder<T>> request({
    HTTPMethod? method,
    Object? data,
    Parameters? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool? useBody,
    BodyFormat? bodyFormat,
    bool isCached = true,
  }) async {
    try {
      final response = await super.request(
        method: method,
        data: data,
        queryParameters: queryParameters ?? pageableParameters,
        options: options,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
        useBody: useBody,
        bodyFormat: bodyFormat,
        isCached: isCached,
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

  APIPageable get pageable => APIPageable();
  Parameters get pageableParameters => {
        pageable.numberKey: pageable.pageNumber,
        pageable.sizeKey: pageable.pageSize,
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

  void _pageableError() {
    if (pageable.isRefresh) {
    } else {
      pageable.pageNumber--;
    }
  }
}

abstract class APIPageableSession<T> extends APIXSession
    with APIParseMixin<T>, APIDioMixin<T, APIResponder<T>>, APIPageableMixin {
  APIPageableSession({
    APIPageable? pageable,
  }) : _pageable = pageable ?? APIPageable();

  final APIPageable _pageable;

  @override
  APIPageable get pageable => _pageable;
}
