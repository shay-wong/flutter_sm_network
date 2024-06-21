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

  APIPaging get pageable => APIPaging();
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

abstract class APIPagingSession<T> extends APIXSession
    with APIParseMixin<T>, APIDioMixin<T, APIResponder<T>>, APIPagingMixin {
  APIPagingSession({
    APIPaging? pageable,
  }) : _pageable = pageable ?? APIPaging();

  final APIPaging _pageable;

  @override
  APIPaging get pageable => _pageable;
}
