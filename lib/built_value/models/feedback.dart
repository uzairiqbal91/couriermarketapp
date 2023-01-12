import 'dart:convert';

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:courier_market_mobile/built_value/enums/feedback_type.dart';
import 'package:courier_market_mobile/built_value/serializers.dart';

part 'feedback.g.dart';

abstract class Feedback implements Built<Feedback, FeedbackBuilder> {
  Feedback._();

  factory Feedback([void Function(FeedbackBuilder)? updates]) = _$Feedback;

  static Serializer<Feedback> get serializer => _$feedbackSerializer;

  @BuiltValueField(wireName: 'id')
  int? get id;

  @BuiltValueField(wireName: 'listing_id')
  int? get listingId;

  @BuiltValueField(wireName: 'feedback_from')
  int? get feedbackFrom;

  @BuiltValueField(wireName: 'feedback_from_name')
  String? get feedbackFromName;

  @BuiltValueField(wireName: 'feedback_to')
  int? get feedbackTo;

  @BuiltValueField(wireName: 'feedback_to_name')
  String? get feedbackToName;

  @BuiltValueField(wireName: 'rate')
  int? get rate;

  @BuiltValueField(wireName: 'note')
  String? get note;

  @BuiltValueField(wireName: 'type')
  FeedbackType? get type;

  @BuiltValueField(wireName: 'created_at')
  DateTime? get createdAt;

  String toJson() {
    return json.encode(serializers.serializeWith(Feedback.serializer, this));
  }

  static Feedback? fromJson(String jsonString) {
    return serializers.deserializeWith(Feedback.serializer, json.decode(jsonString));
  }
}
