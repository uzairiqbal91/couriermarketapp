import 'dart:io' show Platform;

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:courier_market_mobile/built_value/serializers.dart';

part 'device_type.g.dart';

class DeviceType extends EnumClass {
  const DeviceType._(String name) : super(name);

  @BuiltValueEnumConst(wireName: "WEB")
  static const DeviceType web = _$web;

  @BuiltValueEnumConst(wireName: "ANDROID")
  static const DeviceType android = _$android;

  @BuiltValueEnumConst(wireName: "IOS")
  static const DeviceType ios = _$ios;

  static BuiltSet<DeviceType> get values => _$deviceTypeValues;

  static DeviceType valueOf(String name) => _$deviceTypeValueOf(name);

  String? serialize() {
    return serializers.serializeWith(DeviceType.serializer, this) as String?;
  }

  static DeviceType? deserialize(String string) {
    return serializers.deserializeWith(DeviceType.serializer, string);
  }

  static Serializer<DeviceType> get serializer => _$deviceTypeSerializer;

  static DeviceType? get current {
    if (Platform.isAndroid) {
      return android;
    } else if (Platform.isIOS) {
      return ios;
    } else {
      return null;
    }
  }
}
