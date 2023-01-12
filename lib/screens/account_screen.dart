import 'dart:math' as math;

import 'package:courier_market_mobile/api/auth.dart';
import 'package:courier_market_mobile/api/container.dart';
import 'package:courier_market_mobile/api/data_dictionary.dart';
import 'package:courier_market_mobile/api/devices.dart';
import 'package:courier_market_mobile/api/num_util.dart';
import 'package:courier_market_mobile/built_value/models/auth_user.dart';
import 'package:courier_market_mobile/built_value/responses/std_response.dart';
import 'package:courier_market_mobile/fragments/chip_form_field.dart';
import 'package:courier_market_mobile/fragments/label_set.dart';
import 'package:courier_market_mobile/fragments/location_form_field.dart';
import 'package:courier_market_mobile/fragments/section.dart';
import 'package:courier_market_mobile/router/router.gr.dart';
import 'package:flutter/foundation.dart' as Foundation;
import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';

class AccountScreen extends StatelessWidget {
  static const activeRoute = AccountScreenRoute.name;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text("Your Account")),
    body: Builder(
      builder: (context) => SafeArea(
        child: RefreshIndicator(
          onRefresh: getIt<Auth>().refreshUser,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ValueListenableBuilder(
              valueListenable: getIt<Auth>().authUser,
              builder: (BuildContext context, AuthUser? user, Widget? child) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Section(
                    child: Column(
                      children: [
                        Image.network(user!.avatarUrl),
                        Divider(),
                        Text(
                          "${user.firstName} ${user.lastName}",
                          style: Theme.of(context).textTheme.headline2,
                        ),
                      ],
                    ),
                  ),
                  if (!Foundation.kReleaseMode)
                    Section(
                        title: Text("Developer Options"),
                        child: Column(
                          children: [
                            RaisedButton(
                              child: Text("Sync Location"),
                              onPressed: () async => handleGeo(null, true),
                            ),
                          ],
                        )),
                  Section(
                    title: Text("About you"),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LabelSet.vertical("First Name", user.firstName),
                        LabelSet.vertical("Last Name", user.lastName),
                        LabelSet.vertical("Email", user.email),
                        LabelSet.vertical("Contact Number", user.registration?.contactNumber),
                      ],
                    ),
                  ),
                  Section(
                    title: Text("Your group"),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LabelSet.vertical("Name", user.group!.name),
                        LabelSet.vertical("Company Number", user.group!.companyNumber),
                        LabelSet.vertical("Vat Number", user.group!.vatNumber),
                      ],
                    ),
                  ),
                  SectionSearchNotifications(),
                  if (user.can('listing.list')) SectionPreferredJobSettings(user),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class SectionSearchNotifications extends StatefulWidget {
  final AuthUser? authUser;

  SectionSearchNotifications({this.authUser, Key? key}) : super(key: key);

  @override
  _SectionSearchNotificationsState createState() => _SectionSearchNotificationsState();
}

class _SectionSearchNotificationsState extends State<SectionSearchNotifications> {
  bool isLoading = false;
  Devices? devices;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    devices = getIt<Devices>();
  }

  Future withLoader(Future Function() callback) => Future(() => setState(() => isLoading = true))
      .then((value) => callback())
      .whenComplete(() => setState(() => isLoading = false));

  @override
  Widget build(BuildContext context) => Section(
    title: Text("Search and Notifications"),
    trailing: isLoading ? CircularProgressIndicator() : null,
    child: ListTileTheme.merge(
      contentPadding: const EdgeInsets.all(0),
      child: Column(
        children: [
          SwitchListTile(
            title: Text("Notifications"),
            value: devices!.isRegisteredNotify,
            onChanged: (value) => withLoader(() => devices!.deviceRegistration(notify: value)),
          ),
          SwitchListTile(
            title: Text("Location Updates"),
            subtitle: Text("Used for notifying of jobs nearby"),
            value: devices!.isRegisteredLocate,
            onChanged: (value) => withLoader(() => devices!.deviceRegistration(locate: value)),
          ),
        ],
      ),
    ),
  );
}

class SectionPreferredJobSettings extends StatefulWidget {
  final AuthUser? user;

  SectionPreferredJobSettings(this.user) : super();

  @override
  _SectionPreferredJobSettingsState createState() => _SectionPreferredJobSettingsState();
}

class _SectionPreferredJobSettingsState extends State<SectionPreferredJobSettings> {
  final formKey = GlobalKey<FormState>();

  List<int> _suggestedVehiclesIdx = [];

  List<String> get _suggestedVehicles => _suggestedVehiclesIdx.map((int i) => VEHICLE_TYPE.keys.toList()[i]).toList();

  TextEditingController? ctrlHomeLocation;

  PlaceDetails? homeLocation;
  late double distance;

  AuthUser? authUser;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    ctrlHomeLocation = TextEditingController(text: widget.user!.group!.homeAddress);
    _suggestedVehiclesIdx = widget.user!.group!.vehicleFleet == null
        ? []
        : widget.user!.group!.vehicleFleet!.map((String v) {
      return VEHICLE_TYPE.keys.toList().indexOf(v);
    }).toList();
    distance = NumUtil.kmToMiles(widget.user!.group!.radius ?? 0);
  }

  @override
  Widget build(BuildContext context) => Form(
    key: formKey,
    child: Section(
      title: Text("Preferred Jobs"),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          LocationFormField(
            controller: ctrlHomeLocation,
            onPlaceChange: (PlaceDetails place) => setState(() => homeLocation = place),
            decoration: InputDecoration(labelText: "Home Address"),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              showValueIndicator: ShowValueIndicator.always,
            ),
            child: InputDecorator(
              decoration: InputDecoration(labelText: "Distance ${distance.toStringAsFixed(2)}miles"),
              child: Slider(
                value: math.min(50, distance),
                    min: 0,
                    max: 50,
                    label: distance.toStringAsFixed(2),
                    onChanged: (v) => setState(() => distance = v),
                  ),
            ),
          ),
          ChipFormField(
            decoration: InputDecoration(labelText: "Suggested Vehicles"),
            chips: VEHICLE_TYPE.values.map((e) => Text(e)).toList(),
            selectedIndexes: _suggestedVehiclesIdx,
            onSelectionChange: (List<int> selected) => setState(() => _suggestedVehiclesIdx = selected),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              RaisedButton(
                child: Text("Save"),
                onPressed: () async {
                  var response = await (getIt<Auth>().updateAccountSettings({
                    if (homeLocation?.geometry != null)
                      'home_location': {
                        'lat': homeLocation!.geometry.location.lat,
                        'lng': homeLocation!.geometry.location.lng,
                      },
                    'home_address': homeLocation?.formattedAddress,
                    'radius': NumUtil.trimToPrecision(NumUtil.milesToKm(distance), 2),
                    'vehicle_fleet': _suggestedVehicles,
                  }) as Future<StdResponse>);
                  response.displayAsToast();
                },
              )
            ],
          ),
        ],
      ),
    ),
  );
}
