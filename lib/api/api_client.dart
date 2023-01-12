import 'package:courier_market_mobile/api/auth.dart';
import 'package:courier_market_mobile/api/build_config.dart';
import 'package:injectable/injectable.dart';

@Singleton(dependsOn: [Auth])
class ApiClient {
  BuildConfig cfg;
  JsonClient _client;

  Auth _instAuth;

  ApiClient(
    BuildConfig config,
    Auth auth,
  )   : this.cfg = config,
        this._instAuth = auth,
        this._client = auth.client.value ?? JsonClient() {
    _instAuth.client.addListener(() {
      if (_instAuth.client.value != null) this._client = _instAuth.client.value!;
    });
  }

  JsonClient get client => _client;
}
