import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:courier_market_mobile/built_value/serializers.dart';

part 'user_registration.g.dart';

abstract class UserRegistration implements Built<UserRegistration, UserRegistrationBuilder> {
  @BuiltValueField(wireName: 'id')
  int? get id;

  @BuiltValueField(wireName: 'user_id')
  int? get userId;

  @BuiltValueField(wireName: 'dob')
  String? get dob;

  @BuiltValueField(wireName: 'address_line')
  String? get addressLine;

  @BuiltValueField(wireName: 'county')
  String? get county;

  @BuiltValueField(wireName: 'city')
  String? get city;

  @BuiltValueField(wireName: 'created_at')
  String? get createdAt;

  @BuiltValueField(wireName: 'updated_at')
  String? get updatedAt;

  @BuiltValueField(wireName: 'contact_number')
  String? get contactNumber;

  UserRegistration._();

  factory UserRegistration([void Function(UserRegistrationBuilder)? updates]) = _$UserRegistration;

  Map<String, dynamic>? toJson() {
    return serializers.serializeWith(UserRegistration.serializer, this) as Map<String, dynamic>?;
  }

  static UserRegistration? fromJson(Map<String, dynamic> json) {
    return serializers.deserializeWith(UserRegistration.serializer, json);
  }

  static Serializer<UserRegistration> get serializer => _$userRegistrationSerializer;
}
