import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:courier_market_mobile/built_value/enums/device_type.dart';
import 'package:courier_market_mobile/built_value/models/lat_lng.dart';
import 'package:courier_market_mobile/built_value/serializers.dart';

part 'device.g.dart';

abstract class Device implements Built<Device, DeviceBuilder> {
  @BuiltValueField(wireName: 'id')
  int? get id;

  @BuiltValueField(wireName: 'fcm_id')
  String? get fcmId;

  @BuiltValueField(wireName: 'type')
  DeviceType? get type;

  @BuiltValueField(wireName: 'nick')
  String? get nick;

  @BuiltValueField(wireName: 'notify')
  bool? get notify;

  @BuiltValueField(wireName: 'locate')
  bool? get locate;

  @BuiltValueField(wireName: 'location')
  LatLng? get location;

  Device._();

  factory Device([void Function(DeviceBuilder)? updates]) = _$Device;

  static Serializer<Device> get serializer => _$deviceSerializer;

  Map<String, dynamic>? toJson() => serializers.serializeWith(serializer, this) as Map<String, dynamic>?;

  static Device? fromJson(Map<String, dynamic> json) => serializers.deserializeWith(serializer, json);
}
