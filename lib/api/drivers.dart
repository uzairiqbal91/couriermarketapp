import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:courier_market_mobile/api/api_client.dart';
import 'package:courier_market_mobile/api/api_client_base.dart';
import 'package:courier_market_mobile/built_value/models/user.dart';
import 'package:injectable/injectable.dart';

@Singleton(dependsOn: [ApiClient])
class Drivers extends ApiClientBase {
  Drivers(ApiClient client) : super(client);

  Future<BuiltList<User>> list() async {
    var response = await this.http.get("${cfg.apiUrl}/drivers");
    return User.fromJsonList(json.decode(response.body));
  }
}
