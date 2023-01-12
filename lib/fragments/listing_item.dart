import 'package:auto_route/auto_route.dart';
import 'package:courier_market_mobile/api/data_dictionary.dart';
import 'package:courier_market_mobile/built_value/models/listing.dart';
import 'package:courier_market_mobile/fragments/label_set.dart';
import 'package:courier_market_mobile/router/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ListingItem extends StatelessWidget {
  final dtFormatter = DateFormat.yMd().add_jm();
  final Listing? _data;

  ListingItem(this._data);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(8.0),
      clipBehavior: Clip.hardEdge,
      child: Column(children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: <Widget>[
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
              Text(
                '#${this._data!.id}',
                style: Theme.of(context).textTheme.subtitle1,
              ),
              if (this._data!.canView!)
                RaisedButton(
                  onPressed: () => AutoRouter.of(context).push(
                    ListingDetailScreenRoute(listing: this._data!.id),
                  ),
                  child: Text("Details"),
                ),
            ]),
            Row(children: <Widget>[
              Expanded(
                flex: 1,
                child: Column(children: <Widget>[
                  LabelSet("From:", _data!.pickupPostcode ?? '?'),
                  LabelSet("To:", _data!.dropoffPostcode ?? '?'),
                  LabelSet("Dst:", _data!.estDistanceFmt ?? '?'),
                ]),
              ),
              Expanded(
                flex: 2,
                child: Column(children: <Widget>[
                  LabelSet("Pickup:", _data!.pickupFmt()),
                  LabelSet("Dropoff:", _data!.dropoffFmt()),
                  LabelSet("Booked:", _data!.bookedAtFmt()),
                ]),
              ),
            ]),
            InputDecorator(
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelText: "Suggested Vehicles",
                border: InputBorder.none,
              ),
              child: Wrap(
                children:
                    _data!.vehicleSuggestion!.map((String sug) => Chip(label: Text(VEHICLE_TYPE[sug] ?? sug))).toList(),
                spacing: 8,
                runSpacing: 4,
              ),
            )
          ]),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: theme.secondaryHeaderColor),
          child: DefaultTextStyle.merge(
            style: TextStyle(color: Colors.white),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("Est: ${_data!.estDurationFmt}"),
                Text("Posted: ${dtFormatter.format((_data!.publishedAt?.toLocal() ?? _data!.createdAt?.toLocal())!)}"),
              ],
            ),
          ),
        )
      ]),
    );
  }
}
