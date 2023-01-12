import 'package:courier_market_mobile/api/api_client.dart';
import 'package:courier_market_mobile/api/auth.dart';
import 'package:courier_market_mobile/api/build_config.dart';
import 'package:flutter/foundation.dart';

abstract class ApiClientBase {
  @protected
  ApiClient client;

  @protected
  BuildConfig get cfg => client.cfg;

  @protected
  JsonClient get http => client.client;

  ApiClientBase(this.client);
}
