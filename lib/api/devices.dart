import 'dart:convert';
import 'dart:io' show Platform;

import 'package:courier_market_mobile/api/api_client.dart';
import 'package:courier_market_mobile/api/api_client_base.dart';
import 'package:courier_market_mobile/api/container.dart';
import 'package:courier_market_mobile/api/prefs.dart';
import 'package:courier_market_mobile/built_value/enums/device_type.dart';
import 'package:courier_market_mobile/built_value/responses/std_response.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:logging/logging.dart';

@Singleton(dependsOn: [ApiClient])
class Devices extends ApiClientBase with ChangeNotifier {
  final Logger _log = Logger("api/devices");
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  final Prefs prefs;

  Devices(ApiClient client, this.prefs) : super(client);

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

  Future<StdResponse?> delete() async {
    var response = await this.http.delete("${cfg.apiUrl}/user/devices/${prefs.deviceId}");
    var stdResponse = StdResponse.fromJson(response.body);

    prefs.setDeviceId(null);
    prefs.setDeviceLocate(false);
    prefs.setDeviceNotify(false);

    return stdResponse;
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

    prefs.setDeviceId(stdResponse.id!);
    if (notify != null) prefs.setDeviceNotify(notify);
    if (locate != null) {
      PermissionStatus loc =
          await LocationPermissions().requestPermissions(permissionLevel: LocationPermissionLevel.locationAlways);
      if (loc == PermissionStatus.denied) {
        await LocationPermissions().openAppSettings();
        return null;
      }
      prefs.setDeviceLocate(locate);
    }
    notifyListeners();

    return stdResponse;
  }

  Future<bool?> heartbeat(DeviceLocation location) async {
    if (!prefs.deviceIsRegistered) return null;
    await this.http.post(
          "${cfg.apiUrl}/user/devices/${prefs.deviceId}/hb",
          body: json.encode({
            'location': {
              'lat': location.latitude,
              'lng': location.longitude,
            }
          }),
        );

    return true;
  }

  bool get isRegistered => prefs.deviceIsRegistered;

  bool get isRegisteredNotify => prefs.deviceNotify;

  bool get isRegisteredLocate => prefs.deviceLocate;

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
}

void handleGeo([
  String? taskId,
  bool highAccuracy = false,
]) async {
  await ensureDependencies();

  Position loc = await Geolocator.getCurrentPosition(
    desiredAccuracy: highAccuracy ? LocationAccuracy.best : LocationAccuracy.high,
  );
  getIt<Devices>().heartbeat(DeviceLocation(loc.latitude, loc.longitude));
}

class DeviceLocation {
  final double latitude;

  final double longitude;

  DeviceLocation(this.latitude, this.longitude);

  copyWith({
    double? latitude,
    double? longitude,
  }) =>
      DeviceLocation(
        latitude ?? this.latitude,
        longitude ?? this.longitude,
      );
}
