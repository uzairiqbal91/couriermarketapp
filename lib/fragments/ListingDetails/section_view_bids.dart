import 'package:courier_market_mobile/api/api_exception.dart';
import 'package:courier_market_mobile/api/container.dart';
import 'package:courier_market_mobile/api/hauliers.dart';
import 'package:courier_market_mobile/api/listings.dart';
import 'package:courier_market_mobile/built_value/enums/std_status.dart';
import 'package:courier_market_mobile/built_value/models/auth_user.dart';
import 'package:courier_market_mobile/built_value/models/bid.dart';
import 'package:courier_market_mobile/built_value/models/group.dart';
import 'package:courier_market_mobile/built_value/models/listing.dart';
import 'package:courier_market_mobile/fragments/section.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class SectionViewBids extends StatefulWidget {
  final Listing? listing;
  final Listings? client;
  final AuthUser? user;

  final Function()? onBid;

  SectionViewBids(
    this.listing,
    this.client,
    this.user, {
    this.onBid,
    Key? key,
  }) : super(key: key);

  @override
  _SectionViewBidsState createState() => _SectionViewBidsState();
}

class _SectionViewBidsState extends State<SectionViewBids> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) => Section(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text("Bids"),
            ButtonBar(
              buttonPadding: const EdgeInsets.all(0),
              children: [
                FlatButton(
                  child: Text("Cancel"),
                  onPressed: () => _cancelListing(),
                ),
                SizedBox(width: 4),
                RaisedButton(
                  child: Text("Assign"),
                  onPressed: widget.listing!.bookStatus! ? _directBooking : null,
                ),
              ],
            )
          ],
        ),
        child: IgnorePointer(
          ignoring: isLoading,
          child: ListTileTheme(
            contentPadding: const EdgeInsets.all(0),
            child: widget.listing!.bids!.length == 0
                ? Text(
                    "There are no bids on this listing!",
                    style: TextStyle(fontWeight: FontWeight.w300),
                  )
                : ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: widget.listing!.bids!.length,
                    itemBuilder: (BuildContext context, int i) => _buildBidTile(widget.listing!.bids![i]),
                  ),
          ),
        ),
      );

  Widget _buildBidTile(Bid bid) => ExpansionTile(
        title: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  bid.group!.name!,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Row(
              children: [
                Text("£${bid.costExcVat}"),
                if (bid.vat != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 2.0),
                    child: Text("(+£${bid.vat})"),
                  ),
              ],
            ),
          ],
        ),
        children: <Widget>[
          ButtonBar(
            children: <Widget>[
              FlatButton.icon(
                label: Text("Call"),
                icon: Icon(Icons.phone),
                onPressed: () => _callHaulier(bid),
              ),
              RaisedButton.icon(
                label: Text("Book"),
                icon: Icon(Icons.book),
                onPressed: () => widget.listing!.bookStatus! ? _bookHaulier(bid) : null,
              )
            ],
          ),
        ],
      );

  _cancelListing() async {
    var result = await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("Are you sure?"),
        content: Text("You are about to delete this listing\n" + "Are you sure you would like to continue?"),
        actions: <Widget>[
          FlatButton(child: Text("Back"), onPressed: () => Navigator.of(context).pop(false)),
          RaisedButton(child: Text("Cancel Listing"), onPressed: () => Navigator.of(context).pop(true))
        ],
      ),
    );
    if (result != true) return false;
    widget.client!.delete(widget.listing!).then((value) {
      Navigator.of(context).pop();
      value!.displayAsToast();
    });
  }

  Future<bool> _callHaulier(Bid b) async {
    if (b.contactNumber == null) return Fluttertoast.showToast(msg: "Cannot call");
    return await launch("tel:${b.contactNumber}");
  }

  Future<bool> _directBooking() async {
    bool? success = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => DirectAssign(widget.listing, onBid: widget.onBid),
    );
    if (success == true) {
      widget.onBid!();
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _bookHaulier(Bid b) async {
    bool? shouldBook = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("Are you sure?"),
        content: Text(
          "Please ensure you've confirmed: \n\"${b.group!.name}\"\n Is still able to take your booking!",
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          FlatButton(
            child: Text("Go Back"),
            onPressed: () => Navigator.pop(context, null),
          ),
          RaisedButton(
            child: Text("Book"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (shouldBook != true) return false;
    setState(() => isLoading = true);

    return await widget.client!.bookBid(b).then((res) {
      res!.displayAsToast();
      if (res.status == StdStatus.success) {
        widget.onBid!();
        return true;
      }
      return false;
    }).whenComplete(() {
      setState(() => isLoading = false);
    });
  }
}

class DirectAssign extends StatefulWidget {
  final Listing? listing;
  final Function()? onBid;

  DirectAssign(this.listing, {this.onBid}) : super();

  @override
  _DirectAssignState createState() => _DirectAssignState();
}

class _DirectAssignState extends State<DirectAssign> {
  bool isLoading = false;
  String? error;
  Group? group;

  TextEditingController ctrlId = TextEditingController();
  TextEditingController ctrlBid = TextEditingController();
  TextEditingController ctrlBidVat = TextEditingController();

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text("Assign Listing"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("Please enter the ID of the Haulier to perform a look-up,\nthen proceed to assign the listing!"),
              TextField(
                enabled: !isLoading && group == null,
                controller: ctrlId,
                decoration: InputDecoration(
                  labelText: "Haulier ID",
                  errorText: error,
                ),
                textInputAction: TextInputAction.search,
                keyboardType: TextInputType.number,
                onSubmitted: (value) => _searchForHaulier(),
              ),
              if (group != null) ...[
                TextField(
                  controller: ctrlBid,
                  decoration: InputDecoration(labelText: "Agreed Price"),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) {
                    if (value.isEmpty) {
                      ctrlBidVat.text = "";
                    } else {
                      ctrlBidVat.text = (int.parse(value) * 1.2).toStringAsFixed(2);
                    }
                  },
                ),
                if (group!.vat!)
                  TextField(
                    readOnly: true,
                    controller: ctrlBidVat,
                    decoration: InputDecoration(labelText: "Bid (Inc VAT)"),
                  ),
              ],
            ],
          ),
        ),
        actions: _buildActions(),
      );

  _buildActions() {
    if (group == null) {
      return [
        FlatButton(
          child: Text("Cancel"),
          onPressed: () => Navigator.of(context).pop(),
        ),
        RaisedButton(
          child: Text("Search"),
          onPressed: (isLoading || ctrlId.text == null) ? null : _searchForHaulier,
        )
      ];
    } else {
      return [
        FlatButton(
          child: Text("Back"),
          onPressed: () => setState(() => group = null),
        ),
        RaisedButton(
          child: Text("Assign"),
          onPressed: (isLoading) ? null : _assign,
        )
      ];
    }
  }

  Future<bool> _assign() {
    setState(() => isLoading = true);
    return getIt<Listings>()
        .bookHaulier(
      widget.listing!,
      group!,
      double.parse(ctrlBid.text),
    )
        .then((response) {
      response!.displayAsToast();
      if (response.status == StdStatus.success) {
        Navigator.of(context).pop(true);
        return true;
      } else {
        return false;
      }
    }).whenComplete(() {
      setState(() => isLoading = false);
    });
  }

  Future<bool> _searchForHaulier() {
    setState(() {
      error = null;
      isLoading = true;
    });
    return getIt<Hauliers>().lookup(int.parse(ctrlId.text)).then((response) {
      if (response!.status == StdStatus.success) {
        setState(() => group = response.data);
        return true;
      } else {
        setState(() => error = response.message);
        return false;
      }
    }).catchError((err) {
      if (err is ApiNotFoundException) {
        setState(() => error = "That haulier cannot be found!");
      } else {
        setState(() => error = err.toString());
      }
      return false;
    }).whenComplete(() => setState(() => isLoading = false));
  }
}
