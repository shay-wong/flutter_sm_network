import 'api_session.dart';

mixin APISessionLogin {
  String get prefixPath => '/boxLogin';

  Parameters? get parameters;
}
