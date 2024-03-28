import 'api_config.dart';

class APICore {
  static APIConfig? _config;

  /// 可以在任意地方调用, 调用之后所有的 [APISession] 都会默认使用这个配置
  static void initialize(APIConfig config) {
    _config = config;
  }

  static APIConfig get config => _config ?? APIConfig();
}
