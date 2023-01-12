import 'package:auto_route/auto_route.dart';
import 'package:courier_market_mobile/api/container.dart';
import 'package:courier_market_mobile/api/data_dictionary.dart';
import 'package:courier_market_mobile/api/listings.dart';
import 'package:courier_market_mobile/api/validators.dart';
import 'package:courier_market_mobile/fragments/chip_form_field.dart';
import 'package:courier_market_mobile/fragments/datetime_form_field.dart';
import 'package:courier_market_mobile/fragments/location_form_field.dart';
import 'package:courier_market_mobile/fragments/section.dart';
import 'package:courier_market_mobile/router/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_webservice/places.dart';

class ListingCreateScreen extends StatelessWidget {
  static const activeRoute = ListingCreateScreenRoute.name;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onBackPressed(context),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Create Listing"),
        ),
        body: ListingCreateForm(),
      ),
    );
  }

  Future<bool> _onBackPressed(BuildContext context) async {
    bool? result = await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Are you sure?'),
        content: new Text('This listing has not been saved,\nare you sure you want to leave?'),
        actions: <Widget>[
          FlatButton(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Stay"),
          ),
          RaisedButton(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("Leave"),
          ),
        ],
      ),
    );
    return result == true;
  }
}

class ListingCreateForm extends StatefulWidget {
  @override
  _ListingCreateFormState createState() => _ListingCreateFormState();
}

class _ListingCreateFormState extends State<ListingCreateForm> {
  final _formKey = GlobalKey<FormState>();

  var _shouldAutoValidate = false;

  DateTime? _pickupTime;
  String? _pickupWithin;

  static const List<DropdownMenuItem<String>> _pickupWithinDrop = [
    DropdownMenuItem(value: null, child: Text("Time:")),
    DropdownMenuItem(value: "ASAP", child: Text("ASAP")),
    DropdownMenuItem(value: "Within 60 Mins", child: Text("Within 60 Mins")),
  ];

  final _ctrlPickupLocation = TextEditingController();
  late PlaceDetails _pickupLocation;

  DateTime? _dropoffTime;
  String? _dropoffWithin;

  static const List<DropdownMenuItem<String>> _dropoffWithinDrop = [
    DropdownMenuItem(value: null, child: Text("Time:")),
    DropdownMenuItem(value: "ASAP", child: Text("ASAP")),
  ];

  final _ctrlDropoffLocation = TextEditingController();
  late PlaceDetails _dropoffLocation;

  String? _jobType;

  static final List<DropdownMenuItem<String>> _jobTypeDrop = assembleDropdown(JOB_TYPE);

  String? _vehicleFreight;

  static final List<DropdownMenuItem<String>> _vehicleFreightDrop = assembleDropdown(VEHICLE_FREIGHT);

  String? _vehicleLoad;

  static final List<DropdownMenuItem<String>> _vehicleLoadDrop = assembleDropdown(VEHICLE_LOAD);

  List<int> _vehicleSuggestionIdx = [];

  List<String> get _vehicleSuggestion => _vehicleSuggestionIdx.map((i) => VEHICLE_TYPE.keys.toList()[i]).toList();

  List<int> _suggestedBodyIdx = [];

  List<String> get _suggestedBody => _suggestedBodyIdx.map((i) => VEHICLE_BODY.keys.toList()[i]).toList();

  String? _ctrlNotesExternal;

  var isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidate: _shouldAutoValidate,
      child: SingleChildScrollView(
        child: Column(children: [
          _buildSectionPickup(),
          _buildSectionDropoff(),
          _buildSectionSpec(),
          _buildSectionNotes(),
          _buildActionBar(),
        ]),
      ),
    );
  }

  Widget _buildSectionPickup() => Section(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField(
                    decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: "Pickup",
                    ),
                    isExpanded: true,
                    items: _pickupWithinDrop,
                    value: _pickupWithin,
                    onChanged: (String? value) => setState(() => _pickupWithin = value),
                  ),
                ),
                SizedBox(width: 8.0),
                Expanded(
                  flex: 3,
                  child: DateTimeFormField(
                    decoration: InputDecoration(labelText: "Pickup Time"),
                    enabled: _pickupWithin == null,
                    validator: _pickupWithin != null ? Validators.noop : Validators.validateRequired,
                    onSaved: (value) => setState(() => _pickupTime = value),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 14)),
                  ),
                ),
              ],
            ),
            LocationFormField(
              controller: _ctrlPickupLocation,
              decoration: InputDecoration(labelText: "Pickup Location"),
              onPlaceChange: (location) => setState(() => _pickupLocation = location),
              validator: Validators.validateRequired,
            ),
          ],
        ),
      );

  Widget _buildSectionDropoff() => Section(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField(
                    decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: "Dropoff",
                    ),
                    isExpanded: true,
                    items: _dropoffWithinDrop,
                    value: _dropoffWithin,
                    onChanged: (String? value) => setState(() => _dropoffWithin = value),
                  ),
                ),
                SizedBox(width: 8.0),
                Expanded(
                  flex: 3,
                  child: DateTimeFormField(
                    decoration: InputDecoration(labelText: "Dropoff Time"),
                    enabled: _dropoffWithin == null,
                    validator: _dropoffWithin != null ? Validators.noop : Validators.validateNotNull,
                    onSaved: (value) => setState(() => _dropoffTime = value),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 14)),
                  ),
                ),
              ],
            ),
            LocationFormField(
              controller: _ctrlDropoffLocation,
              decoration: InputDecoration(labelText: "Dropoff Location"),
              onPlaceChange: (location) => setState(() => _dropoffLocation = location),
              validator: Validators.validateRequired,
            )
          ],
        ),
      );

  Widget _buildSectionSpec() => Section(
        child: Column(
          children: <Widget>[
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: "Job Type"),
              items: _jobTypeDrop,
              value: _jobType,
              validator: Validators.validateRequired,
              onChanged: (String? value) => setState(() => _jobType = value),
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: "Freight Type"),
              items: _vehicleFreightDrop,
              value: _vehicleFreight,
              validator: Validators.validateRequired,
              onChanged: (String? value) => setState(() => _vehicleFreight = value),
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: "Vehicle Load"),
              items: _vehicleLoadDrop,
              value: _vehicleLoad,
              validator: Validators.validateRequired,
              onChanged: (String? value) => setState(() => _vehicleLoad = value),
            ),
            ChipFormField(
              decoration: InputDecoration(labelText: "Suggested Vehicles"),
              chips: VEHICLE_TYPE.values.map((e) => Text(e)).toList(),
              selectedIndexes: _vehicleSuggestionIdx,
              onSelectionChange: (List<int> selected) => setState(() => _vehicleSuggestionIdx = selected),
            ),
            ChipFormField(
              decoration: InputDecoration(labelText: "Vehicle Body"),
              chips: VEHICLE_BODY.values.map((e) => Text(e)).toList(),
              selectedIndexes: _suggestedBodyIdx,
              onSelectionChange: (List<int> selected) => setState(() => _suggestedBodyIdx = selected),
            )
          ],
        ),
      );

  Widget _buildSectionNotes() => Section(
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: "Additional Notes"),
              keyboardType: TextInputType.multiline,
              onChanged: (value) => setState(() => _ctrlNotesExternal = value),
              minLines: 1,
              maxLines: 5,
              maxLength: 512,
            ),
          ],
        ),
      );

  Widget _buildActionBar() => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: RaisedButton(
                child: Text("Post"),
                onPressed: isProcessing ? null : () => _onSubmit(),
              ),
            ),
          ),
        ],
      );

  _onSubmit() async {
    setState(() => _shouldAutoValidate = true);
    if (!_formKey.currentState!.validate()) return false;
    setState(() => isProcessing = true);

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

    try {
      final listingClient = getIt<Listings>();
      var listing = await (listingClient.post({
        'state': 'active',
        'job_type': _jobType,
        'pickup_address': _pickupLocation.formattedAddress,
        'pickup_placeid': _pickupLocation.placeId,
        'pickup_location': _pickupLocation.geometry.location.toJson(),
        'pickup_time': _pickupWithin == null ? _pickupTime!.toIso8601String() : null,
        'pickup_within': _pickupWithin,
        'dropoff_address': _dropoffLocation.formattedAddress,
        'dropoff_placeid': _dropoffLocation.placeId,
        'dropoff_location': _dropoffLocation.geometry.location.toJson(),
        'dropoff_time': _dropoffWithin == null ? _dropoffTime!.toIso8601String() : null,
        'dropoff_within': _dropoffWithin,
        'vehicle_load': _vehicleLoad,
        'vehicle_freight': _vehicleFreight,
        'vehicle_suggestion': _vehicleSuggestion,
        'vehicle_body': _suggestedBody,
        'notes_external': _ctrlNotesExternal,
      }));

      Fluttertoast.showToast(msg: "Successfully created Listing!");
      Navigator.of(context).pop(true);
      AutoRouter.of(context).replace(
        ListingDetailScreenRoute(listing: listing!.id),
      );
    } catch (e) {
      Navigator.of(context).pop(true);
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Something went wrong, please try again!"),
      ));
      throw (e);
    } finally {
      setState(() => isProcessing = false);
    }
  }
}
