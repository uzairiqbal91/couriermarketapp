import 'package:courier_market_mobile/api/container.dart';
import 'package:courier_market_mobile/api/listings.dart';
import 'package:courier_market_mobile/fragments/app_drawer.dart';
import 'package:courier_market_mobile/fragments/display_error.dart';
import 'package:courier_market_mobile/fragments/display_loader.dart';
import 'package:courier_market_mobile/fragments/listing_item.dart';
import 'package:courier_market_mobile/router/router.gr.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:listview_utils/listview_utils.dart';
import 'package:location/location.dart';

class ListingScreenLocation extends StatelessWidget {
  String get activeRoute => ListingScreenLocationRoute.name;

  Text get title => const Text("Nearby Jobs");

  final GlobalKey<CustomListViewState> listKey = GlobalKey<CustomListViewState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(activeRoute: activeRoute),
      appBar: AppBar(
        title: title,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => listKey.currentState!.refresh(),
          )
        ],
      ),
      body: LocationHandler(listKey: listKey),
    );
  }
}

class LocationHandler extends StatefulWidget {
  final Key? listKey;

  LocationHandler({
    this.listKey,
    Key? key,
  }) : super(key: key);

  @override
  _LocationHandlerState createState() => _LocationHandlerState();
}

class _LocationHandlerState extends State<LocationHandler> {
  final Location location = Location();

  bool _isLoadingServiceInit = true;
  bool _serviceEnabled = false;
  PermissionStatus? _permissionGranted;
  LocationData? _locationData;

  @override
  void initState() {
    super.initState();
    initLocation();
  }

  Future<bool> checkForServiceInit() async {
    if (!await location.serviceEnabled()) {
      await location.requestService();
      if (!await location.serviceEnabled()) {
        return false;
      }
    }
    return true;
  }

  Future<void> loadLocation() async {
    await location.changeSettings(accuracy: LocationAccuracy.balanced);
    final locationData = await location.getLocation();
    setState(() => _locationData = locationData);
  }

  Future<void> initLocation() async {
    final serviceInit = await checkForServiceInit();
    setState(() {
      _serviceEnabled = serviceInit;
      _isLoadingServiceInit = false;
    });
    if (serviceInit == false) return;

    final locationPerms = await location.hasPermission();
    setState(() => _permissionGranted = locationPerms);
    if (_permissionGranted == PermissionStatus.granted) await loadLocation();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingServiceInit) return DisplayLoader();
    if (!_serviceEnabled) return DisplayError(message: "We can't get your location at the moment");
    if (_permissionGranted == PermissionStatus.deniedForever)
      return DisplayError(message: "Please enable location in settings");
    if (_permissionGranted == PermissionStatus.denied) return _buildPermissionRequest();
    if (_locationData == null) return DisplayLoader();
    return _ListingLocationList(
      locationData: _locationData,
      listKey: widget.listKey,
    );
  }

  Widget _buildPermissionRequest() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Icon(
            Icons.location_on,
            size: 96.0 * 2,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                "Location Access",
                style: Theme.of(context).textTheme.headline3,
              ),
              Divider(),
              Text(
                "Please click the button below to allow us to use your location",
                style: Theme.of(context).textTheme.subtitle1,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                child: RaisedButton(
                  onPressed: _requestLocationPermission,
                  child: Text("Allow Location"),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  _requestLocationPermission() async {
    var perms = await location.requestPermission();
    setState(() => _permissionGranted = perms);
    if (perms == PermissionStatus.granted) await loadLocation();
  }
}

class _ListingLocationList extends StatelessWidget {
  final LocationData? locationData;
  final Key? listKey;

  const _ListingLocationList({
    this.listKey,
    Key? key,
    required this.locationData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => CustomListView(
        key: listKey!,
        loadingBuilder: (BuildContext context) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          ),
        ),
        empty: DisplayError(message: "There are no results found"),
        pageSize: 12,
        adapter: ListAdapter(fetchItems: (int offset, int limit) async {
          var items = await getIt<Listings>().list(
            page: (offset / limit).floor(),
            length: limit,
            filter: Listings.FILTER_SHOW_LOCATION,
            additional: {
              'location[lat]': locationData!.latitude.toStringAsFixed(6),
              'location[lng]': locationData!.longitude.toStringAsFixed(6),
            },
          );
          return ListItems(items!.data!, reachedToEnd: items.to == items.total);
        }),
        itemBuilder: (BuildContext context, int idx, dynamic item) => ListingItem(item),
      );
}
