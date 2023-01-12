import 'dart:async';

import 'package:courier_market_mobile/built_value/models/listing.dart';
import 'package:courier_market_mobile/built_value/models/map_marker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrackingMap extends StatefulWidget {
  final Listing? listing;

  TrackingMap(this.listing, {Key? key}) : super(key: key);

  @override
  _TrackingMapState createState() => _TrackingMapState();
}

class _TrackingMapState extends State<TrackingMap> {
  Map<String, BitmapDescriptor>? iconSet;
  GoogleMapController? mapController;

  @override
  void initState() {
    super.initState();
    getIconSet().then((value) => setState(() => iconSet = value));
  }

  Set<Marker> getMarkers() {
    var mapMapMarkers = widget.listing!.mapMarkers!.toMap();
    mapMapMarkers.removeWhere((String k, MapMarker v) => v.location == null);
    return mapMapMarkers.map((String k, MapMarker v) => MapEntry(k, v.toMarker(k, icon: iconSet![k]!))).values.toSet();
  }

  Future<Map<String, BitmapDescriptor>> getIconSet() async {
    Map<String, BitmapDescriptor> iconSet = {};
    await Future.wait(["driver", "dropoff", "pickup"].map((e) => BitmapDescriptor.fromAssetImage(
          ImageConfiguration.empty,
          'assets/icons/map/$e.png',
        ).then((value) => iconSet[e] = value)));
    return iconSet;
  }

  recenter({bool force = false}) async {
    if (mapController == null) return;
    var markerId = MarkerId("driver");

    if (!force) {
      if (!await mapController!.isMarkerInfoWindowShown(markerId)) return;
    }
    var driverLocation = getMarkers().firstWhere((element) => element.markerId == markerId);
    if (driverLocation == null) return;
    mapController!.animateCamera(CameraUpdate.newLatLng(driverLocation.position));
  }

  @override
  Widget build(BuildContext context) {
    if (iconSet == null) return Center(child: CircularProgressIndicator());
    var markers = getMarkers();
    recenter();
    return GoogleMap(
      markers: markers,
      initialCameraPosition: CameraPosition(
        target: widget.listing!.mapMarkers!['driver']?.location?.toGmapLocation() ??
            LatLng(
              (widget.listing!.mapMarkers!['pickup']!.location!.lat! +
                      widget.listing!.mapMarkers!['dropoff']!.location!.lat!) /
                  2,
              (widget.listing!.mapMarkers!['pickup']!.location!.lng! +
                      widget.listing!.mapMarkers!['dropoff']!.location!.lng!) /
                  2,
            ),
        zoom: 14,
      ),
      gestureRecognizers: Set()..add(Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer())),
      onMapCreated: (ctrl) {
        mapController = ctrl;
        Future.delayed(Duration(seconds: 2), () {
          var bounds = boundsFromLatLngList(markers.map<LatLng>((Marker e) {
            return e.position;
          }).toList());
          return ctrl.animateCamera(CameraUpdate.newLatLngBounds(bounds, 24));
        });
      },
    );
  }
}

LatLngBounds boundsFromLatLngList(List<LatLng> list) {
  double? x0, x1, y0, y1;
  for (LatLng latLng in list) {
    if (x0 == null) {
      x0 = x1 = latLng.latitude;
      y0 = y1 = latLng.longitude;
    } else {
      if (latLng.latitude > x1!) x1 = latLng.latitude;
      if (latLng.latitude < x0) x0 = latLng.latitude;
      if (latLng.longitude > y1!) y1 = latLng.longitude;
      if (latLng.longitude < y0!) y0 = latLng.longitude;
    }
  }
  return LatLngBounds(northeast: LatLng(x1!, y1!), southwest: LatLng(x0!, y0!));
}
