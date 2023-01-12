import 'dart:convert';

import 'package:courier_market_mobile/api/api_client.dart';
import 'package:courier_market_mobile/api/api_client_base.dart';
import 'package:courier_market_mobile/built_value/models/user_feedback.dart';
import 'package:courier_market_mobile/built_value/models/user_search.dart';
import 'package:courier_market_mobile/built_value/responses/list_response.dart';
import 'package:courier_market_mobile/built_value/responses/std_response.dart';
import 'package:injectable/injectable.dart';

@Singleton(dependsOn: [ApiClient])
class Members extends ApiClientBase {
  Members(ApiClient client) : super(client);

  Future<StdResponse?> invite(
    String? userType,
    String? firstName,
    String? lastName,
    String? emailAddress,
  ) async {
    var response = await this.http.post(
          '${cfg.apiUrl}/members/invite',
          body: json.encode({
            'first_name': firstName,
            'last_name': lastName,
            'email': emailAddress,
            'intended': userType,
          }),
        );
    return StdResponse.fromJson(response.body);
  }

  Future<ListResponse<UserSearch>?> search(String search) async {
    var response = await this.http.get(
          Uri.parse("${cfg.apiUrl}/members/search").replace(
            queryParameters: {'search': search},
          ),
        );
    return ListResponse.fromJson<UserSearch>(response.body);
  }

  Future<UserFeedback?> feedback(int? memberId) async {
    var response = await this.http.get("${cfg.apiUrl}/feedback/$memberId");
    return UserFeedback.fromJson(response.body);
  }
}
