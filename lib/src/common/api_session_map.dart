import 'api_session.dart';

abstract class APISessionMap<T> with APISession<T> {
  @override
  T Function(dynamic json) get responder => (json) => toObject(json);

  T toObject(Parameters p) => p as T;
}
