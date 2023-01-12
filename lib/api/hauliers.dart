import 'dart:convert';

import 'package:courier_market_mobile/api/api_client.dart';
import 'package:courier_market_mobile/api/api_client_base.dart';
import 'package:courier_market_mobile/built_value/models/group.dart';
import 'package:courier_market_mobile/built_value/responses/std_response.dart';
import 'package:injectable/injectable.dart';

@Singleton(dependsOn: [ApiClient])
class Hauliers extends ApiClientBase {
  Hauliers(ApiClient client) : super(client);

  Future<StdDataResponse<Group>?> lookup(int id) async {
    var response = await this.http.get(Uri.parse('${cfg.apiUrl}/hauliers/look-up').replace(
          queryParameters: {'id': id.toString()},
        ));
    return StdDataResponse.fromJson<Group>(json.decode(response.body));
  }
}
