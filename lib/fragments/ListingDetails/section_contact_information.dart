import 'package:courier_market_mobile/api/container.dart';
import 'package:courier_market_mobile/api/listings.dart';
import 'package:courier_market_mobile/api/validators.dart';
import 'package:courier_market_mobile/built_value/models/listing.dart';
import 'package:courier_market_mobile/fragments/location_form_field.dart';
import 'package:courier_market_mobile/fragments/section.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';

class SectionContactInformation extends StatefulWidget {
  final Listing? listing;
  final VoidCallback? onChange;

  SectionContactInformation({
    this.listing,
    this.onChange,
    Key? key,
  }) : super(key: key);

  @override
  _SectionContactInformationState createState() => _SectionContactInformationState();
}

class _SectionContactInformationState extends State<SectionContactInformation> {
  final _formKey = GlobalKey<FormState>();

  bool _autoValidate = false;

  TextEditingController _pickupController = TextEditingController();
  late PlaceDetails _pickupPlace;
  String? _pickupCompany;
  TextEditingController _pickupCompanyController = TextEditingController();
  String? _pickupContact;
  String? _pickupContactNumber;
  TextEditingController _dropoffController = TextEditingController();
  late PlaceDetails _dropoffPlace;
  String? _dropoffContact;
  String? _dropoffCompany;
  TextEditingController _dropoffCompanyController = TextEditingController();

  String? _dropoffContactNumber;

  @override
  Widget build(BuildContext context) => Section(
        title: Text("Contact Information"),
        child: Form(
          key: _formKey,
          autovalidate: _autoValidate,
          child: Column(
            children: [
              LocationFormField(
                controller: _pickupController,
                decoration: const InputDecoration(labelText: "Pickup Location"),
                onPlaceChange: (PlaceDetails place) {
                  setState(() => _pickupPlace = place);
                  if (place.types.contains("establishment")) {
                    _pickupCompanyController.text = place.name;
                    setState(() => _pickupCompany = place.name);
                  }
                },
                validator: Validators.validateNotEmpty,
              ),
              TextFormField(
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                decoration: const InputDecoration(labelText: "Pickup Company Name"),
                onChanged: (value) => setState(() => _pickupCompany = value),
                controller: _pickupCompanyController,
              ),
              TextFormField(
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                decoration: const InputDecoration(labelText: "Pickup Contact Name"),
                onChanged: (value) => setState(() => _pickupContact = value),
                validator: Validators.validateNotEmpty,
              ),
              TextFormField(
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                decoration: const InputDecoration(labelText: "Pickup Contact Number"),
                keyboardType: TextInputType.phone,
                onChanged: (value) => setState(() => _pickupContactNumber = value),
                validator: Validators.multiValidationBuilder([Validators.validateNotEmpty, Validators.validateNoSpace]),
              ),
              LocationFormField(
                controller: _dropoffController,
                decoration: const InputDecoration(labelText: "Dropoff Location"),
                onPlaceChange: (PlaceDetails place) {
                  setState(() => _dropoffPlace = place);
                  if (place.types.contains("establishment")) {
                    _dropoffCompanyController.text = place.name;
                    setState(() => _dropoffCompany = place.name);
                  }
                },
                validator: Validators.validateNotEmpty,
              ),
              TextFormField(
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                decoration: const InputDecoration(labelText: "Dropoff Company Name"),
                onChanged: (value) => setState(() => _dropoffCompany = value),
                controller: _dropoffCompanyController,
              ),
              TextFormField(
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                decoration: const InputDecoration(labelText: "Dropoff Contact Name"),
                onChanged: (value) => setState(() => _dropoffContact = value),
                validator: Validators.validateNotEmpty,
              ),
              TextFormField(
                textInputAction: TextInputAction.send,
                onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                decoration: const InputDecoration(labelText: "Dropoff Contact Number"),
                keyboardType: TextInputType.phone,
                onChanged: (value) => setState(() => _dropoffContactNumber = value),
                validator: Validators.multiValidationBuilder([Validators.validateNotEmpty, Validators.validateNoSpace]),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  RaisedButton(
                    child: Text("Update Listing"),
                    onPressed: () => updateListing(),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  updateListing() async {
    setState(() => _autoValidate = true);
    if (!_formKey.currentState!.validate()) return null;
    _formKey.currentState!.save();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => WillPopScope(
        onWillPop: () async => false,
        child: SimpleDialog(children: [
          Center(
            child: Column(children: [
              CircularProgressIndicator(),
              Divider(),
              Text("Please Wait"),
            ]),
          )
        ]),
      ),
    );

    return getIt<Listings>()
        .update(
      widget.listing!,
      _pickupPlace,
      _pickupCompany,
      _pickupContact,
      _pickupContactNumber,
      _dropoffPlace,
      _dropoffCompany,
      _dropoffContact,
      _dropoffContactNumber,
    )
        .then((res) {
      res!.displayAsToast();
      if (widget.onChange != null) widget.onChange!();
    }).whenComplete(() {
      Navigator.of(context).pop(true);
    });
  }
}
