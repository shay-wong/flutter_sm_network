/// 1 tab length
const _tabStep = '  ';

/// 打印调试信息
typedef HttpDebugLog = void Function(Object object);

/// 打印错误信息
typedef HttpErrorLog = void Function(Object error, StackTrace? stackTrace);

/// 网络打印信息
class HttpLog {
  // ignore: public_member_api_docs
  const HttpLog({
    this.enable = true,
    this.debug = print,
    HttpErrorLog? error,
    this.tabStep = _tabStep,
  }) : _error = error;

  /// 打印调试信息
  final HttpDebugLog debug;

  /// 是否打印日志
  final bool enable;

  /// 1 tab length
  final String tabStep;

  /// 打印错误信息
  final HttpErrorLog? _error;

  /// 打印错误信息
  void error(Object error, StackTrace? stackTrace) {
    if (_error != null) {
      _error.call(error, stackTrace);
    } else {
      // ignore: avoid_print
      print('$error\n$stackTrace');
    }
  }
}
