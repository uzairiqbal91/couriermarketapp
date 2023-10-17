import 'package:courier_market_mobile/api/container.dart';
import 'package:shared_preferences/shared_preferences.dart';


int? deviceId;

class Prefs {
  String? env;
  late SharedPreferences prefs;

  Prefs(this.env);

  init() async {
    this.prefs = await SharedPreferences.getInstance();
  }

  static Future<Prefs> create() async {
    var prefs =  Prefs(getIt<String>(instanceName: 'env'));
    await prefs.init();
    return prefs;
  }



  String _k(String tag) => '$env.$tag';

  ///---- Devices ----

  // ignore: unnecessary_null_comparison
  get deviceIsRegistered => deviceId != null;

  int get deviceId => prefs.getInt(_k('device.id'));

  Future<bool> setDeviceId(int? value) => prefs.setInt(_k('device.id'), value);

  bool get deviceNotify => prefs.getBool(_k('device.notify')) ?? false;

  Future<bool> setDeviceNotify(bool value) => prefs.setBool(_k('device.notify'), value);

  bool get deviceLocate => prefs.getBool(_k('device.locate')) ?? false;

  Future<bool> setDeviceLocate(bool value) => prefs.setBool(_k('device.locate'), value);

  // setting and getting fcm token in preferences
  // String get fcmToken => prefs.getString(_k('fcm.token')) ?? "";
  // Future<bool> setfcmToken(String value) => prefs.setString(_k('fcm.token'), value);

  ///---- Jobs ----

  List<int?> get jobsInProgress =>
      (prefs.getStringList(_k('jobs.progress')) ?? <int>[]).map((e) => int.parse(e as String)).toList();

  Future<bool> setJobsInProgress(List<int?> value) =>
      prefs.setStringList(_k('jobs.progress'), value.map((e) => e.toString()).toList());
}
