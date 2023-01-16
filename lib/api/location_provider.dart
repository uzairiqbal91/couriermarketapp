import 'package:background_locator/background_locator.dart';
import 'package:background_locator/location_dto.dart';
import 'package:background_locator/settings/android_settings.dart';
import 'package:background_locator/settings/ios_settings.dart';
import 'package:background_locator/settings/locator_settings.dart';
import 'package:courier_market_mobile/api/container.dart';
import 'package:courier_market_mobile/api/devices.dart';
import 'package:courier_market_mobile/api/prefs.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

enum LocationTrackingLevel { NONE, MEDIUM, HIGH }

@singleton
class LocationProvider {
  ValueNotifier<LocationTrackingLevel> trackingLevel = ValueNotifier<LocationTrackingLevel>(LocationTrackingLevel.NONE);

  ValueNotifier<bool?> isRegistered = ValueNotifier<bool?>(null);

  Future platformSync() async {
    try {
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
        accuracy: common['accuracy'] as LocationAccuracy,
        interval: common['interval'] as int,
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
