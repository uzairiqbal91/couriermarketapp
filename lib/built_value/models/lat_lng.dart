import 'dart:convert';

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:courier_market_mobile/built_value/serializers.dart';
import 'package:geolocator/geolocator.dart' show Position;
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:google_maps_webservice/places.dart' as places;

part 'lat_lng.g.dart';

abstract class LatLng implements Built<LatLng, LatLngBuilder> {
  LatLng._();

  factory LatLng([void Function(LatLngBuilder)? updates]) = _$LatLng;

  static Serializer<LatLng> get serializer => _$latLngSerializer;

  @BuiltValue(wireName: "lat")
  double? get lat;

  @BuiltValue(wireName: "lng")
  double? get lng;

  toGmapLocation() => gmap.LatLng(lat!, lng!);

  String toJson() {
    return json.encode(serializers.serializeWith(LatLng.serializer, this));
  }

  static LatLng? fromJson(String jsonString) {
    return serializers.deserializeWith(LatLng.serializer, json.decode(jsonString));
  }

  static LatLng fromPosition(Position location) => LatLng((b) => b
    ..lat = location.latitude
    ..lng = location.longitude);

  static LatLng fromPlace(places.Location location) => LatLng((b) => b
    ..lat = location.lat
    ..lng = location.lng);
}
