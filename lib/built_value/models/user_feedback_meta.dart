import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:courier_market_mobile/built_value/serializers.dart';

part 'user_feedback_meta.g.dart';

abstract class UserFeedbackMeta implements Built<UserFeedbackMeta, UserFeedbackMetaBuilder> {
  @BuiltValueField(wireName: 'delivery_avg')
  double? get deliveryAvg;

  @BuiltValueField(wireName: 'payment_avg')
  double? get paymentAvg;

  UserFeedbackMeta._();

  factory UserFeedbackMeta([void Function(UserFeedbackMetaBuilder)? updates]) = _$UserFeedbackMeta;

  Map<String, dynamic>? toJson() {
    return serializers.serializeWith(UserFeedbackMeta.serializer, this) as Map<String, dynamic>?;
  }

  static UserFeedbackMeta? fromJson(Map<String, dynamic> json) {
    return serializers.deserializeWith(UserFeedbackMeta.serializer, json);
  }

  static Serializer<UserFeedbackMeta> get serializer => _$userFeedbackMetaSerializer;
}
