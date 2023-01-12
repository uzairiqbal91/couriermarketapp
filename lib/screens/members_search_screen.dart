import 'package:auto_route/auto_route.dart';
import 'package:courier_market_mobile/api/container.dart';
import 'package:courier_market_mobile/api/members.dart';
import 'package:courier_market_mobile/built_value/models/user_search.dart';
import 'package:courier_market_mobile/built_value/responses/list_response.dart';
import 'package:courier_market_mobile/fragments/app_drawer.dart';
import 'package:courier_market_mobile/fragments/display_error.dart';
import 'package:courier_market_mobile/fragments/display_loader.dart';
import 'package:courier_market_mobile/fragments/label_set.dart';
import 'package:courier_market_mobile/fragments/section.dart';
import 'package:courier_market_mobile/router/router.gr.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MembersSearchScreen extends StatelessWidget {
  static const activeScreen = MembersSearchScreenRoute.name;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text("Members Search")),
        drawer: AppDrawer(activeRoute: activeScreen),
        body: MemberSearchList(),
      );
}

class MemberSearchList extends StatefulWidget {
  const MemberSearchList({Key? key}) : super(key: key);

  @override
  _MemberSearchListState createState() => _MemberSearchListState();
}

class _MemberSearchListState extends State<MemberSearchList> {
  String? query;

  Future<ListResponse<UserSearch>?>? search;

  Future<void>? handleSearch(String query) {
    var q = query.isEmpty ? null : query;
    if (q == null) return null;
    var fQ = getIt<Members>().search(q);
    setState(() {
      this.query = q;
      this.search = fQ;
    });
    return this.search;
  }

  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Search",
                contentPadding: const EdgeInsets.all(8.0),
              ),
              textInputAction: TextInputAction.search,
              autofocus: true,
              onSubmitted: handleSearch,
            ),
          ),
          Flexible(
            child: query == null
                ? DisplayError(message: "Please enter a search query", icon: Icon(Icons.search, size: 96))
                : FutureBuilder<ListResponse<UserSearch>?>(
                    future: search,
                    builder: (context, snapshot) => snapshot.connectionState == ConnectionState.waiting
                        ? DisplayLoader()
                        : snapshot.data!.data!.length == 0
                            ? DisplayError(message: "There are no results found")
                            : ListView.builder(
                                itemCount: snapshot.data!.data!.length,
                                itemBuilder: (context, index) => MemberListItem(snapshot.data!.data![index]),
                              ),
                  ),
          ),
        ],
      );
}

class MemberListItem extends StatelessWidget {
  final UserSearch user;

  MemberListItem(this.user, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Section(
        title: Text(
          '#${this.user.memberId} - ${this.user.companyName}',
          style: Theme.of(context).textTheme.subtitle1,
        ),
        trailing: RaisedButton(
          onPressed: () => AutoRouter.of(context).push(
            MembersSearchDetailScreenRoute(user: this.user),
          ),
          child: Text("View Feedback"),
        ),
        child: Column(children: <Widget>[
          Hero(
            tag: user.memberId!,
            child: Material(
              type: MaterialType.transparency,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
                LabelSet("Contact Name: ", this.user.firstName! + ' ' + this.user.lastName!),
                LabelSet("Contact Number: ", this.user.phoneNumber),
                LabelSet("Email: ", this.user.email),
                LabelSet("Company Reg: ", this.user.companyRegNumber),
                LabelSet("Pay Terms: ", this.user.paymentTerms),
                LabelSet("VAT: ", this.user.vat! ? 'Yes' : 'No'),
                LabelSet("Address: ", Expanded(child: Text(this.user.address!)))
              ]),
            ),
          ),
          if (this.user.vehicleFleet != null) InputDecorator(
            decoration: InputDecoration(
              floatingLabelBehavior: FloatingLabelBehavior.always,
              labelText: "Vehicle Fleet",
              border: InputBorder.none,
            ),
            child: Wrap(
              children: this.user.vehicleFleet!.map((String sug) => Chip(label: Text(sug))).toList(),
                spacing: 8,
                runSpacing: 4,
              ),
          )
        ]),
      );
}
