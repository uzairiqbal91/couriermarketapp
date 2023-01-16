import 'dart:convert';
import 'dart:io';

import 'package:courier_market_mobile/api/api_client.dart';
import 'package:courier_market_mobile/api/api_exception.dart';
import 'package:courier_market_mobile/api/auth_cache.dart';
import 'package:courier_market_mobile/api/build_config.dart';
import 'package:courier_market_mobile/api/container.dart';
import 'package:courier_market_mobile/api/devices.dart';
import 'package:courier_market_mobile/api/location_provider.dart';
import 'package:courier_market_mobile/api/prefs.dart';
import 'package:courier_market_mobile/built_value/models/auth_user.dart';
import 'package:courier_market_mobile/built_value/responses/std_response.dart';
import 'package:courier_market_mobile/router/router.gr.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Router;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:package_info/package_info.dart';

@Singleton(dependsOn: [AuthCache])
class Auth {
  final log = Logger("api/auth");

  final BuildConfig _cfg;
  final AuthCache _authCache;

  final authUser = ValueNotifier<AuthUser?>(null);
  final client = ValueNotifier<JsonClient?>(null);

  bool _isReady = false;
  Future<bool>? _readiness;

  Auth(
    BuildConfig config,
    AuthCache authCache,
  )   : this._cfg = config,
        this._authCache = authCache;

  @factoryMethod
  static Future<Auth> create(
    BuildConfig config,
    AuthCache authCache,
  ) async {
    Auth auth = Auth(config, authCache);
    await auth.init();
    return auth;
  }

  bool get isAuthenticated => authUser.value != null;

  Future<bool>? ensureInit() => _isReady ? Future.value(true) : _readiness;

  Future<bool> init() async {
    log.info("init");
    log.fine("checking for cred cache");
    await _authCache.ensureInit();

    if (!_authCache.isValid) {
      log.info("cache: miss");
      _isReady = true;
      return false;
    }

    client.value = JsonClient(
      httpClient: oauth2.Client(
        _authCache.creds!,
        onCredentialsRefreshed: _onCredentialRefresh,
      ),
    );

    log.fine("cache: need user?");

    final hasUser = _authCache.hasUser;
    final userStaleness =
        _authCache.refresh == null ? Duration(days: 180) : DateTime.now().difference(_authCache.refresh!);

    log.finer("cache: hasUser? ${hasUser.toString()}");
    log.finer("cache: userStaleness? ${userStaleness.toString()}");

    if (!hasUser || userStaleness > Duration(days: 7)) {
      log.info("cache: needs user");
      await refreshUser();
    } else {
      log.info("cache: has user");
      authUser.value = _authCache.user;
      if (userStaleness > Duration(minutes: 1)) refreshUser();
    }

    return _isReady = true;
  }

  Future<AuthUser?> refreshUser() async {
    log.info("refreshing user");
    try {
      var response = await client.value!.get("${_cfg.apiUrl}/user");
      return _authCache.user = authUser.value = AuthUser.fromJson(response.body);
    } on ApiAuthenticationException {
      //User seems to have been logged out
      Fluttertoast.showToast(msg: "You have been logged out.\nPlease login again");
      logout();
    }
    return null;
  }

  Future<AuthUser?> login(String username, String password) async {
    log.info("login");
    String fcmToken =  getIt<Prefs>().fcmToken;
    var _client = await oauth2.resourceOwnerPasswordGrant(
        Uri.parse("${_cfg.apiUrl}/../oauth/token"), username, password,fcmToken,
        identifier: this._cfg.apiClientId,
        secret: this._cfg.apiClientSecret,
        onCredentialsRefreshed: _onCredentialRefresh

    );
    _authCache.creds = _client.credentials;
    client.value = JsonClient(httpClient: _client);
    log.info("getting user");
    return await refreshUser();
  }

  Future<StdResponse?> updateAccountSettings(Map<String, dynamic> accountSettings) async {

    var response = await this.client.value!.patch(
          "${_cfg.apiUrl}/my-account/patch",
          body: json.encode(accountSettings),
        );
    print(json.encode(accountSettings));
    print(response.body);
    return StdResponse.fromJson(response.body);

  }

  Future<String> getToken() async {
    await ensureInit();
    return _authCache.creds!.accessToken;
  }

  _onCredentialRefresh(oauth2.Credentials credentials) {
    log.info("credentials updated");
    _authCache.creds = credentials;
  }

  logout({BuildContext? context}) async {
    try {
      var location = getIt<LocationProvider>();
      if (location.isRegistered.value!) {
        location.stopLocator();
        await Future.delayed(Duration(milliseconds: 250));
      }

      var devices = getIt<Devices>();
      if (devices.isRegistered) await devices.delete();
      getIt<Router>().pushAndRemoveUntil(LoginScreenRoute(), predicate: (route) => false);
    } catch (e, stack) {
      FlutterError.reportError(FlutterErrorDetails(exception: e, stack: stack));
    }

    authUser.value = null;
    client.value = null;
    _authCache.destroy();
  }
}

@Singleton(dependsOn: [ApiClient])
class JsonClient extends http.BaseClient {
  final Logger _log = Logger("api/json_client");
  http.Client _client;

  JsonClient({http.Client? httpClient}) : _client = httpClient ?? new http.Client();

  @factoryMethod
  static resolve({required ApiClient apiClient}) => apiClient.client;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    var info = getIt<PackageInfo>();

    request.headers.addAll({
      HttpHeaders.userAgentHeader: "CMK/${info.version} (${Platform.operatingSystem})",
      HttpHeaders.acceptHeader: "application/json",
      HttpHeaders.contentTypeHeader: "application/json",
    });

    http.StreamedResponse response = await _client.send(request);

    _log.log(
      (200 <= response.statusCode && response.statusCode < 300) ? Level.FINER : Level.WARNING,
      "Response: ${response.statusCode} - ${request.url}",
    );

    if (response.statusCode == 401) throw ApiAuthenticationException(response.reasonPhrase);
    if (response.statusCode == 403) throw ApiAuthorizationException(response.reasonPhrase);
    if (response.statusCode == 404) throw ApiNotFoundException(response.reasonPhrase);

    return response;
  }
}
