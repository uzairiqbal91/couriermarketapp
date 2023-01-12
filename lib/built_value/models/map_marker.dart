import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:courier_market_mobile/built_value/models/lat_lng.dart';
import 'package:courier_market_mobile/built_value/serializers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;

part 'map_marker.g.dart';

abstract class MapMarker implements Built<MapMarker, MapMarkerBuilder> {
  MapMarker._();

  @BuiltValueField(wireName: 'label')
  String? get label;

  @BuiltValueField(wireName: 'location')
  LatLng? get location;

  gmap.Marker toMarker(
    String markerId, {
    gmap.BitmapDescriptor icon = gmap.BitmapDescriptor.defaultMarker,
  }) =>
      gmap.Marker(
        markerId: gmap.MarkerId(markerId),
        infoWindow: gmap.InfoWindow(title: label!),
        position: location!.toGmapLocation(),
        icon: icon,
      );

  factory MapMarker([void Function(MapMarkerBuilder)? updates]) = _$MapMarker;

  Map<String, dynamic>? toJson() => serializers.serializeWith(MapMarker.serializer, this) as Map<String, dynamic>?;

  static MapMarker? fromJson(Map<String, dynamic> json) => serializers.deserializeWith(MapMarker.serializer, json);

  static Serializer<MapMarker> get serializer => _$mapMarkerSerializer;
}
