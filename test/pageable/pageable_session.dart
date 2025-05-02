import 'package:sm_network/sm_network.dart';

import 'pageable_converter.dart';
import 'pageable_resp.dart';

/// 分页请求
abstract class PageableSession<T> extends RawSession<PageableResp<T>, T> {
  // ignore: public_member_api_docs
  PageableSession({this.pageNumber = 1, this.pageSize = 10});

  /// 页码(不能为空),示例值(1)
  final int pageNumber;

  /// 每页数量(不能为空),示例值(10)
  final int pageSize;

  @override
  Converter<PageableResp<T>, T> get converter => PageableConverter(
        fromJsonT: fromJsonT,
        options: DefaultConverterOptions(
          // ignore: avoid_redundant_argument_values
          code: 'code',
          // ignore: avoid_redundant_argument_values
          data: 'data',
          // ignore: avoid_redundant_argument_values
          message: 'message',
          // ignore: avoid_redundant_argument_values
          status: (status, data) => status == 1,
        ),
      );

  @override
  Parameters? get data => _defaultData;

  @override
  FromJsonT<T>? get fromJsonT => null;

  @override
  Method? get method => Method.post;

  Parameters get _defaultData => {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      };

  @override
  Future<Response<E>> fetch<E>({
    String? path,
    dynamic savePath,
    Method? method,
    Object? data,
    FormFiles? files,
    Parameters? queryParameters,
    CancelToken? cancelToken,
    HttpOptions<PageableResp<T>, T>? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool? deleteOnError,
    FileAccessMode? fileAccessMode,
    String? lengthHeader,
  }) {
    data ??= this.data;

    if (data is Parameters) {
      for (final item in _defaultData.entries) {
        data.putIfAbsent(item.key, () => item.value);
      }
    }

    return super.fetch(
      path: path,
      savePath: savePath,
      method: method,
      data: data,
      files: files,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      options: options,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
      deleteOnError: deleteOnError,
      fileAccessMode: fileAccessMode,
      lengthHeader: lengthHeader,
    );
  }
}
