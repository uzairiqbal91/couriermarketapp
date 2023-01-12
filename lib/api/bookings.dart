import 'dart:convert';

import 'package:courier_market_mobile/api/api_client.dart';
import 'package:courier_market_mobile/api/api_client_base.dart';
import 'package:courier_market_mobile/api/container.dart';
import 'package:courier_market_mobile/api/listings.dart';
import 'package:courier_market_mobile/api/location_provider.dart';
import 'package:courier_market_mobile/api/prefs.dart';
import 'package:courier_market_mobile/built_value/models/listing.dart';
import 'package:courier_market_mobile/built_value/responses/paginated_response.dart';
import 'package:courier_market_mobile/built_value/responses/std_response.dart';
import 'package:injectable/injectable.dart';

@Singleton(dependsOn: [ApiClient, LocationProvider])
class Bookings extends ApiClientBase {
  Prefs prefs;
  LocationProvider location;

  Bookings(ApiClient client, this.prefs, this.location) : super(client);

  Future<PaginatedResponse<Listing>?> list({
    int page = 1,
    int length = 15,
    required Map<String, dynamic> filters,
  }) async {
    filters.removeWhere((key, value) => value == null);
    var response = await this.http.get(
          Uri.parse('${cfg.apiUrl}/bookings').replace(
            queryParameters: {
              ...filters.map((key, value) => MapEntry("filters[$key]", value)),
            },
          ),
        );
    return PaginatedResponse.fromJsonMap<Listing>(json.decode(response.body)["listings"]);
  }

  Future<PaginatedResponse<Listing>?> listComplete({
    int page = 1,
    int length = 12,
    required Map<String, dynamic> filters,
  }) async {
    filters.removeWhere((key, value) => value == null);
    var response = await this.http.get(
          Uri.parse('${cfg.apiUrl}/bookings/complete').replace(
            queryParameters: {
              ...filters.map((key, value) => MapEntry("filters[$key]", value)),
            },
          ),
        );
    return PaginatedResponse.fromJsonMap<Listing>(json.decode(response.body)["listings"]);
  }

  Future<StdResponse?> markInProgress(Listing listing) async {
    var response = await this.http.post('${cfg.apiUrl}/bookings/${listing.id}/progress');
    if (response.statusCode == 200) {
      if (!this.prefs.jobsInProgress.contains(listing.id)) {
        this.prefs.setJobsInProgress(this.prefs.jobsInProgress..add(listing.id));
      }
      this.location.syncWithDesiredAccuracy();
    }
    return StdResponse.fromJson(response.body);
  }

  Future syncProgressWithServer() async {
    print("Syncing Jobs with server");
    var listingsInProgress = await getIt<Listings>().list(filter: Listings.FILTER_SHOW_PROGRESS);
    print("There are ${listingsInProgress!.data!.length} jobs in progress");
    await this.prefs.setJobsInProgress(listingsInProgress.data!.map((Listing l) => l.id).toList());
    await this.location.syncWithDesiredAccuracy();
  }

  Future markComplete(Listing listing) async {
    if (!this.prefs.jobsInProgress.contains(listing.id)) return true;
    await this.prefs.setJobsInProgress(this.prefs.jobsInProgress..remove(listing.id));
    await this.location.syncWithDesiredAccuracy();
  }

  Future setIsOnline(bool state) async {
    if (state && this.location.trackingLevel.value == LocationTrackingLevel.NONE) await this.location.startLocator();
    if (!state && this.location.trackingLevel.value != LocationTrackingLevel.NONE) await this.location.stopLocator();
  }
}
