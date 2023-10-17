import 'dart:convert';

import 'package:background_locator/background_locator.dart';
import 'package:background_locator/location_dto.dart';
import 'package:background_locator/settings/android_settings.dart';
import 'package:background_locator/settings/ios_settings.dart';
import 'package:background_locator/settings/locator_settings.dart';
import 'package:courier_market_mobile/api/container.dart';
import 'package:courier_market_mobile/api/devices.dart';
import 'package:courier_market_mobile/api/prefs.dart';
import 'package:courier_market_mobile/built_value/responses/std_response.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'build_config.dart';

enum LocationTrackingLevel { NONE, MEDIUM, HIGH }

@singleton
class LocationProvider {
  ValueNotifier<LocationTrackingLevel> trackingLevel = ValueNotifier<LocationTrackingLevel>(LocationTrackingLevel.NONE);

  ValueNotifier<bool?> isRegistered = ValueNotifier<bool?>(null);

  Future platformSync() async {
    try {
      // if (Platform.isAndroid) PathProviderAndroid.registerWith();
      // if (Platform.isIOS) PathProviderIOS.registerWith();
      isRegistered.value = await BackgroundLocator.isRegisterLocationUpdate();
    } catch (e) {
      isRegistered.value = true;
    }
  }

  Future init() async {
    if (!getIt<bool>(instanceName: HEADLESS)) await platformSync();
  }

  @factoryMethod
  static Future<LocationProvider> create() async {
    LocationProvider locationProvider = LocationProvider();
    await locationProvider.init();
    return locationProvider;
  }

  startLocator() async {
    isRegistered.value = true;
    trackingLevel.value = calculateAccuracy();
    bool tlh = trackingLevel.value == LocationTrackingLevel.HIGH;

    var common = {
      'accuracy': tlh ? LocationAccuracy.HIGH : LocationAccuracy.BALANCED,
      'interval': tlh ? 90 : 15 * 60,
    };

    await BackgroundLocator.initialize();
    await BackgroundLocator.registerLocationUpdate(

      LocationProviderHandler.callback,
      androidSettings: AndroidSettings(
        // accuracy: common['accuracy'] as LocationAccuracy,
        // interval: common['interval'] as int,
        accuracy: LocationAccuracy.NAVIGATION,
        interval: 5,
        distanceFilter: 0,
        client: LocationClient.google,
        androidNotificationSettings: AndroidNotificationSettings(
          notificationTitle: "Courier Market",
          notificationMsg:
              tlh ? "Location tracking is currently enabled" : "Nearby Notifications are currently Enabled",
          notificationBigMsg: tlh
              ? "Courier Market is using your precise location for ${getIt<Prefs>().jobsInProgress.length} job(s). Open the to see them!"
              : "Courier Market is using your location for Nearby Notifications",
          notificationIcon: "@drawable/ic_notification",
        ),
      ),
      iosSettings: IOSSettings(
        accuracy: common['accuracy'] as LocationAccuracy,
        distanceFilter: 5,
        // accuracy: LocationAccuracy.NAVIGATION,
        //   distanceFilter: 0
      ),
      autoStop: false,
    );
  }

  stopLocator() {
    isRegistered.value = false;
    trackingLevel.value = LocationTrackingLevel.NONE;
    BackgroundLocator.unRegisterLocationUpdate();
  }

  Future syncWithDesiredAccuracy() async {
    trackingLevel.value = calculateAccuracy();
    if (trackingLevel.value == LocationTrackingLevel.NONE) return;

    stopLocator();
    await Future.delayed(Duration(milliseconds: 500));
    await startLocator();
  }

  LocationTrackingLevel calculateAccuracy() {
    return isRegistered.value!
        ? getIt<Prefs>().jobsInProgress.length > 0
            ? LocationTrackingLevel.HIGH
            : LocationTrackingLevel.MEDIUM
        : LocationTrackingLevel.NONE;
  }
}

class LocationProviderHandler {


  static Future<void> callback(LocationDto locationDto) async {
    print("-- BACKGROUND LOCATION --");


    await ensureDependencies(true);
    getIt<Devices>().heartbeat(DeviceLocation(locationDto.latitude, locationDto.longitude));


  }
}


// class HttpService {
//   final String postsURL = "https://test.couriermarket.com/api/user/devices/12/hb";
//
//
//   BuildConfig buildConfig() {
//   const env = String.fromEnvironment(ENV, defaultValue: Env.PRODUCTION);
//   String envApiUrl = '';
//
//   if (env == Env.DEVELOPMENT) {
//     envApiUrl = String.fromEnvironment('SERVER_URL', defaultValue: 'https://test.couriermarket.com/api');
//     return BuildConfig(
//       env: Env.DEVELOPMENT,
//       apiUrl: envApiUrl,
//       apiClientId: "2",
//       apiClientSecret: "ajuUe7LUndZjBRQt64rFuPh1TIstbPTxJCkJPq50",
//     );
//   } else if (env == Env.STAGING) {
//     envApiUrl = String.fromEnvironment('SERVER_URL', defaultValue: 'https://test.couriermarket.com/api');
//     return BuildConfig(
//       env: Env.STAGING,
//       apiUrl: envApiUrl,
//       apiClientId: "2",
//       apiClientSecret: "23uGh8bMDyuBGwujpvtc4yxgRAVNkLzLnBFTsRDcxZ9hqvTCZZ",
//     );
//   } else {
//     envApiUrl = String.fromEnvironment('SERVER_URL', defaultValue: 'https://app.couriermarket.com/api');
//     return BuildConfig(
//       apiUrl: envApiUrl,
//       apiClientId: "2",
//       apiClientSecret: "ajuUe7LUndZjBRQt64rFuPh1TIstbPTxJCkJPq50",
//     );
//   }
// }

// Future<void> getDeviceId() async {
//
//
//
//   var buildConfiginstance = buildConfig();
//
//   String env = buildConfiginstance.env;
//   String _k(String tag) => '$env.$tag';
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   // print(buildConfiginstance.apiUrl);
//   // print(deviceId.toString());
// }
//
//   Future<void> getPosts() async {
//     Response res = await post(postsURL);
//
//
//
//     if (res.statusCode == 200) {
//       List<dynamic> body = jsonDecode(res.body);
//       print(body.toString());
//     } else {
//       throw "Unable to retrieve posts.";
//     }
//   }
//
//   Future<Response> postRequest () async {
//     var buildConfiginstance = buildConfig();
//     var url ='${buildConfiginstance.apiUrl}/user/devices/12/hb';
//
//
//
//     //encode Map to JSON
//     // var body = json.encode(data);
//     var response = await post(url,
//         // headers: {"Content-Type": "application/json"},
//         body: json.encode({
//           'location': {
//             'lat': 24.36,
//             'lng': 76.85,
//           }
//         }
//     ));
//     print("${response.statusCode}");
//     print("${response.body}");
//     return response;
//   }
// }
