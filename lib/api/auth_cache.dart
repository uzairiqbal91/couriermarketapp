import 'dart:convert';
import 'dart:io';

import 'package:courier_market_mobile/api/build_config.dart';
import 'package:courier_market_mobile/built_value/models/auth_user.dart';
import 'package:courier_market_mobile/built_value/serializers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:path_provider/path_provider.dart';

@singleton
class AuthCache {
  static const String C_AUTH = 'auth';
  static const String C_USER = 'user';
  static const String C_REFRESH = 'refresh';

  BuildConfig _cfg;

  late File _cacheFile;
  bool _isReady = false;
  Future? _readiness;

  Map? _content;
  AuthUser? _user;
  String? _refresh;
  oauth2.Credentials? _creds;

  AuthCache(this._cfg) {
    _readiness = init();
  }

  AuthCache.injectable(BuildConfig config) : this._cfg = config;

  @factoryMethod
  static Future<AuthCache> create(BuildConfig config) async {
    AuthCache authCache = AuthCache.injectable(config);
    await authCache.init();
    return authCache;
  }

  bool get isValid => (_creds != null);

  bool get hasUser => (_user != null);

  AuthUser? get user => _user;

  DateTime? get refresh => _refresh == null ? null : DateTime.parse(_refresh!);

  set user(AuthUser? newUser) => _withSave(() {
        _user = newUser;
        _refresh = DateTime.now().toIso8601String();
      });

  oauth2.Credentials? get creds => _creds;

  set creds(oauth2.Credentials? newAuth) => _withSave(() => _creds = newAuth);

  Future<bool>? ensureInit() => _isReady ? Future.value(true) : _readiness as Future<bool>?;

  Future<bool> init() async {
    _cacheFile = new File("${(await getApplicationDocumentsDirectory()).path}/cred-${_cfg.env}.json");
    if (!await _cacheFile.exists()) return _isReady = true;

    var contentRaw = await _cacheFile.readAsString();
    if (contentRaw.isNotEmpty) {
      _content = json.decode(contentRaw);
      try {
        var encoded = json.encode(_content![C_AUTH]);
        _creds = oauth2.Credentials.fromJson(encoded);
      } catch (e) {
        //Malformed cred cache, nuke
        await _cacheFile.delete();
      }
      try {
        _user = serializers.deserializeWith(AuthUser.serializer, _content![C_USER]);
        _refresh = _content![C_REFRESH];
      } catch (e) {
        //This will rehydrate naturally
      }
    }
    return _isReady = true;
  }

  save() async {
    if (!await _cacheFile.parent.exists()) await _cacheFile.parent.create();
    var map = <String, dynamic>{
      C_AUTH: _creds != null ? json.decode(_creds!.toJson()) : null,
      C_USER: _user != null ? json.decode(_user!.toJson()) : null,
      C_REFRESH: _refresh != null ? _refresh : null,
    };
    var encoded = json.encode(map);
    await _cacheFile.writeAsString(encoded);
  }

  _withSave(VoidCallback callback) {
    callback();
    save();
  }

  destroy() async {
    _content = null;
    if (await _cacheFile.exists()) await _cacheFile.delete();
  }
}
