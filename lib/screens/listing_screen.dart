import 'dart:async';

import 'package:courier_market_mobile/api/container.dart';
import 'package:courier_market_mobile/api/listings.dart';
import 'package:courier_market_mobile/built_value/models/listing.dart';
import 'package:courier_market_mobile/built_value/responses/paginated_response.dart';
import 'package:courier_market_mobile/fragments/app_drawer.dart';
import 'package:courier_market_mobile/fragments/display_error.dart';
import 'package:courier_market_mobile/fragments/listing_item.dart';
import 'package:courier_market_mobile/router/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:listview_utils/listview_utils.dart';

class ListingScreen extends StatefulWidget {
  String get activeRoute => ListingScreenRoute.name;

  Text get title => const Text("All Listings");

  bool get filter => false;

  Future<PaginatedResponse<Listing>?> listDelegate(
    BuildContext context,
    int page,
    int length,
    Map<String, dynamic> filters,
  ) =>
      getIt<Listings>().list(page: page, length: length);

  @override
  _ListingScreenState createState() => _ListingScreenState();
}

class _ListingScreenState extends State<ListingScreen> {
  late Key key;
  bool isLoading = false;
  Map<String, dynamic> filters = {};

  @override
  void initState() {
    super.initState();
    this.generateKey();
  }

  void generateKey() {
    setState(() {
      key = ValueKey(DateTime.now().toIso8601String() + filters.hashCode.toString());
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        drawer: AppDrawer(activeRoute: widget.activeRoute),
        appBar: AppBar(
          title: widget.title,
          actions: <Widget>[
            if (widget.filter)
              IconButton(
                  icon: FaIcon(FontAwesomeIcons.filter),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (c) => FilterAlertDialog(
                        filters: filters,
                        onFiltersChanged: (Map<String, dynamic> f) {
                          setState(() => filters = f);
                          generateKey();
                        },
                      ),
                    );
                  }),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () => generateKey(),
            )
          ],
        ),
        body: CustomListView(
          key: key,
          loadingBuilder: (BuildContext context) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          ),
          empty: DisplayError(message: "There are no results found"),
          pageSize: 12,
          adapter: ListAdapter(fetchItems: (int offset, int limit) async {
            var items = await (widget.listDelegate(context, (offset / limit).floor(), limit, filters)
                as FutureOr<PaginatedResponse<Listing>>);
            return ListItems(items.data!, reachedToEnd: items.to == items.total);
          }),
          itemBuilder: (BuildContext context, int idx, dynamic item) => ListingItem(item),
        ),
      );
}

class FilterAlertDialog extends StatefulWidget {
  final Map<String, dynamic> filters;
  final void Function(Map<String, dynamic> f) onFiltersChanged;

  FilterAlertDialog({
    required this.filters,
    required this.onFiltersChanged,
    Key? key,
  }) : super(key: key);

  @override
  _FilterAlertDialogState createState() => _FilterAlertDialogState();
}

class _FilterAlertDialogState extends State<FilterAlertDialog> {
  final format = DateFormat.yMd().format as String Function(DateTime?);

  TextEditingController _ctrlBookedAtDate = TextEditingController();

  DateTime? _bookedAtTime;

  String? _memberId;

  String? _memberName;

  @override
  void initState() {
    super.initState();
    if (widget.filters['booked_at'] != null) _bookedAtTime = DateTime.parse(widget.filters['booked_at']);
    if (_bookedAtTime != null) _ctrlBookedAtDate.text = format(_bookedAtTime);
    _memberId = widget.filters['member_id'] ?? null;
    _memberName = widget.filters['member_name'] ?? null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Filter'),
      content: Container(
        width: MediaQuery.of(context).size.width,
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            TextFormField(
              controller: _ctrlBookedAtDate,
              decoration: InputDecoration(labelText: "Booked At"),
              readOnly: true,
              onTap: () async {
                var date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now().subtract(Duration(days: 365)),
                  lastDate: DateTime.now(),
                );
                if (date == null) return;
                _bookedAtTime = DateTime(date.year, date.month, date.day);
                _ctrlBookedAtDate.text = DateFormat.yMd().format(_bookedAtTime!);
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "Member ID"),
              initialValue: _memberId,
              keyboardType: TextInputType.number,
              onChanged: (v) => setState(() => _memberId = v),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "Member Name"),
              initialValue: _memberName,
              onChanged: (v) => setState(() => _memberName = v),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("Clear"),
          onPressed: () {
            Navigator.of(context).pop();
            widget.onFiltersChanged({
              'booked_at': null,
              'member_id': null,
              'member_name': null,
            });
          },
        ),
        RaisedButton(
          child: Text("Apply"),
          onPressed: () {
            Navigator.of(context).pop();
            widget.onFiltersChanged({
              'booked_at': _bookedAtTime?.toIso8601String(),
              'member_id': _memberId,
              'member_name': _memberName,
            });
          },
        ),
      ],
    );
  }
}
