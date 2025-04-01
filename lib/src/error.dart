/// 网络错误
class NetError extends Error {
  /// Creates an assertion error with the provided [message].
  NetError([this.message]);

  /// Message describing the assertion error.
  final Object? message;

  @override
  String toString() {
    if (message != null) {
      return 'Network failed: ${Error.safeToString(message)}';
    }
    return 'Network failed';
  }
}
