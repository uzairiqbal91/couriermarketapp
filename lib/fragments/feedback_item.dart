import 'package:courier_market_mobile/built_value/models/feedback.dart';
import 'package:flutter/material.dart' hide Feedback;
import 'package:intl/intl.dart';

class FeedbackItem extends StatelessWidget {
  final Feedback item;
  final Widget? badge;

  const FeedbackItem(this.item, {this.badge, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  ...List.generate(
                    5,
                    (i) => Icon(
                      Icons.star,
                      color: item.rate! > i ? Colors.orangeAccent : Theme.of(context).disabledColor,
                    ),
                  ),
                  if (badge != null) badge!,
                ],
              ),
              SizedBox(height: 4),
              Text(
                item.note ?? "No Feedback Given",
                style: item.note != null
                    ? null
                    : TextStyle(
                        fontWeight: FontWeight.w300,
                        fontStyle: FontStyle.italic,
                      ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(DateFormat.yMd().format(item.createdAt!)),
              Text(item.feedbackFromName!),
            ],
          ),
        ],
      ),
    );
  }
}
