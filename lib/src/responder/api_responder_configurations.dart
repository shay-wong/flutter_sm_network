import '../common/api_session.dart';

mixin APIResponderMap {
  Parameters Function(dynamic json) get responder => (json) => json as Parameters;
}

mixin APIResponderList {
  List Function(dynamic json) get responder => (json) => json as List;
}
