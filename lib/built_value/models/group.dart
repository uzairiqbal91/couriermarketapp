import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:courier_market_mobile/built_value/models/lat_lng.dart';
import 'package:courier_market_mobile/built_value/serializers.dart';

part 'group.g.dart';

abstract class Group implements Built<Group, GroupBuilder> {
  Group._();

  factory Group([void Function(GroupBuilder)? updates]) = _$Group;

  static Serializer<Group> get serializer => _$groupSerializer;

  @BuiltValueField(wireName: 'id')
  int? get id;

  @BuiltValueField(wireName: 'name')
  String? get name;

  @BuiltValueField(wireName: 'company_number')
  String? get companyNumber;

  @BuiltValueField(wireName: 'vat_number')
  String? get vatNumber;

  @BuiltValueField(wireName: 'operators_licence')
  String? get operatorsLicence;

  @BuiltValueField(wireName: 'operation_type')
  String? get operationType;

  @BuiltValueField(wireName: 'payment_terms')
  String? get paymentTerms;

  @BuiltValueField(wireName: 'vehicle_fleet')
  BuiltList<String>? get vehicleFleet;

  @BuiltValueField(wireName: 'home_address')
  String? get homeAddress;

  @BuiltValueField(wireName: 'home_location')
  LatLng? get homeLocation;

  @BuiltValueField(wireName: 'radius')
  double? get radius;

  @BuiltValueField(wireName: 'vat')
  bool? get vat;

  @BuiltValueField(wireName: 'contact_number')
  String? get contactNumber;

  @BuiltValueField(wireName: 'created_at')
  DateTime? get createdAt;

  @BuiltValueField(wireName: 'updated_at')
  DateTime? get updatedAt;

  String toJson() {
    return json.encode(serializers.serializeWith(Group.serializer, this));
  }

  static Group? fromJson(String jsonString) {
    return serializers.deserializeWith(Group.serializer, json.decode(jsonString));
  }
}
