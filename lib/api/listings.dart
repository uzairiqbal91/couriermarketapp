import 'dart:convert';
import 'dart:io';

import 'package:courier_market_mobile/api/api_client.dart';
import 'package:courier_market_mobile/api/api_client_base.dart';
import 'package:courier_market_mobile/api/api_exception.dart';
import 'package:courier_market_mobile/api/auth.dart';
import 'package:courier_market_mobile/api/prefs.dart';
import 'package:courier_market_mobile/built_value/enums/device_type.dart';
import 'package:courier_market_mobile/built_value/models/bid.dart';
import 'package:courier_market_mobile/built_value/models/group.dart';
import 'package:courier_market_mobile/built_value/models/listing.dart';
import 'package:courier_market_mobile/built_value/models/user.dart';
import 'package:courier_market_mobile/built_value/responses/paginated_response.dart';
import 'package:courier_market_mobile/built_value/responses/std_response.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@Singleton(dependsOn: [ApiClient, Auth])
class Listings extends ApiClientBase {
  static const FILTER_SHOW_ALL = "showAll";
  static const FILTER_SHOW_ONLY_ME = "showOnlyMe";
  static const FILTER_SHOW_LOCATION = "showLocation";
  static const FILTER_SHOW_PROGRESS = "showProgress";
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  Prefs prefs;
  Listings(ApiClient client, this.prefs) : super(client);

  Future<PaginatedResponse<Listing>?> list({
    String filter = FILTER_SHOW_ALL,
    int page = 1,
    int length = 12,
    Map<String, String>? additional,
  }) async {
    var response = await this.http.get(Uri.parse('${cfg.apiUrl}/listings').replace(
          queryParameters: {
            'filter': filter.toString(),
            'page': page.toString(),
            'perPage': length.toString(),
            ...(additional ?? {})
          },
        ));
    return PaginatedResponse.fromJson<Listing>(response.body);
  }



  static Future<String> getDeviceNick() async {
    var deviceInfoPg = new DeviceInfoPlugin();
    switch (Platform.operatingSystem) {
      case "android":
        return (await deviceInfoPg.androidInfo).model;
      case "ios":
        return (await deviceInfoPg.iosInfo).name;
      default:
        return "unknown";
    }
  }

  Future<String?> getToken([bool requestPermission = true]) async {
    if (requestPermission) {
      var permReq = await firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true, provisional: true),
      );
      if (permReq == false) {
        Fluttertoast.showToast(msg: "Unable to get permissions", backgroundColor: Colors.amber);
        return null;
      }
    }
    return await firebaseMessaging.getToken();
  }

  Future<StdResponse?> deviceRegistration({
    bool? notify,
    bool? locate,
  }) async {
    var nick = await getDeviceNick();
    var fcmId = await getToken(notify ?? false);

    Map<String, dynamic> req = {
      'fcm_id': fcmId,
      'nick': nick,
      'type': DeviceType.current.toString(),
      'notify': notify ?? prefs.deviceNotify,
      'locate': locate ?? prefs.deviceLocate,
    };

    var strJson = jsonEncode(req);

    var response = await this.http.post(
      "${cfg.apiUrl}/user/devices",
      body: strJson,
    );
    var stdResponse = StdResponse.fromJson(response.body)!;

    deviceId = stdResponse.id! ;
    // prefs.setDeviceId(stdResponse.id!);


    // if (notify != null) prefs.setDeviceNotify(notify);


    return stdResponse;
  }

  Future<Listing?> get(int? id) async {
    var response = await this.http.get(cfg.apiUrl + '/listings/$id');
    return Listing.fromJson(response.body);
  }

  Future<StdResponse?> bookHaulier(Listing listing, Group haulier, double amount) async {
    var response = await this.http.post(
          '${cfg.apiUrl}/listings/${listing.id}/book',
          body: json.encode({
            'id': haulier.id,
            'amount': amount,
          }),
        );
    return StdResponse.fromJson(response.body);
  }

  Future<StdResponse?> placeBid(int? id, double? amount, String? note) async {
    var response = await this.http.post(
          '${cfg.apiUrl}/listings/$id/bids',
          body: json.encode({'amount': amount, 'note': note}),
        );
    return StdResponse.fromJson(response.body);
  }

  Future<StdResponse?> withdrawBid(Bid bid) async {
    var response = await this.http.post(cfg.apiUrl + '/listings/${bid.listingId}/bids/${bid.id}/withdraw');
    return StdResponse.fromJson(response.body);
  }

  Future<StdResponse?> bookBid(Bid bid) async {
    var response = await this.http.post(cfg.apiUrl + '/listings/${bid.listingId}/bids/${bid.id}/accept');
    return StdResponse.fromJson(response.body);
  }

  Future<StdResponse?> assignDriver(Listing listing, User driver) async {
    var response = await this.http.post(
          "${cfg.apiUrl}/listings/${listing.id}/driver",
          body: json.encode({'driver_id': driver.id}),
        );
    return StdResponse.fromJson(response.body);
  }

  Future<StdResponse?> post(Map<String, dynamic> data) async {
    var response = await this.http.post(cfg.apiUrl + '/listings', body: json.encode(data));
    if (response.statusCode != 200) {
      print(response.body);
      throw ApiException("Something went wrong, please try again!");
    }
    return StdResponse.fromJson(response.body);
  }

  Future<StdResponse?> delete(Listing listing) async {
    var response = await this.http.delete('${cfg.apiUrl}/listings/${listing.id}');
    return StdResponse.fromJson(response.body);
  }

  Future<StdResponse?> submitFeedback(
      Listing listing, String rate, String? note, bool escalate, String? escNotes) async {
    var response = await this.http.post(
          '${cfg.apiUrl}/listings/${listing.id}/feedback',
          body: json.encode({
            'rate': rate,
            'notes': note,
            'mark_escalation': escalate,
            'escalation': escNotes,
          }),
        );
    return StdResponse.fromJson(response.body);
  }

  Future<StdResponse?> invoice(Listing listing) async {
    var response = await this.http.post('${cfg.apiUrl}/invoice/${listing.id}');
    return StdResponse.fromJson(response.body);
  }

  Future<StdResponse?> update(
    Listing listing,
    PlaceDetails pickup,
    String? pickupCompany,
    String? pickupContact,
    String? pickupContactNumber,
    PlaceDetails dropoff,
    String? dropoffCompany,
    String? dropoffContact,
    String? dropoffContactNumber,
  ) async {
    Map<String, dynamic?> request = ({
      'pickup_placeid': pickup.placeId,
      'pickup_location': pickup.geometry.location.toJson(),
      'pickup_address': pickup.formattedAddress,
      'pickup_company': pickupCompany,
      'pickup_contact': pickupContact,
      'pickup_number': pickupContactNumber,
      'dropoff_placeid': dropoff.placeId,
      'dropoff_location': dropoff.geometry.location.toJson(),
      'dropoff_address': dropoff.formattedAddress,
      'dropoff_company': dropoffCompany,
      'dropoff_contact': dropoffContact,
      'dropoff_number': dropoffContactNumber,
    });
    var response = await this.http.patch(
          '${cfg.apiUrl}/listings/${listing.id}',
          body: json.encode(request),
        );
    return StdResponse.fromJson(response.body);
  }

  Future<StdResponse?> bookingCancel(Listing listing) async {
    var response = await this.http.post('${cfg.apiUrl}/bookings/${listing.id}/cancel');
    return StdResponse.fromJson(response.body);
  }

  Future<StdResponse?> submitPOD(Listing listing, Map<String, String?> data, File file) async {
    var request = http.MultipartRequest('POST', Uri.parse('${cfg.apiUrl}/bookings/${listing.id}/complete'));

    request.files.add(await http.MultipartFile.fromPath("pod_document", file.path));
    request.fields
        .addEntries(data.entries.where((element) => element.value != null) as Iterable<MapEntry<String, String>>);

    var response = await http.Response.fromStream(await this.http.send(request));

    return StdResponse.fromJson(response.body);
  }
}

class PreferenceUtils {
  static Future<SharedPreferences> get _instance async => _prefsInstance ??= await SharedPreferences.getInstance();
  static SharedPreferences? _prefsInstance;

  // call this method from iniState() function of mainApp().
  static Future<SharedPreferences> init() async {
    _prefsInstance = await _instance;
    return _prefsInstance!;
  }

}
