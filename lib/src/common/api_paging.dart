import 'package:sm_network/sm_network.dart';

class APIPaging {
  APIPaging({
    int? pageNumber,
    int? pageSize,
    String? numberKey,
    String? sizeKey,
  })  : pageNumber = pageNumber ?? APICore.pagingConfig.pageNumber,
        pageSize = pageSize ?? APICore.pagingConfig.pageSize,
        assert((pageNumber == null || pageNumber >= 0) && (pageSize == null || pageSize >= 0),
            'pageNumber and pageSize must be >= 0 if they are not null'),
        _firstPage = pageNumber ?? APICore.pagingConfig.pageNumber,
        numberKey = numberKey ?? APICore.pagingConfig.numberKey,
        sizeKey = sizeKey ?? APICore.pagingConfig.sizeKey;

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
  int pageNumber;

  bool get isRefresh => _isRefresh;

  set isRefresh(bool ref) {
    _isRefresh = ref;
    if (_isRefresh) {
      pageNumber = _firstPage;
    } else {
      pageNumber++;
    }
  }
}

mixin APIPagingMixin<T> on APIDioMixin<T, APIResponder<T>> {
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
        queryParameters: queryParameters ?? pagingParameters,
        options: options,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
        useBody: useBody,
        bodyFormat: bodyFormat,
        isCached: isCached,
      );
      if (response.isSuccess) {
        paging.isNoMoreData = (response.dataList?.isEmpty ?? true) || response.dataList!.length < paging.pageSize;
      } else {
        _pagingError();
      }
      return response;
    } catch (e) {
      _pagingError();
      return Future.error(e);
    }
  }

  APIPaging get paging => APIPaging();
  Parameters get pagingParameters => {
        paging.numberKey: paging.pageNumber,
        paging.sizeKey: paging.pageSize,
        ...?parameters,
      };

  Future<List<T>?> load({
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
    paging.isRefresh = false;
    return request(
      method: method,
      data: data,
      queryParameters: queryParameters,
      options: options,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
      useBody: useBody,
      bodyFormat: bodyFormat,
      isCached: isCached,
    ).then((value) => value.dataList);
  }

  Future<List<T>?> refresh({
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
    paging.isRefresh = true;
    return request(
      method: method,
      data: data,
      queryParameters: queryParameters,
      options: options,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
      useBody: useBody,
      bodyFormat: bodyFormat,
      isCached: isCached,
    ).then((value) => value.dataList);
  }

  void _pagingError() {
    if (paging.isRefresh) {
    } else {
      paging.pageNumber--;
    }
  }
}

abstract class APIPagingSession<T> extends APIXSession
    with APIParseMixin<T>, APIDioMixin<T, APIResponder<T>>, APIPagingMixin {
  APIPagingSession({
    APIPaging? paging,
  }) : _paging = paging ?? APIPaging();

  final APIPaging _paging;

  @override
  APIPaging get paging => _paging;
}
