import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:courier_market_mobile/api/permissions.dart';
import 'package:courier_market_mobile/built_value/models/device.dart';
import 'package:courier_market_mobile/built_value/models/group.dart';
import 'package:courier_market_mobile/built_value/models/user.dart';
import 'package:courier_market_mobile/built_value/models/user_registration.dart';
import 'package:courier_market_mobile/built_value/serializers.dart';
import 'package:courier_market_mobile/router/router.gr.dart';
import 'package:crypto/crypto.dart';

part 'auth_user.g.dart';

abstract class AuthUser with IUser implements Built<AuthUser, AuthUserBuilder> {
  AuthUser._();

  factory AuthUser([updates(AuthUserBuilder b)?]) = _$AuthUser;

  static Serializer<AuthUser> get serializer => _$authUserSerializer;

  @BuiltValueField(wireName: 'email')
  String? get email;

  @BuiltValueField(wireName: 'email_verified_at')
  DateTime? get emailVerifiedAt;

  @BuiltValueField(wireName: 'group_id')
  int? get groupId;

  @BuiltValueField(wireName: 'group')
  Group? get group;

  @BuiltValueField(wireName: 'devices')
  BuiltList<Device>? get devices;

  @BuiltValueField(wireName: 'usr_roles')
  BuiltList<String>? get roles;

  @BuiltValueField(wireName: 'usr_perms')
  BuiltList<String>? get perms;

  @BuiltValueField(wireName: 'created_at')
  DateTime? get createdAt;

  @BuiltValueField(wireName: 'updated_at')
  DateTime? get updatedAt;

  @BuiltValueField(wireName: 'deleted_at')
  DateTime? get deletedAt;

  @memoized
  Permissions get permQuery => Permissions(this.perms);

  bool can(String perm) => permQuery.can('super') || permQuery.can(perm);

  bool canAny(Iterable<String> perms) => permQuery.can('super') || permQuery.canAny(perms);

  bool canAll(Iterable<String> perms) => permQuery.can('super') || permQuery.canAll(perms);

  String get avatarUrl => "https://www.gravatar.com/avatar/${md5.convert(utf8.encode(email!)).toString()}?d=mp";

  PageRouteInfo get postLogin => can('listing.list') ? ListingScreenRoute() : ListingScreenBookingsRoute();

  String toJson() {
    return json.encode(serializers.serializeWith(AuthUser.serializer, this));
  }

  static AuthUser? fromJson(String jsonString) {
    return serializers.deserializeWith(AuthUser.serializer, json.decode(jsonString));
  }
}
