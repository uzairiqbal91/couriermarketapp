import 'package:built_collection/built_collection.dart';
import 'package:courier_market_mobile/api/container.dart';
import 'package:courier_market_mobile/api/members.dart';
import 'package:courier_market_mobile/built_value/models/feedback.dart';
import 'package:courier_market_mobile/built_value/models/user_feedback.dart';
import 'package:courier_market_mobile/built_value/models/user_search.dart';
import 'package:courier_market_mobile/fragments/display_error.dart';
import 'package:courier_market_mobile/fragments/display_loader.dart';
import 'package:courier_market_mobile/fragments/feedback_item.dart';
import 'package:courier_market_mobile/fragments/label_set.dart';
import 'package:courier_market_mobile/fragments/section.dart';
import 'package:courier_market_mobile/router/router.gr.dart';
import 'package:flutter/material.dart' hide Feedback;

class MembersSearchDetailScreen extends StatelessWidget {
  static const activeScreen = MembersSearchDetailScreenRoute.name;
  final UserSearch? user;

  MembersSearchDetailScreen(this.user, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text("Member: ${this.user!.firstName}")),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Section(
              title: Text("Member Info"),
              child: Hero(
                tag: user!.memberId!,
                child: Material(
                  type: MaterialType.transparency,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
                    LabelSet("Contact Name: ", this.user!.firstName! + ' ' + this.user!.lastName!),
                    LabelSet("Contact Number: ", this.user!.phoneNumber),
                    LabelSet("Email: ", this.user!.email),
                    LabelSet("Company Reg: ", this.user!.companyRegNumber),
                    LabelSet("Pay Terms: ", this.user!.paymentTerms),
                    LabelSet("VAT: ", this.user!.vat! ? 'Yes' : 'No'),
                    LabelSet("Address: ", this.user!.address),
                  ]),
                ),
              ),
            ),
            MembersFeedBackWidget(user: this.user),
          ],
        ),
      );
}

class MembersFeedBackWidget extends StatefulWidget {
  final UserSearch? user;

  const MembersFeedBackWidget({Key? key, this.user}) : super(key: key);

  @override
  _MembersFeedBackWidgetState createState() => _MembersFeedBackWidgetState();
}

class _MembersFeedBackWidgetState extends State<MembersFeedBackWidget> {
  Future<UserFeedback?>? data;

  @override
  void initState() {
    super.initState();
    data = getIt<Members>().feedback(widget.user!.memberId);
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 2,
        child: Expanded(
          child: Section(
            child: FutureBuilder<UserFeedback?>(
              future: data,
              builder: (context, snapshot) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TabBar(
                    labelColor: Theme.of(context).primaryColorDark,
                    tabs: <Widget>[
                      _RatedTab(
                          label: Text("Payments"),
                          rating: Text(snapshot.data?.meta?.paymentAvg?.toStringAsFixed(1) ?? '?.?')),
                      _RatedTab(
                          label: Text("Delivery"),
                          rating: Text(snapshot.data?.meta?.deliveryAvg?.toStringAsFixed(1) ?? '?.?')),
                    ],
                  ),
                  Expanded(
                    child: snapshot.connectionState != ConnectionState.done
                        ? DisplayLoader()
                        : TabBarView(
                            children: [
                              _buildItemList(snapshot.data!.payment),
                              _buildItemList(snapshot.data!.delivery),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  _buildItemList(BuiltList<Feedback>? items) => items == null
      ? DisplayError(message: "No Feedback for this user!")
      : ListView.separated(
          itemCount: items.length,
          separatorBuilder: (context, index) => Divider(),
          itemBuilder: (context, index) => FeedbackItem(items[index]),
        );
}

class _RatedTab extends StatelessWidget {
  final Widget label;
  final Widget rating;

  _RatedTab({
    required this.label,
    required this.rating,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Tab(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            label,
            Chip(
              avatar: Icon(Icons.star),
              label: rating,
            )
          ],
        ),
      );
}
