import 'package:sm_network/sm_network.dart';

mixin APISessionMixin<T, E extends APIResponder<T>> on APIDioMixin<T, E> {
  /// 根据 responder 自动解析成对应的 model 并返回
  Future<T?> fetch({
    HTTPMethod? method,
    Parameters? queryParameters,
    bool isCached = true,
  }) async {
    return request(
      method: method,
      queryParameters: queryParameters,
      isCached: isCached,
    ).then((value) => value.data);
  }

  /// 根据 responder 自动解析成对应的 list model 并返回
  Future<List<T>?> fetchList({
    HTTPMethod? method,
    Parameters? queryParameters,
    bool isCached = true,
  }) async {
    return request(
      method: method,
      queryParameters: queryParameters,
      isCached: isCached,
    ).then((value) => value.dataList);
  }
}

abstract class APISession<T> with APIOptions<T>, APIDioMixin<T, APIResponder<T>>, APISessionMixin {}
