import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:courier_market_mobile/api/auth.dart';
import 'package:courier_market_mobile/api/bookings.dart';
import 'package:courier_market_mobile/api/build_config.dart';
import 'package:courier_market_mobile/api/container.dart';
import 'package:courier_market_mobile/api/data_dictionary.dart';
import 'package:courier_market_mobile/api/listings.dart';
import 'package:courier_market_mobile/api/versions.dart';
import 'package:courier_market_mobile/built_value/enums/feedback_type.dart';
import 'package:courier_market_mobile/built_value/enums/listing_state.dart';
import 'package:courier_market_mobile/built_value/models/auth_user.dart';
import 'package:courier_market_mobile/built_value/models/feedback.dart';
import 'package:courier_market_mobile/built_value/models/listing.dart';
import 'package:courier_market_mobile/built_value/models/versions.dart';
import 'package:courier_market_mobile/fragments/ListingDetails/section_contact_information.dart';
import 'package:courier_market_mobile/fragments/ListingDetails/section_driver_assign.dart';
import 'package:courier_market_mobile/fragments/ListingDetails/section_place_bid.dart';
import 'package:courier_market_mobile/fragments/ListingDetails/section_view_bids.dart';
import 'package:courier_market_mobile/fragments/ListingDetails/tracking_map.dart';
import 'package:courier_market_mobile/fragments/display_error.dart';
import 'package:courier_market_mobile/fragments/display_response.dart';
import 'package:courier_market_mobile/fragments/feedback_item.dart';
import 'package:courier_market_mobile/fragments/label_set.dart';
import 'package:courier_market_mobile/fragments/section.dart';
import 'package:courier_market_mobile/router/router.gr.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide Feedback;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
class ListingDetailScreen extends StatelessWidget {
  static const activeRoute = ListingDetailScreenRoute.name;
  final int? listing;

  ListingDetailScreen(this.listing);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text("Listing #$listing")),
        body: ListingDetail(listing),
      );
}

class ListingDetail extends StatefulWidget {
  final int? listingId;

  ListingDetail(this.listingId);

  @override
  _ListingDetailState createState() => _ListingDetailState();
}

class _ListingDetailState extends State<ListingDetail> {
  final dtFormatter = DateFormat.yMd().add_jm();

  late Timer timer;
  int counter = 0;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 5), (Timer t) => getData());
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  late Future<Listing?> load;
  bool _isLoading = true;
  late Listings listingClient;

  Listing? _listing;
  Exception? _error;
  AuthUser? user;


  bool? get isOwner => _listing?.isOwnedBy(user!.group);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    user = getIt<Auth>().authUser.value;
    listingClient = getIt<Listings>();
    print({user, listingClient});
    getData();
  }

  Future<void> getData() => listingClient
          .get(widget.listingId)
          .then((Listing? listing) => setState(() => _listing = listing))
          .catchError((e) => setState(() => _error = e))
          .whenComplete(() {
        if (mounted) setState(() => _isLoading = false);
      });




  @override
  Widget build(BuildContext context) => _listing == null
      ? DisplayResponse(isLoading: _isLoading, error: _error)
      : RefreshIndicator(
          onRefresh: () => getData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildDetailsSection(),
                if (isOwner! && _listing!.bookStatus == false)
                  SectionContactInformation(listing: _listing, onChange: getData),
                if (!isOwner!) _buildAuthorDetailsSection(),
                if (_listing!.state == ListingState.complete) _buildPODDetailsSection(),
                _buildAdditionalInfoSection(),
                if (isOwner! && (_listing!.haulierId != null)) _buildAllocationDetailsSection(),
                if (user!.can('listing.list') &&
                    [ListingState.confirmed, ListingState.in_progress, ListingState.complete].contains(_listing!.state))
                  _buildAgreedPriceSection(),
                if (_listing!.notesExternal != null) _buildAdditionalNotesSection(),
                if (_listing!.state != ListingState.complete) _buildBidAndTrackSection(),
                if (_listing!.state == ListingState.complete) _buildFeedbackSection(),
                _buildActionsSection(),
              ],
            ),
          ),
        );

  Widget _buildPODDetailsSection() => Section(
        title: Text("POD Details"),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _addInfoLabelSet("Received By", _listing!.podReceivedBy),
            _addInfoLabelSet("Received On", _listing!.podReceivedOnFmt()),
            _addInfoLabelSet("Notes", _listing!.podNotes),
            Align(
              alignment: Alignment.bottomRight,
              child: OutlineButton(
                child: Text("View"),
                onPressed: () => launch(_listing!.podDocument!),
              ),
            )
          ],
        ),
      );

  Widget _buildDetailsSection() => Section(
        title: Text("Details"),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    LabelSet("From:", _listing!.pickupPostcode ?? ''),
                    LabelSet("To:", _listing!.dropoffPostcode ?? ''),
                  ],
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[
                  LabelSet("Pickup:", _listing!.pickupFmt() ?? ''),
                  LabelSet("Dropoff:", _listing!.dropoffFmt() ?? ''),
                ]),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                LabelSet("Dst: ", "${_listing!.estDistanceFmt ?? ''}"),
                LabelSet("Est: ", "${_listing!.estDurationFmt ?? ''}"),
              ],
            ),
          ],
        ),
      );

  Widget _buildAuthorDetailsSection() => Section(
        title: Text("Author Details"),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _addInfoLabelSet("Name", _listing!.ownerGroup!.name),
            _addInfoLabelSet("Contact Name", _listing!.ownerUser!.fullName),
            _addInfoLabelSet("Payment Terms", _listing!.payTerm),
            _addInfoLabelSet("Phone Number", _listing!.ownerPhoneNumber),
            Align(
              alignment: Alignment.bottomRight,
              child: OutlineButton(
                child: Text("Call"),
                onPressed: () => launch("tel:${_listing!.ownerPhoneNumber}"),
              ),
            )
          ],
        ),
      );

  Widget _buildAllocationDetailsSection() => Section(
        title: Text("Allocation Details"),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _addInfoLabelSet("Haulier Name", _listing!.haulier!.name),
            if (_listing!.driverId != null) _addInfoLabelSet("Driver Name", _listing!.driver!.fullName),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlineButton(
                  child: Text("Call Haulier"),
                  onPressed: () => launch("tel:${_listing!.haulier!.contactNumber}"),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _buildAdditionalInfoSection() => Section(
        title: Text("Additional Information"),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isOwner! || _listing!.haulierId == user!.groupId) ...[
              if (_listing!.pickupContact != null) _addInfoLabelSet("Pickup Contact", _listing!.pickupContact),
              if (_listing!.pickupNumber != null)
                _addInfoLabelSet(
                  "Pickup Phone",
                  OutlineButton(
                    child: Text(_listing!.pickupNumber!),
                    onPressed: () => launch("tel:${_listing!.pickupNumber}"),
                  ),
                ),
              if (_listing!.pickupCompany != null) _addInfoLabelSet("Company Name", _listing!.pickupCompany),
              _addInfoLabelSet(
                  "Pickup",
                  Text(
                    _listing!.pickupAddress!.split(',').join('\n'),
                    textAlign: TextAlign.end,
                  )),
              if (_listing!.dropoffContact != null) _addInfoLabelSet("Dropoff Contact", _listing!.dropoffContact),
              if (_listing!.dropoffNumber != null)
                _addInfoLabelSet(
                  "Dropoff Phone",
                  OutlineButton(
                    child: Text(_listing!.dropoffNumber!),
                    onPressed: () => launch("tel:${_listing!.dropoffNumber}"),
                  ),
                ),
              if (_listing!.dropoffCompany != null) _addInfoLabelSet("Company Name", _listing!.dropoffCompany),
              _addInfoLabelSet(
                  "Dropoff",
                  Text(
                    _listing!.dropoffAddress!.split(',').join('\n'),
                    textAlign: TextAlign.end,
                  )),
            ],
            _addInfoLabelSet("Freight Type", VEHICLE_FREIGHT[_listing!.vehicleFreight!]),
            _addInfoLabelSet("Job Type", JOB_TYPE[_listing!.jobType!]),
            _addInfoLabelSet("Load Type", VEHICLE_LOAD[_listing!.vehicleLoad!]),
            _addInfoLabelSet("Suggested Vehicles", _listing!.vehicleSuggestion!.map((v) => VEHICLE_TYPE[v]).join(', '))
          ],
        ),
      );

  Widget _buildAgreedPriceSection() => Section(
        title: Text("Agreed Price"),
        child: _listing!.bids!.length == 0
            ? DisplayError(message: "Cannot fetch agreed price")
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _addInfoLabelSet(
                    "Sub Total " + (_listing!.bids!.first.vat != null ? '(exc VAT)' : ''),
                    _listing!.bids!.first.costExcVat,
                  ),
                  if (_listing!.bids!.first.vat != null) _addInfoLabelSet("VAT", _listing!.bids!.first.vat),
                  _addInfoLabelSet(
                    "Grand Total",
                    (_listing!.bids!.first.vat == null
                        ? _listing!.bids!.first.costExcVat
                        : _listing!.bids!.first.costIncVat),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (_listing!.state == ListingState.complete && !isOwner!)
                        OutlineButton(
                          child: Text(_listing!.invoice == null ? "Send Invoice" : "Invoice Sent"),
                          onPressed: _listing!.invoice == null ? sendInvoice : null,
                        ),
                    ],
                  ),
                ],
              ),
      );

  Widget _buildAdditionalNotesSection() => Section(
        title: Text("Additional Notes"),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              initialValue: _listing!.notesExternal,
              minLines: 1,
              maxLines: 10,
              readOnly: true,
            ),
          ],
        ),
      );

  Widget _buildBidAndTrackSection() {
    if (_listing!.bookedAt == null) {
      if (isOwner!) {
        return SectionViewBids(_listing, listingClient, user, onBid: getData);
      } else {
        return SectionPlaceBid(_listing, listingClient, user, onBid: getData);
      }
    } else {
      if (!isOwner! && user!.can('listing.list')) {
        return SectionDriverAssign(_listing, listingClient, user, onUpdate: getData);
      } else {
        return Section(
          title: Text("Driver Location"),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _listing!.driverId == null
                  ? Text("Your driver has not yet been assigned!")
                  : AspectRatio(aspectRatio: 1, child: TrackingMap(_listing)),
            ],
          ),
        );
      }
    }
  }

  Widget _buildFeedbackSection() {
    return Section(
      title: Text("Feedback"),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _listing!.feedback!
            .map((Feedback i) => FeedbackItem(
                  i,
                  badge: Chip(
                    label: Text(
                        (i.type == (isOwner! ? FeedbackType.delivery : FeedbackType.payment)) ? "Sent" : "Received"),
                  ),
                ))
            .toList(),
      ),
    );
  }

//TODO: Move buttons out of here
  Widget _buildActionsSection() => Section(
        title: Text("Actions"),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (_listing!.state == ListingState.complete &&
                !_listing!.feedback!
                    .any((Feedback f) => f.type == (isOwner! ? FeedbackType.delivery : FeedbackType.payment)) &&
                _listing!.invoice != null)
              OutlineButton(
                child: Text("Feedback"),
                onPressed: () {
                  AutoRouter.of(context)
                      .push(ListingDetailFeedbackScreenRoute(listing: _listing))
                      .then((value) => getData());
                },
              ),
            if (!isOwner! && _listing!.driverId != null && _listing!.state == ListingState.confirmed)
              OutlineButton(
                child: Text("Mark Progress"),
                onPressed: () async {
                  if (await showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: Text("Are you sure?"),
                          content: Text(
                            "You are about to mark this booking as in progress\n" +
                                "Are you sure you would like to continue?",
                          ),
                          actions: <Widget>[
                            FlatButton(child: Text("Back"), onPressed: () => Navigator.of(context).pop(false)),
                            RaisedButton(child: Text("In Progress"), onPressed: () => Navigator.of(context).pop(true))
                          ],
                        ),
                      ) ==
                      true) await getIt<Bookings>().markInProgress(_listing!).then((value) => getData());
                },
              ),
            if (!isOwner! &&
                _listing!.driverId != null &&
                [ListingState.in_progress, ListingState.confirmed].contains(_listing!.state))
              OutlineButton(
                child: Text("POD"),
                onPressed: () {
                  AutoRouter.of(context)
                      .push(ListingDetailPodScreenRoute(listing: _listing))
                      .then((value) => getData())
                      .then((value) => getIt<Bookings>().markComplete(_listing!));
                },
              ),
          ],
        ),
      );

  Widget _addInfoLabelSet(key, value) => LabelSet(
        key,
        value,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
      );

  sendInvoice() async {
    setState(() => _isLoading = true);

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

    return listingClient.invoice(_listing!).then((res) {
      res!.displayAsToast();
      getData();
    }).whenComplete(() {
      setState(() => _isLoading = false);
      Navigator.pop(context);
    });
  }



}


