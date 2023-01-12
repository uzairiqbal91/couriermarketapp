import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:courier_market_mobile/built_value/models/user_registration.dart';
import 'package:courier_market_mobile/built_value/serializers.dart';

part 'user.g.dart';

abstract class IUser {
  @BuiltValueField(wireName: 'id')
  int? get id;

  @BuiltValueField(wireName: 'first_name')
  String? get firstName;

  @BuiltValueField(wireName: 'last_name')
  String? get lastName;

  String get fullName => "$firstName $lastName";

  @BuiltValueField(wireName: 'registration')
  UserRegistration? get registration;
}

abstract class User with IUser implements Built<User, UserBuilder> {
  User._();

  factory User([void Function(UserBuilder)? updates]) = _$User;

  static BuiltList<User> fromJsonList(List<dynamic> json) {
    return BuiltList.from(json.map((e) => User.fromJson(e)));
  }

  Map<String, dynamic>? toJson() {
    return serializers.serializeWith(User.serializer, this) as Map<String, dynamic>?;
  }

  static User? fromJson(Map<String, dynamic> json) {
    return serializers.deserializeWith(User.serializer, json);
  }

  static Serializer<User> get serializer => _$userSerializer;
}
