import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:courier_market_mobile/built_value/serializers.dart';

part 'user_search.g.dart';

abstract class UserSearch implements Built<UserSearch, UserSearchBuilder> {
  UserSearch._();

  factory UserSearch([updates(UserSearchBuilder b)?]) = _$UserSearch;

  static Serializer<UserSearch> get serializer => _$userSearchSerializer;

  @BuiltValueField(wireName: 'member_id')
  int? get memberId;

  @BuiltValueField(wireName: 'first_name')
  String? get firstName;

  @BuiltValueField(wireName: 'last_name')
  String? get lastName;

  @BuiltValueField(wireName: 'email')
  String? get email;

  @BuiltValueField(wireName: 'payments_terms')
  String? get paymentTerms;

  @BuiltValueField(wireName: 'company_name')
  String? get companyName;

  @BuiltValueField(wireName: 'company_reg_number')
  String? get companyRegNumber;

  @BuiltValueField(wireName: 'phone_number')
  String? get phoneNumber;

  @BuiltValueField(wireName: 'address')
  String? get address;

  @BuiltValueField(wireName: 'vat')
  bool? get vat;

  @BuiltValueField(wireName: 'vehicle_fleet')
  BuiltList<String>? get vehicleFleet;

  String toJson() {
    return json.encode(serializers.serializeWith(UserSearch.serializer, this));
  }

  static UserSearch? fromJson(String jsonString) {
    return serializers.deserializeWith(UserSearch.serializer, json.decode(jsonString));
  }
}
