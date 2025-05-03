/// 网络错误
class HttpError extends Error {
  /// Creates an assertion error with the provided [message].
  HttpError([this.message]);

  /// Message describing the assertion error.
  final Object? message;

  @override
  String toString() {
    if (message != null) {
      return 'HttpError: ${Error.safeToString(message)}';
    }
    return 'HttpError unknown error';
  }
}

/// 错误码
final class HttpErrorCode {
  /// 错误码
  static const error = 9001;

  /// 内部错误
  static const internalError = 9003;
}
