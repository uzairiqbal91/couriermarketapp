import 'package:courier_market_mobile/api/build_config.dart';
import 'package:courier_market_mobile/api/container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:uuid/uuid.dart';

class LocationFormField extends StatelessWidget {
  final TextEditingController? controller;

  final InputDecoration? decoration;

  final void Function(PlaceDetails place) onPlaceChange;

  final String? sessionToken;

  final FormFieldValidator<String>? validator;

  LocationFormField({
    required this.onPlaceChange,
    required this.controller,
    this.sessionToken,
    this.decoration,
    this.validator,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        decoration: decoration,
        readOnly: true,
        onTap: () => _handleTap(context),
        validator: validator,
      );

  Future<void> _handleTap(BuildContext context) async {
    var prediction = await PlacesAutocomplete.show(
      context: context,
      sessionToken: sessionToken ?? Uuid().v4(),
      apiKey: getIt<BuildConfig>().gMapsApiKey,
      mode: Mode.fullscreen,
    );
    if (prediction == null) return;
    var _places = GoogleMapsPlaces(apiKey: getIt<BuildConfig>().gMapsApiKey);
    PlaceDetails place = await _places.getDetailsByPlaceId(
      prediction.placeId,
      fields: ["formatted_address", "geometry", "name", "place_id", "type"],
    ).then((value) => value.result);

    controller!.text = place.formattedAddress;
    onPlaceChange(place);
  }
}
