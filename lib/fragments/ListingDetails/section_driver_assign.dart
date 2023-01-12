import 'package:built_collection/built_collection.dart';
import 'package:courier_market_mobile/api/container.dart';
import 'package:courier_market_mobile/api/drivers.dart';
import 'package:courier_market_mobile/api/listings.dart';
import 'package:courier_market_mobile/built_value/models/auth_user.dart';
import 'package:courier_market_mobile/built_value/models/listing.dart';
import 'package:courier_market_mobile/built_value/models/user.dart';
import 'package:courier_market_mobile/fragments/ListingDetails/tracking_map.dart';
import 'package:courier_market_mobile/fragments/section.dart';
import 'package:flutter/material.dart';

class SectionDriverAssign extends StatefulWidget {
  final Listing? listing;
  final Listings? client;
  final AuthUser? user;

  final Function()? onUpdate;

  SectionDriverAssign(
    this.listing,
    this.client,
    this.user, {
    this.onUpdate,
    Key? key,
  }) : super(key: key);

  @override
  _SectionDriverAssignState createState() => _SectionDriverAssignState();
}

class _SectionDriverAssignState extends State<SectionDriverAssign> {
  BuiltList<User>? driverList;
  User? driverSelected;

  bool isLoading = false;

  bool get isDirty => widget.listing!.driver != driverSelected;

  @override
  Widget build(BuildContext context) {
    return Section(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Driver Assignment"),
          if (widget.listing!.driver == null)
            RaisedButton(
              child: Text("Cancel"),
              onPressed: _cancelBooking,
            )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildDriverAssignment(),
          if (widget.listing!.driver != null) AspectRatio(aspectRatio: 1, child: TrackingMap(widget.listing)),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      driverSelected = widget.listing!.driver;
    });
    getIt<Drivers>().list().then((value) => setState(() => driverList = value));
  }

  Widget _buildDriverAssignment() => Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: DropdownButton(
              value: driverSelected,
              hint: Text("Select a driver"),
              items: driverList
                  ?.map((User driver) => DropdownMenuItem(
                        key: ValueKey(driver.id),
                        value: driver,
                        child: Text("${driver.firstName} ${driver.lastName}"),
                      ))
                  .toList(),
              onChanged: (dynamic value) => setState(() => driverSelected = value),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: RaisedButton(
              child: Text("Assign"),
              onPressed: isLoading || !isDirty
                  ? null
                  : () {
                setState(() => isLoading = true);
                      widget.client!.assignDriver(widget.listing!, driverSelected!).then((value) {
                        widget.onUpdate!();
                        value!.displayAsToast();
                      }).whenComplete(() {
                        setState(() => isLoading = false);
                      });
                    },
            ),
          )
        ],
      );

  _cancelBooking() async {
    var result = await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("Are you sure?"),
        content: Text("You are about to cancel this booking\n" + "Are you sure you would like to continue?"),
        actions: <Widget>[
          FlatButton(child: Text("Back"), onPressed: () => Navigator.of(context).pop(false)),
          RaisedButton(child: Text("Cancel Booking"), onPressed: () => Navigator.of(context).pop(true))
        ],
      ),
    );
    if (result != true) return false;
    widget.client!.bookingCancel(widget.listing!).then((value) {
      Navigator.of(context).pop();
      value!.displayAsToast();
    });
  }
}
