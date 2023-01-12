import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:courier_market_mobile/built_value/models/feedback.dart';
import 'package:courier_market_mobile/built_value/models/user_feedback_meta.dart';
import 'package:courier_market_mobile/built_value/serializers.dart';

part 'user_feedback.g.dart';

abstract class UserFeedback implements Built<UserFeedback, UserFeedbackBuilder> {
  UserFeedback._();

  factory UserFeedback([updates(UserFeedbackBuilder b)?]) = _$UserFeedback;

  static Serializer<UserFeedback> get serializer => _$userFeedbackSerializer;

  @BuiltValueField(wireName: 'payment')
  BuiltList<Feedback>? get payment;

  @BuiltValueField(wireName: 'delivery')
  BuiltList<Feedback>? get delivery;

  @BuiltValueField(wireName: 'misc')
  UserFeedbackMeta? get meta;

  String toJson() {
    return json.encode(serializers.serializeWith(UserFeedback.serializer, this));
  }

  static UserFeedback? fromJson(String jsonString) {
    return serializers.deserializeWith(UserFeedback.serializer, json.decode(jsonString));
  }
}
