import 'package:courier_market_mobile/built_value/models/versions.dart';
import 'package:injectable/injectable.dart';

import 'api_client.dart';
import 'api_client_base.dart';
import 'dart:io' show Platform;
import 'package:courier_market_mobile/api/api_client.dart';
import 'package:courier_market_mobile/api/api_client_base.dart';
import 'package:http/http.dart' as http;

@Singleton(dependsOn: [ApiClient])
class Versions extends ApiClientBase {


  Versions(ApiClient client) : super(client);
    Future<Version?> get() async {
    var response = await this.http.get(cfg.apiUrl + '/app/version');
    return Version.fromJson(response.body);
  }


}
