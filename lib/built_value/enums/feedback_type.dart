import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:courier_market_mobile/built_value/serializers.dart';

part 'feedback_type.g.dart';

class FeedbackType extends EnumClass {
  @BuiltValueEnumConst(wireName: "delivery")
  static const FeedbackType delivery = _$delivery;

  @BuiltValueEnumConst(wireName: "payment")
  static const FeedbackType payment = _$payment;

  const FeedbackType._(String name) : super(name);

  static BuiltSet<FeedbackType> get values => _$feedbackTypeValues;

  static FeedbackType valueOf(String name) => _$feedbackTypeValueOf(name);

  String? serialize() {
    return serializers.serializeWith(FeedbackType.serializer, this) as String?;
  }

  static FeedbackType? deserialize(String string) {
    return serializers.deserializeWith(FeedbackType.serializer, string);
  }

  static Serializer<FeedbackType> get serializer => _$feedbackTypeSerializer;
}
