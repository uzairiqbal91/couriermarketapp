import 'package:courier_market_mobile/api/listings.dart';
import 'package:courier_market_mobile/built_value/enums/std_status.dart';
import 'package:courier_market_mobile/built_value/models/auth_user.dart';
import 'package:courier_market_mobile/built_value/models/bid.dart';
import 'package:courier_market_mobile/built_value/models/listing.dart';
import 'package:courier_market_mobile/fragments/section.dart';
import 'package:flutter/material.dart';

class SectionPlaceBid extends StatefulWidget {
  final Listing? listing;
  final Listings? client;
  final AuthUser? user;

  final Function()? onBid;

  SectionPlaceBid(
    this.listing,
    this.client,
    this.user, {
    this.onBid,
    Key? key,
  }) : super(key: key);

  @override
  _SectionPlaceBidState createState() => _SectionPlaceBidState();
}

class _SectionPlaceBidState extends State<SectionPlaceBid> {
  final formKey = GlobalKey<FormState>();

  bool isLoading = false;
  double? bidAmount;
  String? bidNote;

  Bid? get ownBid => widget.listing!.ownBid(widget.user!.group);

  TextEditingController? ctrlBidAmount;
  TextEditingController? ctrlBidVatAmount;
  TextEditingController? ctrlBidNote;

  @override
  void initState() {
    super.initState();
    ctrlBidAmount = TextEditingController(text: ownBid?.costExcVat);
    ctrlBidVatAmount = TextEditingController(text: ownBid?.costIncVat);
    ctrlBidNote = TextEditingController(text: ownBid?.note);
    ctrlBidAmount!.addListener(updateVatCalculation);
    updateVatCalculation();
  }

  @override
  void dispose() {
    ctrlBidAmount!.dispose();
    ctrlBidVatAmount!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: <Widget>[
          Section(
            title: Text("Bid"),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: "Bid Amount"),
                  readOnly: ownBid != null,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  controller: ctrlBidAmount,
                  onSaved: (value) => setState(() => bidAmount = double.parse(value!)),
                  validator: (value) {
                    double? val = double.tryParse(value!);
                    if (val == null) return "Please enter a number";
                    if (val == null) return "Please enter a positive number";
                    return null;
                  },
                  onFieldSubmitted: (value) => FocusScope.of(context).nextFocus(),
                ),
                if (widget.user!.group!.vat!)
                  TextFormField(
                    readOnly: true,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    controller: ctrlBidVatAmount,
                    decoration: InputDecoration(labelText: "Bid (Inc VAT)"),
                  ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Notes",
                  ),
                  readOnly: ownBid != null,
                  controller: ctrlBidNote,
                  minLines: 1,
                  maxLines: 5,
                  maxLength: 255,
                  onSaved: (value) => setState(() => bidNote = value),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: RaisedButton(
                        padding: null,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        child: ownBid == null ? Text("Place Bid") : Text("Withdraw Bid"),
                        onPressed: isLoading ? null : (ownBid == null ? submitBid : withdrawBid),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  submitBid() {
    if (!formKey.currentState!.validate()) return null;
    formKey.currentState!.save();
    setState(() => isLoading = true);
    return widget.client!.placeBid(widget.listing!.id, bidAmount, bidNote).then((res) {
      res!.displayAsToast();
      if (res.status == StdStatus.success) widget.onBid!();
    }).whenComplete(() {
      setState(() => isLoading = false);
    });
  }

  withdrawBid() async {
    await widget.client!.withdrawBid(ownBid!);
    await widget.onBid!();
  }

  updateVatCalculation() {
    var value = ctrlBidAmount!.text;
    ctrlBidVatAmount!.text = value.isEmpty ? "" : (double.parse(value) * 1.2).toStringAsFixed(2);
  }
}
